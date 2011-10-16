! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: layouts kernel parser math math.bitwise sequences ;
IN: persistent.hashtables.config

: radix-bits ( -- n ) << cell 4 = 4 5 ? suffix! >> ; foldable
: radix-mask ( -- n ) radix-bits on-bits ; foldable
: full-bitmap-mask ( -- n ) radix-bits 2^ on-bits ; inline
