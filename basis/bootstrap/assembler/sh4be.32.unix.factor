! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.sh.assembler kernel namespaces parser sequences ;
IN: bootstrap.assembler.sh
sh-big-endian? on
sh-soft-abi? off
<< "resource:basis/bootstrap/assembler/sh4.32.factor" parse-file suffix! >> call
