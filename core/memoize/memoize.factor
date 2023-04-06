! Copyright (C) 2007, 2010 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs definitions effects hashtables
kernel kernel.private math sequences sequences.private words ;
IN: memoize

<PRIVATE

! We can't use n*quot, narray and firstn from generalizations because
! they're macros, and macros use memoize!
: (n*quot) ( n quot -- quotquot )
    <repetition> [ ] concat-as ;

: [nsequence] ( length exemplar -- quot )
    [ [ [ 1 - ] keep ] dip '[ _ _ _ new-sequence ] ]
    [ drop [ [ set-nth-unsafe ] 2keep [ 1 - ] dip ] (n*quot) ] 2bi
    [ nip ] 3append ;

: [firstn] ( length -- quot )
    [ 0 swap ] swap
    [ [ nth-unsafe ] 2keep [ 1 + ] dip ] (n*quot)
    [ 2drop ] 3append ;

: packer ( seq -- quot )
    length dup 4 <=
    [ { [ f ] [ ] [ 2array ] [ 3array ] [ 4array ] } nth ]
    [ { } [nsequence] ] if ;

: unpacker ( seq -- quot )
    length dup dup 4 <=
    [ { [ drop ] [ ] [ first2-unsafe ] [ first3-unsafe ] [ first4-unsafe ] } nth ]
    [ [firstn] ] if swap 1 >
    [ [ { array } declare ] prepose ] when ;

: pack/unpack ( quot effect -- newquot )
    [ in>> packer ] [ out>> unpacker ] bi surround ;

: unpack/pack ( quot effect -- newquot )
    [ in>> unpacker ] [ out>> packer ] bi surround ;

: make/n ( table quot effect -- quot )
    [ unpack/pack '[ _ _ cache ] ] keep pack/unpack ;

: make/0 ( table quot effect -- quot )
    out>> [
        packer '[
            _ dup first-unsafe [ second-unsafe ] [
                @ @ [
                    1 pick set-nth-unsafe t 0 rot set-nth-unsafe
                ] keep
            ] if
        ]
    ] keep unpacker compose ;

: make-memoizer ( table quot effect -- quot )
    dup in>> length zero? [ make/0 ] [ make/n ] if ;

PRIVATE>

: (define-memoized) ( word quot effect hashtable -- )
    [ [ drop "memo-quot" set-word-prop ] ] dip
    '[ 2drop _ "memoize" set-word-prop ]
    [ [ [ dup "memoize" word-prop ] 2dip make-memoizer ] keep define-declared ]
    3tri ;

: define-memoized ( word quot effect -- )
    dup in>> length zero? [ f f 2array ] [ H{ } clone ] if
    (define-memoized) ;

: define-identity-memoized ( word quot effect -- )
    dup in>> length zero? [ f f 2array ] [ IH{ } clone ] if
    (define-memoized) ;

PREDICATE: memoized < word "memoize" word-prop >boolean ;

M: memoized definer
    def>> 3 from-tail swap ?nth hashtable?
    \ MEMO: \ IDENTITY-MEMO: ? \ ; ;

M: memoized definition "memo-quot" word-prop ;

M: memoized reset-word
    [ call-next-method ]
    [ { "memoize" "memo-quot" } remove-word-props ]
    bi ;

: memoize-quot ( quot effect -- memo-quot )
    dup in>> length zero? [ f f 2array ] [ H{ } clone ] if
    -rot make-memoizer ;

: reset-memoized ( word -- )
    "memoize" word-prop dup sequence?
    [ f swap set-first ] [ clear-assoc ] if ;

: invalidate-memoized ( inputs... word -- )
    [ stack-effect in>> packer call ]
    [
        "memoize" word-prop dup sequence?
        [ f swap set-first ] [ delete-at ] if
    ]
    bi ;

\ invalidate-memoized t "no-compile" set-word-prop
