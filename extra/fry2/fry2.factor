! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit combinators.smart fry generalizations
kernel lexer make math math.order multiline namespaces parser
prettyprint quotations sequences sequences.deep
sequences.private sets sorting.slots splitting
splitting.monotonic strings.parser ;
IN: fry2

MACRO: nswapd ( ndown1 ndown2 dip -- quot )
    [ 2dup < [ swap ] when
    [ [ - ] keep ] [  ] 2bi ] dip
    '[ [ _ _  -nrotd _ _ nrotd ] _ ndip ] ;



TUPLE: local name mutable? ;

: <local> ( name -- local )
    local new
        swap "!" ?tail
        [ >>name ] dip
        [ >>mutable? ] when* ; inline

TUPLE: fry-quot seq ;
INSTANCE: fry-quot immutable-sequence

: <fry-quot> ( seq -- fry-quot )
    fry-quot new
        swap >>seq ; inline

M: fry-quot length seq>> length ;
M: fry-quot nth-unsafe seq>> nth-unsafe ;

: find-locals ( seq -- hash )
    [ local? ] deep-filter members
    { { name>> >=< } } sort-by zip-index reverse ;

DEFER: fry2
DEFER: fry3
<<
SYNTAX: FRY[ parse-quotation <fry-quot> fry >quotation append! ;
SYNTAX: FRY2[ parse-quotation <fry-quot> fry2 append! ;
! SYNTAX: LFRY[ parse-quotation <fry-quot> fry3 append! ;
SYNTAX: L" lexer get skip-blank parse-string <local> suffix! ;
>>

: split-fry ( quot -- seq )
    [
        [ { _ @ } member? ] bi@
        2array { { t f } { f f } } member?
    ] monotonic-split ;

: trim-fry ( seq -- quot )
    [
        dup ?first \ _ = [
            unclip drop >quotation '[ _ curry ]
        ] [
            dup ?first \ @ = [
                unclip drop >quotation '[ B _ compose ] ! B '[ call @ ]
            ] [
               ! B
            ] if
        ] if
    ] map [ >quotation ] map dup .

    '[ [ _ spread ] [ ] output>sequence concat ] ; inline

: fry2 ( quot -- quot' ) split-fry trim-fry ; inline

DEFER: convert-locals

! : fry3 ( quot -- quot' )
!     [ find-locals ] keep
!     [ convert-locals call ] keep
!     [ dup local? [ drop \ _ ] when ] map split-fry trim-fry ; inline

:: convert-locals ( locals quot -- quot' )
    locals assoc-size :> size
    [
        size quot [
            {
                { [ dup \ _ = ] [ drop 1 - [ ] , ] }
                ! { [ dup \ @ = ] [ drop "omg" throw 1 - [ ] , ] }
                { [ dup local? ] [
                    [ locals at dup size swap - swap [ + ] dip '[ 1 _ _ mntuckd ] , ] keepd
                ] }
                ! { [ dup fry-quot? ] [
                !     B
                !     ! size '[ _ 1 1 noverd ] ,
                !     ! [ locals ] dip  '[ _ _ convert-locals fry ] ,
                !     [ locals ] dip convert-locals fry '[ _ ] , ! fry ,
                !     ! size '[ _ ndrop ] ,
                ! ] }
                [ drop ]
            } cond
        ] each drop
        size '[ _ ndrop ] ,
    ] [ ] make concat ; inline
