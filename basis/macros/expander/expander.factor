! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private namespaces make
quotations accessors words continuations vectors effects math
generalizations stack-checker.transforms fry ;
IN: macros.expander

GENERIC: expand-macros ( quot -- quot' )

SYMBOL: stack

: begin ( -- ) V{ } clone stack set ;

: end ( -- )
    stack get
    [ [ literalize , ] each ]
    [ delete-all ]
    bi ;

: literal ( obj -- ) stack get push ;

GENERIC: expand-macros* ( obj -- )

: (expand-macros) ( quot -- )
    [ expand-macros* ] each ;

M: wrapper expand-macros* wrapped>> literal ;

: expand-dispatch? ( word -- ? )
    \ dispatch eq? stack get length 1 >= and ;

: expand-dispatch ( -- )
    stack get pop end
    [ [ expand-macros ] [ ] map-as '[ _ dip ] % ]
    [
        length [ <reversed> ] keep
        [ '[ _ ndrop _ nnip call ] [ ] like ] 2map , \ dispatch ,
    ] bi ;

: expand-macro ( quot -- )
    stack [ swap with-datastack >vector ] change
    stack get pop >quotation end (expand-macros) ;

: expand-macro? ( word -- quot ? )
    dup [ "transform-quot" word-prop ] [ "macro" word-prop ] bi or dup [
        swap [ "transform-n" word-prop ] [ stack-effect in>> length ] bi or
        stack get length <=
    ] [ 2drop f f ] if ;

: word, ( word -- ) end , ;

M: word expand-macros*
    dup expand-dispatch? [ drop expand-dispatch ] [
        dup expand-macro? [ nip expand-macro ] [
            drop word,
        ] if
    ] if ;

M: object expand-macros* literal ;

M: callable expand-macros*
    expand-macros literal ;

M: callable expand-macros ( quot -- quot' )
    [ begin (expand-macros) end ] [ ] make ;
