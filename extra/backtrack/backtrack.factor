! Copyright (C) 2008 William Schlieper
! See https://factorcode.org/license.txt for BSD license.

USING: assocs combinators continuations kernel math
namespaces quotations sequences summary ;

IN: backtrack

SYMBOL: failure

ERROR: amb-failure ;

M: amb-failure summary drop "Backtracking failure" ;

: fail ( -- )
    failure get [ continue ] [ amb-failure ] if* ;

: must-be-true ( ? -- )
    [ fail ] unless ;

MACRO: checkpoint ( quot -- quot' )
    '[
        failure get _ '[
            '[ failure set _ continue ] callcc0
            _ failure set @
        ] callcc0
    ] ;

: number-from ( from -- from+n )
    [ 1 + number-from ] checkpoint ;

<PRIVATE

: preserve ( quot var -- ) [ get [ call ] dip ] keep set ; inline

: amb-preserve ( quot -- ) failure preserve ; inline

: unsafe-number-from-to ( to from -- to from+n )
    2dup = [ [ 1 + unsafe-number-from-to ] checkpoint ] unless ;

: number-from-to ( to from -- to from+n )
    2dup < [ fail ] when unsafe-number-from-to ;

: amb-integer ( seq -- int )
    length 1 - 0 number-from-to nip ;

MACRO: unsafe-amb ( seq -- quot )
    dup length 1 = [
        first 1quotation
    ] [
        unclip swap '[ _ [ drop _ unsafe-amb ] checkpoint ]
    ] if ;

PRIVATE>

: amb-lazy ( seq -- elt )
    [ amb-integer ] [ nth ] bi ;

: amb ( seq -- elt )
    [ fail f ] [ unsafe-amb ] if-empty ; inline

MACRO: amb-execute ( seq -- quot )
    [ length 1 - ] [ <enumerated> [ 1quotation ] assoc-map ] bi
    '[ _ 0 unsafe-number-from-to nip _ case ] ;

: if-amb ( true false -- ? )
    [
        [ { t f } amb ]
        [ '[ @ must-be-true t ] ]
        [ '[ @ f ] ]
        tri* if
    ] amb-preserve ; inline

: cut-amb ( -- )
    f failure set ;

: amb-all ( quot -- )
    [ { t f } amb [ call fail ] [ drop ] if ] amb-preserve ; inline

: bag-of ( quot -- seq )
    V{ } clone [ '[ @ _ push ] amb-all ] keep ; inline
