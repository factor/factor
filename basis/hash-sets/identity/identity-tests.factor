USING: hash-sets.identity kernel literals sets tools.test ;
IN: hash-sets.identity.tests

CONSTANT: the-real-slim-shady "marshall mathers"

CONSTANT: will
    IHS{
        $ the-real-slim-shady
        "marshall mathers"
    }

: please-stand-up ( set obj -- ? )
    swap in? ;

{ t } [ will the-real-slim-shady please-stand-up ] unit-test
{ t } [ will clone the-real-slim-shady please-stand-up ] unit-test

{ 2 } [ will cardinality ] unit-test
{ { "marshall mathers" } } [
    the-real-slim-shady will clone
    [ delete ] [ members ] bi
] unit-test

CONSTANT: same-as-it-ever-was "same as it ever was"

{ IHS{ $ same-as-it-ever-was } }
[ HS{ $ same-as-it-ever-was } IHS{ } set-like ] unit-test
