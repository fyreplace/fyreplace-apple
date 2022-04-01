#!/usr/bin/env python3

import os
import sys


def main():
    should_output_string = sys.argv[-1] == "string"
    branch = os.popen("git rev-parse --abbrev-ref HEAD").read().strip()
    branch_parts = branch.split("/")
    commit_count = os.popen("git rev-list --count HEAD").read().strip()
    version = os.popen("git describe --tags").read().strip()[1:]
    version_parts = version.split("-")

    if len(branch_parts) > 1 and branch_parts[0] in ["hotfix", "release"]:
        if should_output_string:
            print(branch_parts[1])
        else:
            build_suffix = 2 if branch_parts[0] == "release" else 1
            print(f"{commit_count}.{build_suffix}")
    elif len(version_parts) == 1:
        if should_output_string:
            print(version)
        else:
            print(commit_count + ".3")
    elif should_output_string:
        version = version_parts[0]
        version_parts = version.split(".")
        print(f"{version_parts[0]}.{int(version_parts[1]) + 1}.0")
    else:
        print(commit_count + ".0")


if __name__ == "__main__":
    main()
