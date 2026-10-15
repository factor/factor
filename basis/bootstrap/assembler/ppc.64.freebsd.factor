! Copyright (C) 2011 Erik Charlebois.
! FreeBSD big-endian PowerPC64 uses ELFv2, unlike Linux ELFv1.
! See https://factorcode.org/license.txt for BSD license.
USING: parser system kernel sequences math ranges
cpu.ppc.assembler cpu.ppc.relocation combinators compiler.constants compiler.codegen.relocation
bootstrap.image.private layouts namespaces ;
IN: bootstrap.assembler.ppc

8 \ cell set
big-endian on
ppc-little-endian off

<< "resource:basis/bootstrap/assembler/ppc.64.freebsd-common.factor" parse-file suffix! >> call
