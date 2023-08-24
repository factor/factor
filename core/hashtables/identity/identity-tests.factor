! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs hashtables.identity kernel literals tools.test ;
IN: hashtables.identity.tests

CONSTANT: the-real-slim-shady "marshall mathers"

CONSTANT: will
    IH{
        { $ the-real-slim-shady t }
        { "marshall mathers"    f }
    }

: please-stand-up ( assoc key -- value )
    of ;

{ t } [ will the-real-slim-shady please-stand-up ] unit-test
{ t } [ will clone the-real-slim-shady please-stand-up ] unit-test

{ 2 } [ will assoc-size ] unit-test
{ { { "marshall mathers" f } } } [
    the-real-slim-shady will clone
    [ delete-at ] [ >alist ] bi
] unit-test
{ t } [
    t the-real-slim-shady identity-associate
    t the-real-slim-shady identity-associate =
] unit-test
{ f } [
    t the-real-slim-shady identity-associate
    t "marshall mathers"  identity-associate =
] unit-test

CONSTANT: same-as-it-ever-was "same as it ever was"

{ IH{ { $ same-as-it-ever-was $ same-as-it-ever-was } } }
[ H{ { $ same-as-it-ever-was $ same-as-it-ever-was } } IH{ } assoc-like ] unit-test
