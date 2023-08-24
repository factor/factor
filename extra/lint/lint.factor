! Copyright (C) 2007, 2008, 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras classes
classes.tuple.private combinators.short-circuit continuations io
kernel kernel.private locals.backend make math math.private
namespaces prettyprint quotations sequences sequences.deep
shuffle slots.private splitting stack-checker vocabs words
words.alias ;
IN: lint

<PRIVATE

CONSTANT: manual-substitutions
    H{
        { -rot [ swap [ swap ] dip ] }
        { -rot [ swap swapd ] }
        { rot [ [ swap ] dip swap ] }
        { rot [ swapd swap ] }
        { over [ dup swap ] }
        { swapd [ [ swap ] dip ] }
        { dupd [ [ dup ] dip ] }
        { 2dup [ over over ] }
        { 2swap [ -roll -roll ] }
        { 2nip [ nip nip ] }
        { 3nip [ 2nip nip ] }
        { 4nip [ 3nip nip ] }
        { 2drop [ drop drop ] }
        { 3drop [ drop drop drop ] }
        { 4drop [ drop drop drop drop ] }
        { pop* [ pop drop ] }
        { when [ [ ] if ] }
        { spin [ swap rot ] }
        { >boolean [ f = not ] }
        { keep [ over [ call ] dip ] }
    }

CONSTANT: trivial-defs
    {
        [ ">" write ] [ "/>" write ] [ " " write ]
        [ 0 or + ]
        [ dup length <iota> ]
        [ 0 swap copy ]
        [ dup length ]
        [ 0 swap ]
        [ 2dup = ] [ 2dup eq? ]
        [ = not ] [ eq? not ]
        [ boa throw ]
        [ with each ] [ with map ]
        [ curry filter ]
        [ compose compose ]
        [ empty? ] [ empty? not ]
        [ dup empty? ] [ dup empty? not ]
        [ 2dup both-fixnums? ]
        [ [ drop ] prepose ]
        [ 1 0 ? ]
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
        [ length 1 <= ]

        ! Remove trivial defs
        [ trivial-defs member? ]

        ! Remove curry only defs
        [ [ \ curry = ] all? ]

        ! Remove words with locals
        [ [ \ load-locals = ] any? ]

        ! Remove stuff with wrappers
        [ [ wrapper? ] any? ]

        ! Remove trivial math
        [ [ { [ number? ] [ { + - / * /i /f >integer } member? ] } 1|| ] all? ]

        ! Remove more trival defs
        [
            {
                [ length 2 = ]
                [ first2 [ word? ] either? ]
                [ first2 [ { dip dup over swap drop } member? ] either? ]
            } 1&&
        ]

        ! Remove [ V{ } clone ] and related
        [
            {
                [ length 2 = ]
                [ first { [ sequence? ] [ assoc? ] } 1|| ]
                [ second { clone clone-like like assoc-like make } member? ]
            } 1&&
        ]

        ! Remove [ foo get ] and related
        [
            {
                [ length 2 = ]
                [ first word? ]
                [ second { get get-global , % } member? ]
            } 1&&
        ]

        ! Remove [ first second ] and related
        [
            {
                [ length 2 = ]
                [ first { first second third } member? ]
                [ second { first second third } member? ]
            } 1&&
        ]

        ! Remove [ [ trivial ] if ] and related
        [
            {
                [ length 2 = ]
                [ first { [ quotation? ] [ ignore-def? ] } 1&& ]
                [ second { if if* unless unless* when when* curry } member? ]
            } 1&&
        ]

        ! Remove [ n - ] and related
        [
            {
                [ length 2 = ]
                [ first { [ number? ] [ boolean? ] } 1|| ]
                [ second { + - / * < <= = >= > shift bitand bitor bitxor eq? } member? ]
            } 1&&
        ]

        ! Remove [ dup 0 > ] and related
        [
            {
                [ length 3 = ]
                [ first { dup over } member? ]
                [ second number? ]
                [ third { + - / * < <= = >= > } member? ]
            } 1&&
        ]

        ! Remove [ drop f f ] and related
        [
            {
                [ length 4 <= ]
                [ first { drop 2drop 3drop nip 2nip 3nip 4nip } member? ]
                [ rest-slice [ boolean? ] all? ]
            } 1&&
        ]

        ! Remove [ length 1 = ] and related
        [
            {
                [ length 3 = ]
                [ first \ length = ]
                [ second number? ]
                [ third { + - / * < <= = >= > } member? ]
            } 1&&
        ]

        ! Remove [ dup length 1 = ] and related
        [
            {
                [ length 4 = ]
                [ first { dup over } member? ]
                [ second \ length = ]
                [ third number? ]
                [ fourth { + - / * < <= = >= > } member? ]
            } 1&&
        ]

        ! Remove numbers/t/f only defs
        [
            [ { [ number? ] [ boolean? ] } 1|| ] all?
        ]

        ! Remove [ tag n eq? ]
        [
            {
                [ length 3 = ]
                [ first \ tag = ] [ second number? ] [ third \ eq? = ]
            } 1&&
        ]

        ! Remove [ { foo } declare class-of ]
        [
            {
                [ length 3 = ]
                [ first { [ array? ] [ length 1 = ] } 1&& ]
                [ second \ declare = ]
                [ third \ class-of = ]
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
    [ { [ callable? ] [ ignore-def? not ] } 1&& ] deep-filter ;

: (load-definitions) ( word def hash -- )
    [ all-callables ] dip push-at-each ;

: load-definitions ( words -- hash )
    H{ } clone [ '[ dup def>> _ (load-definitions) ] each ] keep ;

SYMBOL: lint-definitions
SYMBOL: lint-definitions-keys

: reload-definitions ( -- )
    ! Load lintable and non-ignored definitions
    lintable-words load-definitions

    ! Remove words that are their own definition
    [ [ [ def>> ] [ 1quotation ] bi = ] reject ] assoc-map

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
    lint-definitions-keys get-global [ subseq-of? ] with filter ;

M: word lint ( word -- seq/f )
    def>> [ callable? ] deep-filter [ lint ] map concat ;

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
    [ lint ] zip-with trim-self
    [ second empty? ] reject filter-symbols ;

M: word run-lint ( word -- seq ) 1array run-lint ;

PRIVATE>

: find-swap/swap ( word -- ? )
    def>> [ callable? ] deep-filter
    [
        {
            [ [ \ swap = ] count 2 >= ]
            [
                { swap } split rest but-last
                [ [ infer ] [ 2drop ( -- ) ] recover ( x -- x ) = ] any?
            ]
        } 1&&
    ] any? ;

: find-redundant-word-props ( -- seq )
    all-words [
        {
            [ { [ foldable? ] [ flushable? ] } 1|| ]
            [ inline? ]
        } 1&&
    ] filter ;

: lint-all ( -- seq )
    all-words run-lint dup lint. ;

: lint-vocab ( vocab -- seq )
    vocab-words run-lint dup lint. ;

: lint-vocabs ( prefix -- seq )
    [ loaded-vocab-names ] dip [ head? ] curry filter [ lint-vocab ] map ;

: lint-word ( word -- seq )
    1array run-lint dup lint. ;

reload-definitions
