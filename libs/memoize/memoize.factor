! Copyright (C) 2007 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
IN: memoize
USING: kernel hashtables sequences arrays words namespaces
parser errors math assocs ;

: packer ( n -- quot )
    { [ f ] [ ] [ 2array ] [ 3array ] [ 4array ] } nth ;

: unpacker ( n -- quot )
    { [ drop ] [ ] [ first2 ] [ first3 ] [ first4 ] } nth ;

: #in ( word -- n )
    stack-effect effect-in length ;

: #out ( word -- n )
    stack-effect effect-out length ;

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

: check-memoized ( word -- )
    dup #in 4 > swap #out 4 > or [
        "There must be no more than 4 input and 4 output arguments" throw
    ] when ;

: define-memoized ( word quot -- )
    over check-memoized
    over H{ } clone "memoize" set-word-prop
    over make-memoizer define-compound ;

: MEMO:
    CREATE dup reset-generic parse-definition define-memoized ; parsing
