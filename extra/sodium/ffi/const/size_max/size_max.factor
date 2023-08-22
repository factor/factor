! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: layouts literals math.bitwise ;
IN: sodium.ffi.const.size_max

CONSTANT: SIZE_MAX $[ cell-bits on-bits ]
