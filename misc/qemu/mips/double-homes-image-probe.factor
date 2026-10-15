! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel math.functions math.libm memory ;
IN: mips.double-homes-image
! Execute the existing compiled words, without compiling a new inline caller.
3.0 4.0 5.0 \ ffma execute 17.0 assert=
3.0 4.0 5.0 \ fma execute 17.0 assert=
gc
3.0 4.0 5.0 \ ffma execute 17.0 assert=
3.0 4.0 5.0 \ fma execute 17.0 assert=
"Compiled libm fma and existing inline caller PASS" print flush
