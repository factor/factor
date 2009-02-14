! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays alien.c-types alien.structs
sequences math kernel namespaces fry libc cpu.architecture ;
IN: alien.arrays

UNION: value-type array struct-type ;

M: array c-type ;

M: array c-type-class drop object ;

M: array heap-size unclip [ product ] [ heap-size ] bi* * ;

M: array c-type-align first c-type-align ;

M: array c-type-stack-align? drop f ;

M: array unbox-parameter drop "void*" unbox-parameter ;

M: array unbox-return drop "void*" unbox-return ;

M: array box-parameter drop "void*" box-parameter ;

M: array box-return drop "void*" box-return ;

M: array stack-size drop "void*" stack-size ;

M: array c-type-boxer-quot drop [ ] ;

M: array c-type-unboxer-quot drop [ >c-ptr ] ;

M: value-type c-type-reg-class drop int-regs ;

M: value-type c-type-getter
    drop [ swap <displaced-alien> ] ;

M: value-type c-type-setter ( type -- quot )
    [ c-type-getter ] [ c-type-unboxer-quot ] [ heap-size ] tri
    '[ @ swap @ _ memcpy ] ;
