! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: checksums classes.singleton kernel math math.ranges
math.vectors sequences ;
IN: checksums.adler-32

SINGLETON: adler-32

CONSTANT: adler-32-modulus 65521

M: adler-32 checksum-bytes ( bytes checksum -- value )
    drop
    [ sum 1 + ]
    [ [ dup length [1,b] <reversed> v. ] [ length ] bi + ] bi
    [ adler-32-modulus mod ] bi@ 16 shift bitor ;

INSTANCE: adler-32 checksum
