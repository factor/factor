! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel hashtables sequences arrays words namespaces make
parser math assocs effects definitions quotations summary
accessors fry ;
IN: memoize

ERROR: too-many-arguments ;

M: too-many-arguments summary
    drop "There must be no more than 4 input and 4 output arguments" ;

<PRIVATE

: packer ( seq -- quot )
    length { [ f ] [ ] [ 2array ] [ 3array ] [ 4array ] } nth ;

: unpacker ( seq -- quot )
    length { [ drop ] [ ] [ first2 ] [ first3 ] [ first4 ] } nth ;

: pack/unpack ( quot effect -- newquot )
    [ in>> packer ] [ out>> unpacker ] bi surround ;

: unpack/pack ( quot effect -- newquot )
    [ in>> unpacker ] [ out>> packer ] bi surround ;

: check-memoized ( effect -- )
    [ in>> ] [ out>> ] bi [ length 4 > ] either? [ too-many-arguments ] when ;

: make-memoizer ( table quot effect -- quot )
    [ check-memoized ] keep
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