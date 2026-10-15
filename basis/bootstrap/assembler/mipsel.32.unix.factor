! Copyright (C) 2026 Doug Coleman.
USING: bootstrap.image.private cpu.mips.assembler kernel namespaces parser sequences ;
IN: bootstrap.assembler.mips
big-endian off
mips-big-endian? off
<< "resource:basis/bootstrap/assembler/mips.32.factor" parse-file suffix! >> call
