! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: layouts literals math.bitwise math.order
sodium.ffi.const.size_max ;
IN: sodium.ffi.const

CONSTANT: SODIUM_SIZE_MAX $[ SIZE_MAX 64 on-bits min ]
