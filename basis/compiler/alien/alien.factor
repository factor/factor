! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces make math sequences layouts
alien.c-types cpu.architecture ;
IN: compiler.alien

: large-struct? ( ctype -- ? )
    dup c-struct? [ return-struct-in-registers? not ] [ drop f ] if ;

: alien-parameters ( params -- seq )
    dup parameters>>
    swap return>> large-struct? [ void* prefix ] when ;

: alien-return ( params -- ctype )
    return>> dup large-struct? [ drop void ] when ;

: c-type-stack-align ( type -- align )
    dup c-type-stack-align? [ c-type-align ] [ drop cell ] if ;

: parameter-align ( n type -- n delta )
    [ c-type-stack-align align dup ] [ drop ] 2bi - ;

: parameter-sizes ( types -- total offsets )
    #! Compute stack frame locations.
    [
        0 [
            [ parameter-align drop dup , ] keep stack-size +
        ] reduce cell align
    ] { } make ;
