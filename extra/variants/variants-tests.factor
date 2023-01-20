! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math tools.test variants slots ;
IN: variants.tests

VARIANT: list
    nil
    cons: { { first object } { rest list } }
    ;

{ t } [ nil list? ] unit-test
{ t } [ 1 nil <cons> list? ] unit-test
{ f } [ 1 list? ] unit-test

: list-length ( list -- length )
    {
        { nil  [ 0 ] }
        { cons [ nip list-length 1 + ] }
    } match ;

{ 4 }
[ 5 6 7 8 nil <cons> <cons> <cons> <cons> list-length ] unit-test

{ nil t } [ list initial-value ] unit-test

VARIANT: list2 ;
VARIANT-MEMBER: list2 nil2 ;
VARIANT-MEMBER: list2 cons2: { { first object } { rest list2 } } ;

{ t } [ nil2 list2? ] unit-test
{ t } [ 1 nil2 <cons2> list2? ] unit-test
{ f } [ 1 list2? ] unit-test

: list2-length ( list2 -- length )
    {
        { nil2  [ 0 ] }
        { cons2 [ nip list2-length 1 + ] }
    } match ;

{ 4 }
[ 5 6 7 8 nil2 <cons2> <cons2> <cons2> <cons2> list2-length ] unit-test
