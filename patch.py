#!/usr/bin/env python3

# some basic util libraries for my program
import argparse
import json
import os
import shutil
import subprocess
import sys

#
# Hardcoded Values for Castlevania 1
#

# But the way I've written this, it should be reusable in any game

# The various files and injection sites for the assembly code
# format is:
# {
#   "inject" : [
#     {
#       "file": <path to asm file>,
#       "address": <number or array of numbers>,
#       "max_size": <optional, max number of bytes that will fit at the addresses>
#     }
#   ]
# }
inject_json = {
    "inject": [
        {
            "file": "./cv_ui_interrupt.asm",
            "address": [0x3f18, 0x7f18, 0xbf18, 0xff18, 0x13f18, 0x17f18, 0x1bf18],
            "max_size": 210
        },
        {
            "file": "./cv_nmi_jmp.asm",
            "address": 0x1c068,
            "max_size": 3
        },
    ]
}

# The argparse library handles making command line flags
# for a program like "--help" and "-o" and such
def parse_args():
    parsey = argparse.ArgumentParser()
    parsey.add_argument("--assembler", "-a",
            help="The assembler program to use (default: xa)")
    parsey.add_argument("--assemblerflags", "-F",
            help="Extra command line flags to be passed to the"
            " assembler; Space separated")
    parsey.add_argument("--infile", "-i",
            help="The input NES file", required=True)
    parsey.add_argument("--outfile", "-o",
            help="The output NES file")
    parsey.add_argument("--force", "-f",
            action="store_true", help="Force overwrite of output file")
    parsey.add_argument("--inplace", "-I",
            action="store_true", help="Modify the input NES file directly")
    parsey.add_argument("--json", "-j",
            help="a file with a json specification of code injection (example in script)")
    args = parsey.parse_args()

    args.assembler = "xa"

    if not args.inplace and not args.outfile:
        print("ERROR: please provide an output filename", file=sys.stderr)
        sys.exit(1)

    if not args.json:
        global inject_json
        args.json = inject_json
    else:
        with open(args.json, "r") as f:
            args.json = json.load(f)

    return args

def verify_json(the_json):
    if "inject" not in the_json:
        return False, "ERROR: missing \"inject\" in top-level of json"
    a = the_json["inject"]
    for i in a:
        if "file" not in i:
            return False, f"ERROR: missing \"file\" in json ({i})"
        if type(i["file"]) != str:
            return False, f"ERROR: \"file\" isn't a string ({i})"
        if "address" not in i:
            return False, f"ERROR: missing \"address\" in json ({i})"
        if type(i["address"]) != int and type(i["address"]) != list:
            return False, f"ERROR: type of address isn't right, should be a number or an array ({i})"
        if type(i["address"]) == list:
            for x in i["address"]:
                if type(x) != int:
                    return False, f"ERROR: type of address array element isn't an integer ({x}, {i})"
        if "max_size" in i and type(i["max_size"]) != int:
            return False, f'ERROR: max_size provided, but it\'s not an integer ({i["max_size"]}, {i})'
    return True, ""

def assemble(asmfile, max_size, args):
    command = [args.assembler]
    if args.assemblerflags:
        command.extend(args.assemblerflags.strip().split(" "))
    command.extend([asmfile, "-o", "outasm.a65"])
    subprocess.check_call(command)
    s = os.stat("./outasm.a65")
    if max_size != -1 and s.st_size > max_size:
        raise Exception("ERROR: current binary size exceeds max size"
                f"of empty space in ROM ({s.st_size} > {max_size})")

def patch(addr, args):
    payload_bytes = b""
    with open("./outasm.a65", "rb") as asmf:
        payload_bytes = asmf.read()

    with open(args.outfile, "r+b") as f:
        def write(a):
            f.seek(a)
            f.write(payload_bytes)

        if type(addr) == list:
            for i in addr:
                write(i)
        else:
            write(addr)

def main(args):
    if os.path.exists(args.outfile) and not args.force:
        print("ERROR: output file already exists and --force (-f)"
                " not provided. Stopping.", file=sys.stderr)
        return 1
    res, err_str = verify_json(args.json)
    if not res:
        print(err_str, file=sys.stderr)
        return 1
    inject_arr = args.json["inject"]
    if args.inplace:
        args.outfile = args.infile
    else:
        shutil.copy(args.infile, args.outfile)
    for i in inject_arr:
        max_size = -1
        if "max_size" in i:
            max_size = i["max_size"]
        assemble(i["file"], max_size, args)
        patch(i["address"], args)
    return 0

if __name__ == "__main__":
    sys.exit(main(parse_args()))
