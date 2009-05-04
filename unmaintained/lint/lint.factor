! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors arrays assocs
combinators.short-circuit fry hashtables io
kernel math namespaces prettyprint quotations sequences
sequences.deep sets slots.private vectors vocabs words
kernel.private ;
IN: lint

SYMBOL: def-hash
SYMBOL: def-hash-keys

: set-hash-vector ( val key hash -- )
    2dup at -rot [ ?push ] 2dip set-at ;

: more-defs ( hash -- )
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

: accessor-words ( -- seq )
{
    alien-signed-1 alien-signed-2 alien-signed-4 alien-signed-8
    alien-unsigned-1 alien-unsigned-2 alien-unsigned-4 alien-unsigned-8
    <displaced-alien> alien-unsigned-cell set-alien-signed-cell
    set-alien-unsigned-1 set-alien-signed-1 set-alien-unsigned-2
    set-alien-signed-2 set-alien-unsigned-4 set-alien-signed-4
    set-alien-unsigned-8 set-alien-signed-8
    alien-cell alien-signed-cell set-alien-cell set-alien-unsigned-cell
    set-alien-float alien-float
} ;

: trivial-defs ( -- seq )
    {
        [ drop ] [ 2array ]
        [ bitand ]

        [ . ]
        [ get ]
        [ t ] [ f ]
        [ { } ]
        [ drop f ]
        [ "cdecl" ]
        [ first ] [ second ] [ third ] [ fourth ]
        [ ">" write ] [ "/>" write ]
    } ;

! ! Add definitions
H{ } clone def-hash set-global

all-words [
    dup def>> dup callable?
    [ def-hash get-global set-hash-vector ] [ drop ] if
] each

! ! Remove definitions

! Remove empty word defs
def-hash get-global [ drop empty? not ] assoc-filter

! Remove constants [ 1 ]
[ drop { [ length 1 = ] [ first number? ] } 1&& not ] assoc-filter

! Remove words that are their own definition
[ [ [ def>> ] [ 1quotation ] bi = not ] filter ] assoc-map

! Remove set-alien-cell, etc.
[ drop [ accessor-words diff ] keep [ length ] bi@ = ] assoc-filter

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


dup more-defs

[ def-hash set-global ] [ keys def-hash-keys set-global ] bi

: find-duplicates ( -- seq )
    def-hash get-global [ nip length 1 > ] assoc-filter ;

GENERIC: lint ( obj -- seq )

M: object lint ( obj -- seq ) drop f ;

: subseq/member? ( subseq/member seq -- ? )
    { [ start ] [ member? ] } 2|| ;

M: callable lint ( quot -- seq )
    [ def-hash-keys get-global ] dip '[ _ subseq/member? ] filter ;

M: word lint ( word -- seq )
    def>> dup callable? [ lint ] [ drop f ] if ;

: word-path. ( word -- )
    [ vocabulary>> ] [ unparse ] bi ":" glue print ;

: 4bl ( -- ) bl bl bl bl ;

: (lint.) ( pair -- )
    first2 [ word-path. ] dip [
        [ 4bl .  "-----------------------------------" print ]
        [ def-hash get-global at [ 4bl word-path. ] each nl ] bi
    ] each nl nl ;

: lint. ( alist -- ) [ (lint.) ] each ;

GENERIC: run-lint ( obj -- obj )

: (trim-self) ( val key -- obj ? )
    def-hash get-global at*
    [ dupd remove empty? not ] [ drop f ] if ;

: trim-self ( seq -- newseq )
    [ [ (trim-self) ] filter ] assoc-map ;

: filter-symbols ( alist -- alist )
    [
        nip first dup def-hash get-global at
        [ first ] bi@ literalize = not
    ] assoc-filter ;

M: sequence run-lint ( seq -- seq )
    [ dup lint ] { } map>assoc trim-self
    [ second empty? not ] filter filter-symbols ;

M: word run-lint ( word -- seq ) 1array run-lint ;

: lint-all ( -- seq ) all-words run-lint dup lint. ;

: lint-vocab ( vocab -- seq ) words run-lint dup lint. ;

: lint-word ( word -- seq ) 1array run-lint dup lint. ;
