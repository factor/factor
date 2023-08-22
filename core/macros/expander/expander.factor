! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
continuations effects generalizations kernel make math
namespaces quotations sequences sequences.private vectors words ;
IN: macros.expander

GENERIC: expand-macros ( quot -- quot' )

SYMBOL: stack

: begin ( -- )
    V{ } clone stack set ;

: end ( -- )
    stack get [ [ literalize , ] each ] [ delete-all ] bi ;

GENERIC: condomize? ( obj -- ? )

M: array condomize? [ condomize? ] any? ;
M: callable condomize? [ condomize? ] any? ;
M: object condomize? drop f ;

GENERIC: condomize ( obj -- obj' )

M: array condomize [ condomize ] map ;
M: callable condomize [ condomize ] map ;
M: object condomize ;

: literal ( obj -- )
    dup condomize? [ condomize ] when stack get push ;

GENERIC: expand-macros* ( obj -- )

M: wrapper expand-macros* wrapped>> literal ;

: expand-dispatch? ( word -- ? )
    \ dispatch eq? stack get length 1 >= and ;

: expand-dispatch ( -- )
    stack get pop end
    [ [ expand-macros ] [ ] map-as '[ _ dip ] % ]
    [
        length <iota> [ <reversed> ] keep
        [ '[ _ ndrop _ nnip call ] [ ] like ] 2map , \ dispatch ,
    ] bi ;

: word, ( word -- ) end , ;

: expand-macro ( word quot -- )
    '[
        drop
        stack [ _ with-datastack >vector ] change
        stack get pop >quotation end
        [ expand-macros* ] each
    ] [
        drop
        word,
    ] recover ;

: macro-quot ( word -- quot/f )
    {
        [ "transform-quot" word-prop ]
        [ "macro" word-prop ]
    } 1|| ;

: macro-effect ( word -- n )
    {
        [ "transform-n" word-prop ]
        [ stack-effect in>> length ]
    } 1|| ;

: expand-macro? ( word -- quot ? )
    dup macro-quot [
        swap macro-effect stack get length <=
    ] [
        drop f f
    ] if* ;

M: word expand-macros*
    {
        { [ dup expand-dispatch? ] [ drop expand-dispatch ] }
        { [ dup expand-macro? ] [ expand-macro ] }
        [ drop word, ]
    } cond ;

M: object expand-macros* literal ;

M: callable expand-macros*
    expand-macros literal ;

M: callable expand-macros
    [ begin [ expand-macros* ] each end ] [ ] make ;
