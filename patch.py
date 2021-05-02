#!/usr/bin/env python3

# some basic util libraries for my program
import argparse
import os
import shutil
import subprocess
import sys

#
# Hardcoded Values for Castlevania 1
#

# Maximum size of assembly payload
MAXSIZE=200

# 3 of those bytes are meant to overwrite an instruction
# elsewhere, not in our main block of code
ADJUST_SIZE=-3

# the first address we'll write our payload to
START_ADDR=0x3f18

# the final address where we'll stop writing our payload
# (the end condition will be when current_addr == END_ADDR)
END_ADDR=0x1bf19

# the amount of bytes between our payload addresses (thanks rom banks)
STEP=0x4000

# this is the address of the instruction we're going to overwrite to
# jump into our code
INJECTION_ADDR = 0x1c068

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
    parsey.add_argument("--asmfile", "-A",
            required=True, help="The ASM file to patch into the ROM")
    args = parsey.parse_args()

    args.assembler = "xa"

    if not args.inplace and not args.outfile:
        print("ERROR: please provide an output filename", file=sys.stderr)
        sys.exit(1)
    return args

def assemble(args):
    command = [args.assembler]
    if args.assemblerflags:
        command.extend(args.assemblerflags.strip().split(" "))
    command.extend([args.asmfile, "-o", "outasm.a65"])
    subprocess.check_call(command)
    s = os.stat("./outasm.a65")
    if s.st_size > MAXSIZE:
        raise Exception("ERROR: current binary size exceeds max size"
                f"of empty space in ROM ({s.st_size} > {MAXSIZE})")

def patch(args):
    payload_bytes = b""
    with open("./outasm.a65", "rb") as asmf:
        payload_bytes = asmf.read()
    jump_instruction = payload_bytes[-3:]
    payload_bytes = payload_bytes[:-3]

    with open(args.outfile, "r+b") as f:
        addr = START_ADDR
        while addr < END_ADDR:
            f.seek(addr)
            f.write(payload_bytes)
            addr += STEP
        f.seek(INJECTION_ADDR)
        f.write(jump_instruction)

def main(args):
    if os.path.exists(args.outfile) and not args.force:
        print("ERROR: output file already exists and --force (-f)"
                " not provided. Stopping.", file=sys.stderr)
        return 1
    assemble(args)
    if args.inplace:
        args.outfile = args.infile
    else:
        shutil.copy(args.infile, args.outfile)
    patch(args)
    return 0

if __name__ == "__main__":
    sys.exit(main(parse_args()))
