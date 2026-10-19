! Copyright (C) 2011 Erik Charlebois.
! FreeBSD PowerPC64 uses the ELFv2 direct-entry ABI.
! See https://factorcode.org/license.txt for BSD license.
USING: parser system kernel sequences math ranges
cpu.ppc.assembler cpu.ppc.relocation combinators compiler.constants compiler.codegen.relocation
bootstrap.image.private layouts namespaces ;
IN: bootstrap.assembler.ppc

8 \ cell set
big-endian off
ppc-little-endian on

<< "resource:basis/bootstrap/assembler/ppc.64.freebsd-common.factor" parse-file suffix! >> call
