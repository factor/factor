! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays assocs classes.tuple.private
combinators.short-circuit fry hashtables io kernel
locals.backend make math namespaces prettyprint quotations
sequences sequences.deep shuffle slots.private vectors vocabs
words xml.data words.alias ;
IN: lint

<PRIVATE

CONSTANT: manual-substitutions
    H{
        { -rot [ swap [ swap ] dip ] }
        { -rot [ swap swapd ] }
        { rot [ [ swap ] dip swap ] }
        { rot [ swapd swap ] }
        { over [ dup swap ] }
        { tuck [ dup -rot ] }
        { swapd [ [ swap ] dip ] }
        { 2nip [ nip nip ] }
        { 2drop [ drop drop ] }
        { 3drop [ drop drop drop ] }
        { pop* [ pop drop ] }
        { when [ [ ] if ] }
        { >boolean [ f = not ] }
    }

CONSTANT: trivial-defs
    {
        [ drop t ] [ drop f ]
        [ 2drop t ] [ 2drop f ]
        [ 3drop t ] [ 3drop f ]
        [ ">" write ] [ "/>" write ]
        [ length 1 - ] [ length 1 = ] [ length 1 > ]
        [ drop f f ] [ 2drop f f ]
        [ drop f f f ]
        [ nip f f ]
        [ 0 or + ]
        [ dup 0 > ] [ dup 0 <= ]
        [ dup length iota ]
        [ 0 swap copy ]
        [ dup 1 + ]
    }

: lintable-word? ( word -- ? )
    {
        [ vocabulary>> "specialized-" head? ]
        [ vocabulary>> "windows-messages" = ]
        [ alias? ]
    } 1|| not ;

: lintable-words ( -- words )
    all-words [ lintable-word? ] filter ;

: ignore-def? ( def -- ? )
    {
        ! Remove small defs
        [ length 2 <= ]

        ! Remove trivial defs
        [ trivial-defs member? ]

        ! Remove curry only defs
        [ [ \ curry = ] all? ]

        ! Remove words with locals
        [ [ \ load-locals = ] any? ]

        ! Remove numbers/t/f only defs
        [
            [ { [ number? ] [ t? ] [ f eq? ] } 1|| ] all?
        ]

        ! Remove tag defs
        [
            {
                [ length 3 = ]
                [ first \ tag = ] [ second number? ] [ third \ eq? = ]
            } 1&&
        ]

        ! Remove [ m n shift ]
        [
            {
                [ length 3 = ]
                [ first2 [ number? ] both? ] [ third \ shift = ]
            } 1&&
        ]

        ! Remove [ layout-of n slot ]
        [
            {
                [ length 3 = ]
                [ first \ layout-of = ]
                [ second number? ]
                [ third \ slot = ]
            } 1&&
        ]
    } 1|| ;

: all-callables ( def -- seq )
    [ callable? ] deep-filter ;

: (load-definitions) ( word def hash -- )
    [ all-callables ] dip '[ _ push-at ] with each ;

: load-definitions ( words -- hash )
    H{ } clone [ '[ dup def>> _ (load-definitions) ] each ] keep ;

SYMBOL: lint-definitions
SYMBOL: lint-definitions-keys

: reload-definitions ( -- )
    ! Load lintable and non-ignored definitions
    lintable-words load-definitions
    [ drop ignore-def? not ] assoc-filter

    ! Remove words that are their own definition
    [ [ [ def>> ] [ 1quotation ] bi = not ] filter ] assoc-map

    ! Add manual definitions
    manual-substitutions over '[ _ push-at ] assoc-each

    ! Set globals to new values
    [ lint-definitions set-global ]
    [ keys lint-definitions-keys set-global ] bi ;

: find-duplicates ( -- seq )
    lint-definitions get-global [ nip length 1 > ] assoc-filter ;

GENERIC: lint ( obj -- seq )

M: object lint ( obj -- seq ) drop f ;

M: callable lint ( quot -- seq )
    [ lint-definitions-keys get-global ] dip '[ _ subseq? ] filter ;

M: word lint ( word -- seq/f )
    def>> all-callables [ lint ] map concat ;

: word-path. ( word -- )
    [ vocabulary>> write ":" write ] [ . ] bi ;

: 4bl ( -- ) bl bl bl bl ;

: (lint.) ( pair -- )
    first2 [ word-path. ] dip [
        [ 4bl .  "-----------------------------------" print ]
        [ lint-definitions get-global at [ 4bl word-path. ] each nl ] bi
    ] each nl ;

: lint. ( alist -- ) [ (lint.) ] each ;

GENERIC: run-lint ( obj -- obj )

: (trim-self) ( val key -- obj ? )
    lint-definitions get-global at*
    [ dupd remove empty? not ] [ drop f ] if ;

: trim-self ( seq -- newseq )
    [ [ (trim-self) ] filter ] assoc-map ;

: filter-symbols ( alist -- alist )
    [
        nip first dup lint-definitions get-global at
        [ first ] bi@ literalize = not
    ] assoc-filter ;

M: sequence run-lint ( seq -- seq )
    [ dup lint ] { } map>assoc trim-self
    [ second empty? not ] filter filter-symbols ;

M: word run-lint ( word -- seq ) 1array run-lint ;

PRIVATE>

: lint-all ( -- seq )
    all-words run-lint dup lint. ;

: lint-vocab ( vocab -- seq )
    words run-lint dup lint. ;

: lint-vocabs ( prefix -- seq )
    [ vocabs ] dip [ head? ] curry filter [ lint-vocab ] map ;

: lint-word ( word -- seq )
    1array run-lint dup lint. ;

reload-definitions
