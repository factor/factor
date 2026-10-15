#!/usr/bin/env python3
"""Emit actual Factor primitive tests with an exact integer IEEE oracle.

Run the emitted file with a native m68k Factor image. It prints the number
of mismatches. Optional argument: vectors per operation (default 1024).
"""
import random
import sys

rng = random.Random(68881)
count = int(sys.argv[1]) if len(sys.argv) > 1 else 1024
print("USING: math math.floats.private kernel sequences prettyprint ;\n{")
for operation in range(2):
    for _ in range(count):
        a = (1 << 52) | rng.getrandbits(52)
        exponent = 1022 - rng.randrange(45) if operation == 0 else 1023 + rng.randrange(45)
        b = (exponent << 52) | rng.getrandbits(52)
        significand = (1 << 52) | (b & ((1 << 52) - 1))
        numerator, denominator = ((a * significand, 1 << (1075 - exponent))
                                  if operation == 0 else
                                  (a << (1075 - exponent), significand))
        result, remainder = divmod(numerator, denominator)
        if 2 * remainder > denominator or (2 * remainder == denominator and result & 1):
            result += 1
        print(f"{{ {operation} 0x{a:x} 0x{b:x} 0x{result:x} }}")
print("} [ first4 [ [ bits>double ] bi@ ] dip "
      "[ rot zero? [ * ] [ / ] if double>bits ] dip = not ] count .")
