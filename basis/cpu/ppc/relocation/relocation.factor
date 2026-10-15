! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.constants compiler.codegen.relocation ;
IN: cpu.ppc.relocation

ALIAS: rc-absolute-ppc-2 rc-native-0
ALIAS: rc-absolute-ppc-2/2 rc-native-0
ALIAS: rc-absolute-ppc-2/2/2/2 rc-native-0
ALIAS: rc-relative-ppc-2-pc rc-native-1
ALIAS: rc-relative-ppc-3-pc rc-native-1

! A native absolute load into r2 identifies the ELFv1 TOC relocation.
ALIAS: rel-dlsym-toc rel-dlsym
