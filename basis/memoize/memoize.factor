! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel hashtables sequences arrays words namespaces make
parser math assocs effects definitions quotations summary
accessors fry ;
IN: memoize

<PRIVATE

! We can't use n*quot, narray and firstn from generalizations because
! they're macros, and macros use memoize!
: (n*quot) ( n quot -- quotquot )
    <repetition> concat >quotation ;

: [narray] ( length -- quot )
    [ [ 1 - ] keep '[ _ _ f <array> ] ]
    [ [ [ set-nth ] 2keep [ 1 - ] dip ] (n*quot) ] bi
    [ nip ] 3append ; 

: [firstn] ( length -- quot )
    [ 0 swap ] swap
    [ [ nth ] 2keep [ 1 + ] dip ] (n*quot)
    [ 2drop ] 3append ;

: packer ( seq -- quot )
    length dup 4 <=
    [ { [ f ] [ ] [ 2array ] [ 3array ] [ 4array ] } nth ]
    [ [narray] ] if ;

: unpacker ( seq -- quot )
    length dup 4 <=
    [ { [ drop ] [ ] [ first2 ] [ first3 ] [ first4 ] } nth ]
    [ [firstn] ] if ;

: pack/unpack ( quot effect -- newquot )
    [ in>> packer ] [ out>> unpacker ] bi surround ;

: unpack/pack ( quot effect -- newquot )
    [ in>> unpacker ] [ out>> packer ] bi surround ;

: make-memoizer ( table quot effect -- quot )
    [ unpack/pack '[ _ _ cache ] ] keep
    pack/unpack ;

PRIVATE>

: define-memoized ( word quot effect -- )
    [ drop "memo-quot" set-word-prop ]
    [ 2drop H{ } clone "memoize" set-word-prop ]
    [ [ [ dup "memoize" word-prop ] 2dip make-memoizer ] keep define-declared ]
    3tri ;

SYNTAX: MEMO: (:) define-memoized ;

PREDICATE: memoized < word "memoize" word-prop ;

M: memoized definer drop \ MEMO: \ ; ;

M: memoized definition "memo-quot" word-prop ;

M: memoized reset-word
    [ call-next-method ]
    [ { "memoize" "memo-quot" } reset-props ]
    bi ;

: memoize-quot ( quot effect -- memo-quot )
    [ H{ } clone ] 2dip make-memoizer ;

: reset-memoized ( word -- )
    "memoize" word-prop clear-assoc ;

: invalidate-memoized ( inputs... word -- )
    [ stack-effect in>> packer call ] [ "memoize" word-prop delete-at ] bi ;

\ invalidate-memoized t "no-compile" set-word-prop
