! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.strings alien.c-types alien.accessors alien.structs
arrays words sequences math kernel namespaces fry libc cpu.architecture
io.encodings.utf8 ;
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

PREDICATE: string-type < pair
    first2 [ "char*" = ] [ word? ] bi* and ;

M: string-type c-type ;

M: string-type c-type-class
    drop object ;

M: string-type heap-size
    drop "void*" heap-size ;

M: string-type c-type-align
    drop "void*" c-type-align ;

M: string-type c-type-stack-align?
    drop "void*" c-type-stack-align? ;

M: string-type unbox-parameter
    drop "void*" unbox-parameter ;

M: string-type unbox-return
    drop "void*" unbox-return ;

M: string-type box-parameter
    drop "void*" box-parameter ;

M: string-type box-return
    drop "void*" box-return ;

M: string-type stack-size
    drop "void*" stack-size ;

M: string-type c-type-reg-class
    drop int-regs ;

M: string-type c-type-boxer
    drop "void*" c-type-boxer ;

M: string-type c-type-unboxer
    drop "void*" c-type-unboxer ;

M: string-type c-type-boxer-quot
    second '[ _ alien>string ] ;

M: string-type c-type-unboxer-quot
    second '[ _ string>alien ] ;

M: string-type c-type-getter
    drop [ alien-cell ] ;

M: string-type c-type-setter
    drop [ set-alien-cell ] ;

{ "char*" utf8 } "char*" typedef
"char*" "uchar*" typedef

