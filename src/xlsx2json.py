# Copyright 2021 Richard Lincoln. All rights reserved.

import sys

from andes.system import System

import andes.io.xlsx as xlsxio
import andes.io.json as jsonio


def xlsx2json():
    if len(sys.argv) != 3:
        print("two args required", file=sys.stderr)
        exit(2)
    system = System()
    infile = sys.argv[1]
    xlsxio.read(system, infile)
    outfile = sys.argv[2]
    jsonio.write(system, outfile)


if __name__ == "__main__":
    xlsx2json()
