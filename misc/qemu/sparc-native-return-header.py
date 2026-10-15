from pathlib import Path
import sys

p = Path(sys.argv[1])
prefix = (p / "prolog.bin").read_bytes()
code = prefix + (p / "primitive.bin").read_bytes()
code += (p / "observe.bin").read_bytes()
code += (p / "epilog.bin").read_bytes() + (p / "return.bin").read_bytes()
rel = (p / "primitive.reloc").read_bytes()
records = [int.from_bytes(rel[i:i + 4], "big") for i in range(0, len(rel), 4)]
(p / "sparc-native-return-data.h").write_text(
    "static const unsigned char gate_code[]={" + ",".join(map(str, code)) + "};\n"
    "static const unsigned gate_rel[]={" + ",".join(map(str, records)) + "};\n"
    "enum { gate_prefix=" + str(len(prefix)) + " };\n"
)
