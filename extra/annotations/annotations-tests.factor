USING: annotations math sorting tools.test ;
IN: annotations.tests

: three ( -- x )
    !BROKEN find a dictionary
    "threa" ;

: four ( -- x )
    !BROKEN this code is broken
    2 2 + 1+ ;

: five ( -- x )
    !TODO return 5
    f ;

[ { four three } ] [ BROKENs natural-sort ] unit-test
[ { five } ] [ TODOs ] unit-test
