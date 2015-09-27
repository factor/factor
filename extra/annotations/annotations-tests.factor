USING: accessors annotations combinators.short-circuit
io.pathnames kernel math sequences sorting tools.test ;
IN: annotations.tests

!NOTE testing toplevel form

: three ( -- x )
    !BROKEN english plz
    "þrij" ;

: four ( -- x )
    !BROKEN this code is broken
    2 2 + 1 + ;

: five ( -- x )
    !TODO return 5
    f ;

{ t } [
    NOTEs {
        [ length 1 = ]
        [ first string>> file-name "annotations-tests.factor" = ]
    } 1&&
] unit-test

{ t } [
    BROKENs { [ \ four swap member? ] [ \ three swap member? ] } 1&&
] unit-test

{ t } [ TODOs \ five swap member? ] unit-test
