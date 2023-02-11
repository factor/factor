! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: lcs lcs.diff2html kernel tools.test strings sequences
xml.writer ;

{ } [
    "hello" "heyo" [ [ 1string ] { } map-as ] bi@
    lcs-diff htmlize-diff xml>string drop
] unit-test
