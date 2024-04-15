USING: http.download io.encodings.utf8 io.files io.files.temp
kernel math.parser quotations sequences splitting strings
tools.test unicode ;
IN: unicode.breaks.tests

{ "\u001112\u001161\u0011abA\u000300a\r\r\n" }
[ "\r\n\raA\u000300\u001112\u001161\u0011ab" string-reverse ] unit-test
{ "dcba" } [ "abcd" string-reverse ] unit-test
{ 3 } [ "\u001112\u001161\u0011abA\u000300a"
        dup last-grapheme head last-grapheme ] unit-test

{ 3 } [ 2 "hello" first-grapheme-from ] unit-test
{ 1 } [ 2 "hello" last-grapheme-from ] unit-test

{ 4 } [ 2 "what am I saying" first-word-from ] unit-test
{ 0 } [ 2 "what am I saying" last-word-from ] unit-test
{ 16 } [ 11 "what am I saying" first-word-from ] unit-test
{ 10 } [ 11 "what am I saying" last-word-from ] unit-test

{ { t f t t f t } } [ 6 <iota> [ "as df" word-break-at? ] map ] unit-test

: grapheme-break-test ( -- filename )
    "https://downloads.factorcode.org/misc/UCD/15.1.0/auxiliary/GraphemeBreakTest.txt"
    "GraphemeBreakTest-15.1.0.txt" cache-file download-once-as ;

: word-break-test ( -- filename )
    "https://downloads.factorcode.org/misc/UCD/15.1.0/auxiliary/WordBreakTest.txt"
    "WordBreakTest-15.1.0.txt" cache-file download-once-as ;

: parse-test-file ( file-name -- tests )
    utf8 file-lines
    [ "#" split1 drop ] map harvest [
        "÷" split
        [
            "×" split
            [ [ blank? ] trim hex> ] map
            [ { f 0 } member? ] reject
            >string
        ] map
        harvest
    ] map ;

:: test-unicode-breaks ( tests quot -- )
    tests [
        [ 1quotation ]
        [ concat [ quot call [ "" like ] map ] curry ] bi unit-test
    ] each ;

! XXX: not used?
: grapheme-test ( tests -- )
    [
        [ 1quotation ]
        [ concat [ >graphemes [ "" like ] map ] curry ] bi unit-test
    ] each ;

: run-grapheme-break-tests ( -- )
    grapheme-break-test parse-test-file [ >graphemes ] test-unicode-breaks ;

: run-word-break-tests ( -- )
    word-break-test parse-test-file [ >words ] test-unicode-breaks ;
