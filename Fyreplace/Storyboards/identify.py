#!/usr/bin/env python3

import enum
import glob
import os
import re
import sys
from collections import OrderedDict
from hashlib import sha256
from os.path import basename, dirname, realpath, splitext
from typing import Dict, List, Optional, Text, Tuple
from xml.etree import ElementTree as etree


class TreeBuilder(etree.TreeBuilder):
    def comment(self, data: Text):
        self.start(etree.Comment, {})
        self.data(data)
        self.end(etree.Comment)


class IdPartType(enum.Enum):
    NAME = "name"
    STRING = "string"
    REFERENCE = "reference"
    SEPARATOR = "separator"


class IdForm(enum.Enum):
    FULL = "full"
    HASH = "hash"
    SHRINK = "shrink"


IdPart = Tuple[IdPartType, Text]
Id = List[IdPart]
Mapping = Dict[Text, Tuple[Id, IdForm]]


sanitizer = re.compile("[^A-Za-z0-9-]")
last_comment: Optional[Text] = None
id_counters: List[int] = []


def process(storyboard: Text):
    global last_comment
    last_comment = None

    tree = etree.parse(storyboard, parser=etree.XMLParser(target=TreeBuilder()))
    mapping = OrderedDict()
    storyboard_name = splitext(basename(storyboard))[0]
    walk(tree.find("scenes"), mapping, [])

    for name in [storyboard] + glob.glob(f"**/{storyboard_name}.strings"):
        old_to_new = [(old, new) for old, new in mapping_items(mapping) if old != new]

        if len(old_to_new) == 0:
            break

        with open(name, "r") as f:
            data = f.read()

        def do_replace(first_step: bool) -> Text:
            nonlocal data

            for id_attr in (
                "sceneID",
                "id",
                "reference",
                "destination",
                "firstItem",
                "secondItem",
                "AnchorView",
                "ViewCell",
                "Label"
            ):
                old_prefix = f'{id_attr}="' if first_step else '"='
                new_prefix = f'{id_attr}="=' if first_step else '"'

                for old_id, new_id in old_to_new:
                    if not first_step:
                        old_id = new_id

                    for end in ['"', "."]:
                        data = data.replace(
                            old_prefix + old_id + end,
                            new_prefix + new_id + end,
                        )

            old_prefix = '>' if first_step else '>='
            new_prefix = '>=' if first_step else '>'
            end = '<'

            for old_id, new_id in old_to_new:
                if not first_step:
                    old_id = new_id

                data = data.replace(
                    old_prefix + old_id + end,
                    new_prefix + new_id + end,
                )

            return data

        data = do_replace(first_step=True)
        data = do_replace(first_step=False)

        with open(name, "w") as f:
            f.write(data)


def walk(node: etree.Element, mapping: Mapping, prefix: Id):
    global last_comment
    global id_counters

    if node.tag == etree.Comment:
        last_comment = node.text
    elif node.tag == "scene":
        identifier = make_id(*prefix, (IdPartType.STRING, last_comment))
        mapping[node.attrib["sceneID"]] = (identifier, IdForm.HASH)
        prefix = identifier
    elif "id" in node.attrib:
        node_id, form = get_id(node)
        identifier = make_id(*prefix, *node_id)
        mapping[node.attrib["id"]] = (identifier, form)
        prefix = identifier
    else:
        for child in node:
            if child.tag == "string" and child.attrib.get("key") == "id":
                node_id, form = get_id(node)
                identifier = make_id(*prefix, *node_id)
                mapping[child.text] = (identifier, form)
                prefix = identifier

    id_counters.append(0)

    for child in node:
        walk(child, mapping, prefix)

    id_counters.pop()


