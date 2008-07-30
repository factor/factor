USING: tools.test unicode.breaks sequences math kernel ;

[ "\u001112\u001161\u0011abA\u000300a\r\r\n" ]
[ "\r\n\raA\u000300\u001112\u001161\u0011ab" string-reverse ] unit-test
[ "dcba" ] [ "abcd" string-reverse ] unit-test
[ 3 ] [ "\u001112\u001161\u0011abA\u000300a"
        dup last-grapheme head last-grapheme ] unit-test
