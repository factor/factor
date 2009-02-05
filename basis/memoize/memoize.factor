! Copyright (C) 2007 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel hashtables sequences arrays words namespaces make
parser math assocs effects definitions quotations summary
accessors ;
IN: memoize

: packer ( n -- quot )
    { [ f ] [ ] [ 2array ] [ 3array ] [ 4array ] } nth ;

: unpacker ( n -- quot )
    { [ drop ] [ ] [ first2 ] [ first3 ] [ first4 ] } nth ;

: #in ( word -- n )
    stack-effect in>> length ;

: #out ( word -- n )
    stack-effect out>> length ;

: pack/unpack ( quot word -- newquot )
    [ dup #in unpacker % swap % #out packer % ] [ ] make ;

: make-memoizer ( quot word -- quot )
    [
        [ #in packer % ] keep
        [ "memoize" word-prop , ] keep
        [ pack/unpack , ] keep
        \ cache ,
        #out unpacker %
    ] [ ] make ;

ERROR: too-many-arguments ;

M: too-many-arguments summary
    drop "There must be no more than 4 input and 4 output arguments" ;

: check-memoized ( word -- )
    [ #in ] [ #out ] bi [ 4 > ] either? [ too-many-arguments ] when ;

: define-memoized ( word quot -- )
    over check-memoized
    2dup "memo-quot" set-word-prop
    over H{ } clone "memoize" set-word-prop
    over make-memoizer define ;

: MEMO: (:) define-memoized ; parsing

PREDICATE: memoized < word "memoize" word-prop ;

M: memoized definer drop \ MEMO: \ ; ;

M: memoized definition "memo-quot" word-prop ;

M: memoized reset-word
    [ call-next-method ]
    [ { "memoize" "memo-quot" } reset-props ]
    bi ;

: memoize-quot ( quot effect -- memo-quot )
    gensym swap dupd "declared-effect" set-word-prop
    dup rot define-memoized 1quotation ;

: reset-memoized ( word -- )
    "memoize" word-prop clear-assoc ;

: invalidate-memoized ( inputs... word -- )
    [ #in packer call ] [ "memoize" word-prop delete-at ] bi ;
