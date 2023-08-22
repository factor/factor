! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel layouts math math.bitwise sequences ;
IN: persistent.hashtables.config

: radix-bits ( -- n ) << cell 4 = 4 5 ? suffix! >> ; foldable
: radix-mask ( -- n ) radix-bits on-bits ; foldable
: full-bitmap-mask ( -- n ) radix-bits 2^ on-bits ; inline
