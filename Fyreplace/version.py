#!/usr/bin/env python3

import os


def main():
    version = os.popen("git describe --tags").read().strip()[1:]
    parts = version.split("-")

    if len(parts) == 1:
        print(version)
        return

    version = parts[0]
    parts = version.split(".")
    print(f"{parts[0]}.{int(parts[1]) + 1}.0")


if __name__ == "__main__":
    main()
