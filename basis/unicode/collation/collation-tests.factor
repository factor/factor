USING: arrays assocs fry grouping io io.encodings.utf8 io.files
io.streams.null kernel math math.order math.parser multiline
random sequences splitting strings tools.test unicode words ;
IN: unicode.collation.tests

: test-equality ( str1 str2 -- ? ? ? ? )
    { primary= secondary= tertiary= quaternary= }
    [ execute( a b -- ? ) ] 2with map
    first4 ;

{ f f f f } [ "hello" "hi" test-equality ] unit-test
{ t f f f } [ "hello" "h\u0000e9llo" test-equality ] unit-test
{ t t f f } [ "hello" "HELLO" test-equality ] unit-test
{ t t t f } [ "hello" "h e l l o." test-equality ] unit-test
{ t t t t } [ "hello" "\0hello\0" test-equality ] unit-test
{ { "good bye" "goodbye" "hello" "HELLO" } }
[ { "HELLO" "goodbye" "good bye" "hello" } sort-strings ] unit-test

: parse-collation-test-shifted ( -- lines )
    "vocab:unicode/UCA/CollationTest/CollationTest_SHIFTED.txt" utf8 file-lines
    [ "#@" split first ] map harvest
    [ ";" split first ] map
    [ " " split [ hex> ] "" map-as ] map ;

