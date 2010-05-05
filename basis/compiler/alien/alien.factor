! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces make math sequences layouts
alien.c-types cpu.architecture ;
IN: compiler.alien

: large-struct? ( type -- ? )
    dup c-struct? [ return-struct-in-registers? not ] [ drop f ] if ;

: alien-parameters ( params -- seq )
    dup parameters>>
    swap return>> large-struct? [ struct-return-pointer-type prefix ] when ;

: alien-return ( params -- type )
    return>> dup large-struct? [ drop void ] when ;
