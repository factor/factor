! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces quotations accessors words
continuations vectors effects math stack-checker.transforms ;
IN: macros.expander

GENERIC: expand-macros ( quot -- quot' )

<PRIVATE

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

: expand-macro ( quot -- )
    stack [ swap with-datastack >vector ] change
    stack get pop >quotation end (expand-macros) ;

: expand-macro? ( word -- quot ? )
    dup [ "macro" word-prop ] [ +transform-quot+ word-prop ] bi or dup [
        swap [ stack-effect in>> length ] [ +transform-n+ word-prop ] bi or
        stack get length <=
    ] [ 2drop f f ] if ;

M: word expand-macros*
    dup expand-macro? [ nip expand-macro ] [ drop end , ] if ;

M: object expand-macros* literal ;

M: callable expand-macros*
    expand-macros literal ;

M: callable expand-macros ( quot -- quot' )
    [ begin (expand-macros) end ] [ ] make ;

PRIVATE>
