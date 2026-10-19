! Copyright (C) 2026 Doug Coleman.
USING: bootstrap.image.private cpu.mips.assembler kernel namespaces parser sequences ;
IN: bootstrap.assembler.mips
big-endian on
mips-big-endian? on
<< "resource:basis/bootstrap/assembler/mips.64.factor" parse-file suffix! >> call
