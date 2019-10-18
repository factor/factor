USING: tools.test unicode.breaks sequences math kernel ;

[ "\u1112\u1161\u11abA\u0300a\r\r\n" ]
[ "\r\n\raA\u0300\u1112\u1161\u11ab" string-reverse ] unit-test
[ "dcba" ] [ "abcd" string-reverse ] unit-test
[ 3 ] [ "\u1112\u1161\u11abA\u0300a" [ length 1- ] keep
        [ prev-grapheme ] keep prev-grapheme ] unit-test
