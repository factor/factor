! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.x86.features init kernel namespaces random
random.mersenne-twister random.sfmt ;
IN: random.backend

[
    sse2? [ default-sfmt ] [ default-mersenne-twister ] if
    random-generator set-global
] "bootstrap.random" add-init-hook