: tail-from-last ( string char -- string' )
    '[ _ = ] dupd find-last drop 1 + tail ; inline

: line>test-weights ( string -- pair )
    ";" split1 [
        " " split [ hex> ] map
    ] [
        "#" split1 nip ch'\[ tail-from-last
        "]" split1 drop
        "|" split 4 head
        [ " " split harvest [ hex> ] map ] map
    ] bi* 2array ;

: parse-collation-test-weights ( -- weights )
    "vocab:unicode/UCA/CollationTest/CollationTest_SHIFTED.txt" utf8 file-lines
    [ "#" head? ] reject harvest
    [ line>test-weights ] map ;

: calculate-collation ( chars collation -- collation-calculated collation-answer )
    [ >string collation-key/nfd drop ] [ { 0 } join ] bi* ;

: find-bad-collations ( pairs -- seq )
    [ first2 dupd calculate-collation 3array ] map
    [ first3 sequence= nip ] reject ;

{ 208026 { } }
[ parse-collation-test-weights [ length ] [ find-bad-collations ] bi ] unit-test

{ 208025 { } } [
    parse-collation-test-shifted
    2 clump [ length ] keep
    [ string<=> { +lt+ +eq+ } member? ] assoc-reject
] unit-test




![[
{ +lt+ } [ { 8194 33 } { 8193 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8194 63 } { 8193 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8189 33 } { 900 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8189 63 } { 900 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8173 820 } { 168 769 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8174 820 } { 168 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8173 33 } { 901 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8174 33 } { 8129 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8173 63 } { 901 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8174 63 } { 8129 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8141 820 } { 8127 769 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8142 820 } { 8127 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8190 820 } { 8158 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8190 820 } { 8159 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8190 33 } { 8157 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8190 63 } { 8157 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8656 33 } { 8653 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8656 63 } { 8653 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8658 33 } { 8655 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8658 63 } { 8655 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8660 33 } { 8654 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8660 63 } { 8654 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8800 33 } { 8316 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8800 63 } { 8316 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 10973 33 } { 10972 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 10973 63 } { 10972 63 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119135 820 } { 119128 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119136 820 } { 119128 119141 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119137 820 } { 119128 119141 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119138 820 } { 119128 119141 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119139 820 } { 119128 119141 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119227 820 } { 119225 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119229 820 } { 119225 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119228 820 } { 119226 119141 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119230 820 } { 119226 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1425 820 } { 820 1426 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1426 820 } { 820 1427 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1427 820 } { 820 1428 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1428 820 } { 820 1429 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1429 820 } { 820 1430 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1430 820 } { 820 1431 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1431 820 } { 820 1432 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1432 820 } { 820 1433 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1433 820 } { 820 1434 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1434 820 } { 820 1435 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1435 820 } { 820 1436 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1436 820 } { 820 1437 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1437 820 } { 820 1438 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1438 820 } { 820 1439 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1439 820 } { 820 1440 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1440 820 } { 820 1441 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1441 820 } { 820 1442 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1442 820 } { 820 1443 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1443 820 } { 820 1444 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1444 820 } { 820 1445 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1445 820 } { 820 1446 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1446 820 } { 820 1447 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1447 820 } { 820 1448 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1448 820 } { 820 1449 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1449 820 } { 820 1450 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1450 820 } { 820 1451 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1451 820 } { 820 1452 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1452 820 } { 820 1453 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1453 820 } { 820 1454 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1454 820 } { 820 1455 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1455 820 } { 820 1469 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1469 820 } { 820 1476 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1476 820 } { 820 1477 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1477 820 } { 820 1552 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1552 820 } { 820 1553 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1553 820 } { 820 1554 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1554 820 } { 820 1555 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1555 820 } { 820 1556 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1556 820 } { 820 1557 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1557 820 } { 820 1558 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1558 820 } { 820 1559 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1559 820 } { 820 1560 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1560 820 } { 820 1561 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1561 820 } { 820 1562 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1562 820 } { 820 1750 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1750 820 } { 820 1751 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1751 820 } { 820 1752 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1752 820 } { 820 1753 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1753 820 } { 820 1754 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1754 820 } { 820 1755 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1755 820 } { 820 1756 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1756 820 } { 820 1759 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1759 820 } { 820 1760 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1760 820 } { 820 1761 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1761 820 } { 820 1762 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1762 820 } { 820 1763 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1763 820 } { 820 1764 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1764 820 } { 820 1767 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1767 820 } { 820 1768 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1768 820 } { 820 1770 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1770 820 } { 820 1771 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1771 820 } { 820 1772 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1772 820 } { 820 1773 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1773 820 } { 820 1856 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1856 820 } { 820 1859 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1859 820 } { 820 1860 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1860 820 } { 820 1863 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1863 820 } { 820 1864 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1864 820 } { 820 1865 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1865 820 } { 820 1866 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2273 820 } { 820 2282 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2282 820 } { 820 2283 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2283 820 } { 820 2284 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2284 820 } { 820 2285 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2285 820 } { 820 2286 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2286 820 } { 820 2287 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2287 820 } { 820 2291 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2291 820 } { 820 2385 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2385 820 } { 820 2386 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2386 820 } { 820 3864 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3864 820 } { 820 3865 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3865 820 } { 820 3893 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3893 820 } { 820 3895 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3895 820 } { 820 3970 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3970 820 } { 820 3971 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3971 820 } { 820 3974 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3974 820 } { 820 3975 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3975 820 } { 820 4038 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4038 820 } { 820 6783 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6783 820 } { 820 7019 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7019 820 } { 820 7020 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7020 820 } { 820 7021 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7021 820 } { 820 7022 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7022 820 } { 820 7023 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7023 820 } { 820 7024 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7024 820 } { 820 7025 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7025 820 } { 820 7026 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7026 820 } { 820 7027 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7027 820 } { 820 7376 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7376 820 } { 820 7377 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7377 820 } { 820 7378 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7378 820 } { 820 7381 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7381 820 } { 820 7382 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7382 820 } { 820 7383 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7383 820 } { 820 7384 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7384 820 } { 820 7385 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7385 820 } { 820 7386 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7386 820 } { 820 7387 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7387 820 } { 820 7388 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7388 820 } { 820 7389 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7389 820 } { 820 7390 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7390 820 } { 820 7391 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7391 820 } { 820 7392 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7392 820 } { 820 7412 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7412 820 } { 820 7416 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7416 820 } { 820 7417 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7417 820 } { 820 11647 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 11647 820 } { 820 43232 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43232 820 } { 820 43233 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43233 820 } { 820 43234 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43234 820 } { 820 43235 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43235 820 } { 820 43236 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43236 820 } { 820 43237 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43237 820 } { 820 43238 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43238 820 } { 820 43239 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43239 820 } { 820 43240 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43240 820 } { 820 43241 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43241 820 } { 820 43242 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43242 820 } { 820 43243 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43243 820 } { 820 43244 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43244 820 } { 820 43245 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43245 820 } { 820 43246 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43246 820 } { 820 43247 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43247 820 } { 820 43248 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43248 820 } { 820 43249 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43249 820 } { 820 65057 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65057 820 } { 820 65059 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65059 820 } { 820 65060 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65060 820 } { 820 65061 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65061 820 } { 820 65062 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65062 820 } { 820 65064 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65064 820 } { 820 65066 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65066 820 } { 820 65067 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65067 820 } { 820 65068 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65068 820 } { 820 65069 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65069 820 } { 820 65071 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65071 820 } { 820 66272 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 66272 820 } { 820 70502 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70502 820 } { 820 70503 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70503 820 } { 820 70504 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70504 820 } { 820 70505 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70505 820 } { 820 70506 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70506 820 } { 820 70507 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70507 820 } { 820 70508 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70508 820 } { 820 70512 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70512 820 } { 820 70513 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70513 820 } { 820 70514 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70514 820 } { 820 70515 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70515 820 } { 820 70516 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70516 820 } { 820 119141 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119141 820 } { 820 119142 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119142 820 } { 820 119149 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119149 820 } { 820 119150 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119150 820 } { 820 119151 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119151 820 } { 820 119152 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119152 820 } { 820 119153 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119153 820 } { 820 119154 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119154 820 } { 820 119163 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119163 820 } { 820 119164 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119164 820 } { 820 119165 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119165 820 } { 820 119166 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119166 820 } { 820 119167 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119167 820 } { 820 119168 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119168 820 } { 820 119169 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119169 820 } { 820 119170 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119170 820 } { 820 119173 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119173 820 } { 820 119174 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119174 820 } { 820 119175 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119175 820 } { 820 119176 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119176 820 } { 820 119177 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119177 820 } { 820 119178 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119178 820 } { 820 119179 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119179 820 } { 820 119210 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119210 820 } { 820 119211 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119211 820 } { 820 119212 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119212 820 } { 820 119213 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119213 820 } { 820 119362 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119362 820 } { 820 119363 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119363 820 } { 820 119364 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 119364 820 } { 820 125136 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 125136 820 } { 820 125137 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 125137 820 } { 820 125138 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 125138 820 } { 820 125139 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 125139 820 } { 820 125140 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 125140 820 } { 820 125141 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 125141 820 } { 820 125142 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 125142 820 } { 7380 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 835 820 } { 820 1158 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1158 820 } { 820 11505 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1157 820 } { 820 11504 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 833 820 } { 820 2388 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 832 820 } { 820 2387 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 781 } { 782 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 782 } { 786 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 786 } { 789 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 789 } { 794 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 829 820 } { 820 830 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 830 820 } { 820 831 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 831 820 } { 820 838 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 838 820 } { 820 842 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 842 820 } { 820 843 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 843 820 } { 820 844 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 844 820 } { 820 848 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 848 820 } { 820 849 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 849 820 } { 820 850 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 850 820 } { 820 855 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 855 820 } { 820 859 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 859 820 } { 820 861 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 861 820 } { 820 862 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 862 820 } { 820 1156 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1156 820 } { 820 1159 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1159 820 } { 820 1857 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1857 820 } { 820 1861 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1861 820 } { 820 6109 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6109 820 } { 820 6832 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6832 820 } { 820 6833 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6833 820 } { 820 6834 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6834 820 } { 820 6835 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6835 820 } { 820 6836 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6836 820 } { 820 6843 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6843 820 } { 820 6844 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6844 820 } { 820 7616 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7616 820 } { 820 7617 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7617 820 } { 820 7619 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7619 820 } { 820 7620 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7620 820 } { 820 7621 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7621 820 } { 820 7622 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7622 820 } { 820 7623 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7623 820 } { 820 7624 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7624 820 } { 820 7625 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7625 820 } { 820 7627 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7627 820 } { 820 7628 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7628 820 } { 820 7629 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7629 820 } { 820 7630 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7630 820 } { 820 7633 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7633 820 } { 820 7669 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7675 820 } { 820 7678 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7678 820 } { 820 8432 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8432 820 } { 820 11503 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 11503 820 } { 820 42620 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 42620 820 } { 820 42621 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 42621 820 } { 820 68325 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 790 } { 791 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 791 } { 792 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 792 } { 793 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 793 } { 796 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 796 } { 797 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 797 } { 798 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 798 } { 799 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 799 } { 800 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 800 } { 809 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 809 } { 810 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 810 } { 811 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 811 } { 812 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 812 } { 815 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 820 815 } { 819 820 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 826 820 } { 820 827 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 827 820 } { 820 828 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 828 820 } { 820 839 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 839 820 } { 820 840 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 840 820 } { 820 841 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 841 820 } { 820 845 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 845 820 } { 820 846 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 846 820 } { 820 851 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 851 820 } { 820 852 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 852 820 } { 820 853 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 853 820 } { 820 854 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 854 820 } { 820 857 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 857 820 } { 820 858 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 858 820 } { 820 860 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 860 820 } { 820 863 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 863 820 } { 820 866 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 866 820 } { 820 1858 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1858 820 } { 820 1862 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1862 820 } { 820 2137 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2137 820 } { 820 2138 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2138 820 } { 820 2139 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2139 820 } { 820 6837 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6837 820 } { 820 6838 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6838 820 } { 820 6839 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6839 820 } { 820 6840 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6840 820 } { 820 6841 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6841 820 } { 820 6842 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6842 820 } { 820 6845 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6845 820 } { 820 7618 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7618 820 } { 820 7631 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7631 820 } { 820 7632 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7632 820 } { 820 7676 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7676 820 } { 820 7677 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7677 820 } { 820 7679 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7679 820 } { 820 8428 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8428 820 } { 820 8429 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8429 820 } { 820 8430 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8430 820 } { 820 8431 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8431 820 } { 820 65063 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65063 820 } { 820 68109 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 68109 820 } { 820 68326 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 864 820 } { 820 65058 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65058 820 } { 820 65065 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 865 820 } { 820 65056 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1155 820 } { 820 65070 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1464 820 } { 820 1479 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1465 820 } { 820 1466 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2076 820 } { 820 2077 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2078 820 } { 820 2079 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2079 820 } { 820 2080 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2081 820 } { 820 2082 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2082 820 } { 820 2083 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2086 820 } { 820 2087 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2089 820 } { 820 2090 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2364 820 } { 820 2492 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2492 820 } { 820 2620 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2620 820 } { 820 2748 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2748 820 } { 820 2876 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 2876 820 } { 820 3260 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3260 820 } { 820 6964 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 6964 820 } { 820 7142 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7142 820 } { 820 7223 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7223 820 } { 820 43443 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 43443 820 } { 820 69818 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 69818 820 } { 820 70003 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70003 820 } { 820 70090 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70090 820 } { 820 70198 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70198 820 } { 820 70377 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70377 820 } { 820 70460 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70726 820 } { 820 70851 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 70851 820 } { 820 71104 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 71104 820 } { 820 71351 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 7405 820 } { 820 69889 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 68111 820 } { 820 69890 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8194 97 } { 8193 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8189 97 } { 900 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8173 97 } { 901 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8174 97 } { 8129 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8190 97 } { 8157 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8656 97 } { 8653 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8658 97 } { 8655 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8660 97 } { 8654 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8800 97 } { 8316 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 10973 97 } { 10972 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8194 65 } { 8193 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8189 65 } { 900 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8173 65 } { 901 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8174 65 } { 8129 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8190 65 } { 8157 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8656 65 } { 8653 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8658 65 } { 8655 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8660 65 } { 8654 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8800 65 } { 8316 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 10973 65 } { 10972 65 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8194 98 } { 8193 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8189 98 } { 900 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8173 98 } { 901 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8174 98 } { 8129 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8190 98 } { 8157 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8656 98 } { 8653 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8658 98 } { 8655 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8660 98 } { 8654 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 8800 98 } { 8316 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 10973 98 } { 10972 98 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 876 820 } { 820 7626 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1081 97 } { 1080 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1049 97 } { 1048 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1575 1425 } { 1570 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1575 1425 } { 1571 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1608 1425 } { 1572 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1610 1425 } { 1574 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3144 97 } { 3142 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3274 1 } { 3270 3266 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3274 1425 } { 3270 3266 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3546 97 } { 3545 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3549 97 } { 3545 3535 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3548 1425 } { 3545 3535 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3955 97 } { 3953 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3969 97 } { 3953 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 3957 97 } { 3953 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4018 3968 } { 4018 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4018 820 } { 3959 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4018 3969 } { 4018 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4019 3968 } { 4019 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4019 3953 } { 3961 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4019 3969 } { 4019 1425 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 44032 97 } { 4352 119141 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 101106 98 } { 19968 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 40917 98 } { 64014 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 183969 98 } { 888 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 40918 98 } { 55296 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 55296 98 } { 55297 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 55297 98 } { 55298 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 55298 98 } { 55299 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 55299 98 } { 55300 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 55300 98 } { 56320 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 56320 98 } { 57343 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 63743 98 } { 64976 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 64976 98 } { 64977 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 64977 98 } { 64978 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 64978 98 } { 64979 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 64979 98 } { 64980 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65520 98 } { 65534 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65534 98 } { 65535 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 65535 98 } { 131070 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 131070 98 } { 131071 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 183970 98 } { 196606 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 196606 98 } { 196607 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 196607 98 } { 262142 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 262142 98 } { 262143 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 262143 98 } { 327678 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 327678 98 } { 327679 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 327679 98 } { 393214 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 393214 98 } { 393215 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 393215 98 } { 458750 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 458750 98 } { 458751 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 458751 98 } { 524286 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 524286 98 } { 524287 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 524287 98 } { 589822 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 589822 98 } { 589823 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 589823 98 } { 655358 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 655358 98 } { 655359 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 655359 98 } { 720894 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 720894 98 } { 720895 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 720895 98 } { 786430 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 786430 98 } { 786431 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 786432 98 } { 851966 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 851966 98 } { 851967 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 851968 98 } { 917502 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 917502 98 } { 917503 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 917509 98 } { 983038 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 983038 98 } { 983039 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1114109 98 } { 1114110 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 1114110 98 } { 1114111 33 } [ >string ] bi@ string<=> ] unit-test
]]
