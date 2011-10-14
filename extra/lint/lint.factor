! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays assocs combinators.short-circuit
fry hashtables io kernel math namespaces prettyprint quotations
sequences sequences.deep shuffle slots.private vectors vocabs
words xml.data words.alias ;
IN: lint

SYMBOL: lint-definitions
SYMBOL: lint-definitions-keys

: set-hash-vector ( val key hash -- )
    2dup at -rot [ ?push ] 2dip set-at ;

: manual-substitutions ( hash -- )
    {
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
    } swap '[ first2 _ set-hash-vector ] each ;

CONSTANT: trivial-defs
    {
        [ drop ] [ 2drop ] [ 2array ]
        [ bitand ]
        [ . ]
        [ new ]
        [ get ]
        [ "" ]
        [ t ] [ f ]
        [ { } ]
        [ drop t ] [ drop f ] [ 2drop t ] [ 2drop f ]
        [ cdecl ]
        [ first ] [ second ] [ third ] [ fourth ]
        [ ">" write ] [ "/>" write ]
    }

! ! Add definitions
H{ } clone lint-definitions set-global

all-words [
    dup def>> dup callable?
    [ lint-definitions get-global set-hash-vector ] [ drop ] if
] each

! ! Remove definitions

! Remove empty word defs
lint-definitions get-global [ drop empty? not ] assoc-filter

! Remove constants [ 1 ]
[ drop { [ length 1 = ] [ first number? ] } 1&& not ] assoc-filter

! Remove words that are their own definition
[ [ [ def>> ] [ 1quotation ] bi = not ] filter ] assoc-map

! Remove specialized*
 [ nip [ vocabulary>> "specialized-" head? ] any? not ] assoc-filter

 [ nip [ vocabulary>> "windows.messages" = ] any? not ] assoc-filter

 [ nip [ alias? ] any? not ] assoc-filter

! Remove trivial defs
[ drop trivial-defs member? not ] assoc-filter

! Remove numbers only defs
[ drop [ number? ] all? not ] assoc-filter

! Remove curry only defs
[ drop [ \ curry = ] all? not ] assoc-filter

! Remove tag defs
[
    drop {
            [ length 3 = ]
            [ first \ tag = ] [ second number? ] [ third \ eq? = ]
    } 1&& not
] assoc-filter

[
    drop {
        [ [ wrapper? ] deep-any? ]
        [ [ hashtable? ] deep-any? ]
    } 1|| not
] assoc-filter

! Remove n m shift defs
[
    drop dup length 3 = [
        [ first2 [ number? ] both? ]
        [ third \ shift = ] bi and not
    ] [ drop t ] if
] assoc-filter 

! Remove [ n slot ]
[
    drop dup length 2 =
    [ first2 [ number? ] [ \ slot = ] bi* and not ] [ drop t ] if
] assoc-filter

dup manual-substitutions

[ lint-definitions set-global ] [ keys lint-definitions-keys set-global ] bi

: find-duplicates ( -- seq )
    lint-definitions get-global [ nip length 1 > ] assoc-filter ;

GENERIC: lint ( obj -- seq )

M: object lint ( obj -- seq ) drop f ;

: subseq/member? ( subseq/member seq -- ? )
    { [ start ] [ member? ] } 2|| ;

M: callable lint ( quot -- seq )
    [ lint-definitions-keys get-global ] dip '[ _ subseq/member? ] filter ;

M: word lint ( word -- seq )
    def>> dup callable? [ lint ] [ drop f ] if ;

: word-path. ( word -- )
    [ vocabulary>> ] [ name>> ] bi ":" glue print ;

: 4bl ( -- ) bl bl bl bl ;

: (lint.) ( pair -- )
    first2 [ word-path. ] dip [
        [ 4bl .  "-----------------------------------" print ]
        [ lint-definitions get-global at [ 4bl word-path. ] each nl ] bi
    ] each nl nl ;

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

: lint-all ( -- seq ) all-words run-lint dup lint. ;

: lint-vocab ( vocab -- seq ) words run-lint dup lint. ;

: lint-vocabs ( prefix -- seq )
    [ vocabs ] dip [ head? ] curry filter [ lint-vocab ] map ;

: lint-word ( word -- seq ) 1array run-lint dup lint. ;