def get_id(node: etree.Element) -> Tuple[Id, bool]:
    global id_counters

    if node.tag == "constraint":
        return (
            make_id(
                (IdPartType.NAME, "-C"),
                (IdPartType.REFERENCE, node.attrib.get("firstItem")),
                (IdPartType.STRING, node.attrib.get("firstAttribute")),
                (IdPartType.STRING, node.attrib.get("relation")),
                (IdPartType.REFERENCE, node.attrib.get("secondItem")),
                (IdPartType.STRING, node.attrib.get("secondAttribute")),
            ),
            IdForm.SHRINK,
        )
    elif node.tag == "action":
        return (
            make_id(
                (IdPartType.NAME, "-A"),
                (IdPartType.STRING, node.attrib.get("eventType")),
                (IdPartType.REFERENCE, node.attrib.get("destination")),
                (IdPartType.STRING, node.attrib.get("selector")),
            ),
            IdForm.HASH,
        )
    elif node.tag == "outlet":
        return (
            make_id(
                (IdPartType.NAME, "-O"),
                (IdPartType.STRING, node.attrib.get("property")),
            ),
            IdForm.HASH,
        )
    elif node.tag == "outletCollection":
        return (
            make_id(
                (IdPartType.NAME, "-O"),
                (IdPartType.STRING, node.attrib.get("property")),
                (IdPartType.STRING, node.attrib.get("destination")),
            ),
            IdForm.HASH,
        )
    elif node.tag == "segue":
        return (
            make_id(
                (IdPartType.NAME, "-S"),
                (IdPartType.REFERENCE, node.attrib.get("destination")),
            ),
            IdForm.HASH,
        )

    def try_attributes(attrs: List[Text]) -> Optional[Text]:
        for attr in attrs:
            value = node.attrib.get(attr)

            if value is not None:
                return value

    label = try_attributes(
        [
            "userLabel",
            "title",
            "headerTitle",
            "reuseIdentifier",
            "text",
            "placeholder",
            "image",
        ]
    )

    if node.tag == "button":
        for child in node:
            if child.tag == "state" and child.attrib.get("key") == "normal":
                label = child.attrib.get("title")
    elif node.tag == "barButtonItem" and label is None:
        label = node.attrib.get("systemItem")

    if (
        label is None
        and (node.tag.endswith("Cell") or node.tag.endswith("Section"))
        and len(id_counters) > 0
    ):
        label = node.tag + "-{:02x}".format(id_counters[-1])
        id_counters[-1] += 1

    label = label or try_attributes(["customClass", "key"])
    return ([(IdPartType.STRING, label or node.tag)], IdForm.FULL)


def make_id(*parts: IdPart) -> Id:
    actual_parts = [part for part in parts if part[1]]
    result = list()

    def is_sep(part: IdPart):
        return part[0] == IdPartType.SEPARATOR

    for i in range(len(actual_parts)):
        if i > 0 and not is_sep(actual_parts[i - 1]) and not is_sep(actual_parts[i]):
            result.append((IdPartType.SEPARATOR, "-"))

        result.append(actual_parts[i])

    return result


def mapping_items(mapping: Mapping) -> List[Tuple[Text, Text]]:
    items = sorted(mapping.items(), key=lambda i: resolve_id(mapping, i[1][0]))
    counters = list()
    result = dict()
    previous_id_string = ""

    for old_id, new_id_data in items:
        new_id, form = new_id_data
        goes_deeper = False

        while len(counters) < len(new_id):
            counters.append(0)
            goes_deeper = True

        if not goes_deeper:
            counters = counters[0 : len(new_id)]
            counters[-1] += 1

        if form == IdForm.FULL:
            new_id_string = resolve_id(mapping, new_id)
        elif form == IdForm.HASH:
            new_id_string = hash_id(mapping, new_id)
        elif form == IdForm.SHRINK:
            new_id_string = shrink_id(new_id, counters)
        else:
            sys.exit(f"Invalid ID form: {form}")

        if new_id_string != old_id:
            result[old_id] = new_id_string

        if new_id_string == previous_id_string:
            sys.exit(f"Two objects have the same ID: {new_id_string}")
        else:
            previous_id_string = new_id_string

    return result.items()


def resolve_id(mapping: Mapping, identifier: Id) -> Text:
    return "".join([resolve_id_part(mapping, part) for part in identifier])


def resolve_id_part(mapping: Mapping, part: IdPart) -> Text:
    part_type = part[0]
    part_value = part[1]

    if part_type == IdPartType.STRING:
        return sanitizer.sub("-", part_value)
    elif part_type == IdPartType.REFERENCE:
        return resolve_id(mapping, mapping[part_value][0])
    else:
        return part_value


def hash_id(mapping: Mapping, identifier: Id) -> Text:
    return sha256(resolve_id(mapping, identifier).encode()).hexdigest()


def shrink_id(identifier: Id, counters: List[int]) -> Text:
    result = ""

    for i, part in enumerate(identifier):
        part_type, part_value = part

        if part_type == IdPartType.SEPARATOR:
            result += part_value
        else:
            result += (
                part_value
                if part_type == IdPartType.NAME
                else "{:02x}".format(counters[i])
            )

    return result


if __name__ == "__main__":
    os.chdir(dirname(realpath(__file__)))

    for storyboard in glob.iglob("*/*.storyboard"):
        process(storyboard)
