! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test crypto.passwd-md5 ;
IN: crypto.passwd-md5.tests


{ "$1$npUpD5oQ$1.X7uXR2QG0FzPifVeZ2o1" }
[ "$1$" "npUpD5oQ" "factor" passwd-md5 ] unit-test

{ "$1$Kilak4kR$wlEr5Dv5DcdqPjKjQtt430" }
[
    "$1$"
    "Kilak4kR"
    "longpassword12345678901234567890"
    passwd-md5
] unit-test
