! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs combinators.lib io kernel
macros math namespaces prettyprint quotations sequences
vectors vocabs words ;
USING: html.elements slots.private tar ;
IN: lint

SYMBOL: def-hash
SYMBOL: def-hash-keys

: set-hash-vector ( val key hash -- )
    2dup at -rot >r >r ?push r> r> set-at ;

: add-word-def ( word quot -- )
    dup callable? [
        def-hash get-global set-hash-vector
    ] [
        2drop
    ] if ;

: more-defs
    {
        { [ swap >r swap r> ] -rot }
        { [ swap swapd ] -rot }
        { [ >r swap r> swap ] rot }
        { [ swapd swap ] rot }
        { [ dup swap ] over }
        { [ dup -rot ] tuck }
        { [ >r swap r> ] swapd }
        { [ nip nip ] 2nip }
        { [ drop drop ] 2drop }
        { [ drop drop drop ] 3drop }
        { [ 0 = ] zero? }
        { [ pop drop ] pop* }
        { [ [ ] if ] when }
    } [ first2 swap add-word-def ] each ;

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

: trivial-defs
    {
        [ get ] [ t ] [ { } ] [ . ] [ drop f ]
        [ drop ] [ f ] [ first ] [ second ] [ third ] [ fourth ]
        [ ">" write-html ] [ <unimplemented-typeflag> throw ]
        [ "/>" write-html ]
    } ;

H{ } clone def-hash set-global
all-words [ dup word-def add-word-def ] each
more-defs

! Remove empty word defs
def-hash get-global [
    drop empty? not
] assoc-subset

! Remove constants [ 1 ]
[
    drop dup length 1 = swap first number? and not
] assoc-subset

! Remove set-alien-cell, etc.
[
    drop [ accessor-words swap seq-diff ] keep [ length ] 2apply =
] assoc-subset

! Remove trivial defs
[
    drop trivial-defs member? not
] assoc-subset

! Remove n m shift defs
[
    drop dup length 3 = [
        dup first2 [ number? ] 2apply and swap third \ shift = and not
    ] [ drop t ] if
] assoc-subset 

! Remove [ n slot ]
[
    drop dup length 2 = [
        first2 \ slot = swap number? and not
    ] [ drop t ] if
] assoc-subset def-hash set-global

: find-duplicates
    def-hash get-global [
        nip length 1 >
    ] assoc-subset ;

def-hash get-global keys def-hash-keys set-global

GENERIC: lint ( obj -- seq )

M: object lint ( obj -- seq )
    drop f ;

: subseq/member? ( subseq/member seq -- ? )
    { [ 2dup start ] [ 2dup member? ] } || 2nip ;

M: callable lint ( quot -- seq )
    def-hash-keys get [
        swap subseq/member?
    ] curry* subset ;

M: word lint ( word -- seq )
    word-def dup callable? [ lint ] [ drop f ] if ;

: word-path. ( word -- )
    [ word-vocabulary ":" ] keep unparse 3append write nl ;

: lint. ( array -- )
    first2 >r word-path. r> [
        bl bl bl bl
        dup .
        "-----------------------------------" print
        def-hash get at [ bl bl bl bl word-path. ] each
        nl
    ] each nl nl ;
    

GENERIC: run-lint ( obj -- obj )

: trim-self ( seq -- newseq )
    [
        first2 [
            def-hash get-global at* [
                dupd remove empty? not
            ] [
                drop f
            ] if
        ] subset 2array
    ] map ;

M: sequence run-lint ( seq -- seq )
    [
        global [ dup . flush ] bind
        dup lint 2array
    ] map
    trim-self
    [ second empty? not ] subset ;

M: word run-lint ( word -- seq )
    1array run-lint ;

: lint-all ( -- seq )
    all-words run-lint dup [ lint. ] each ;

