USING: arrays kernel math math.order namespaces sequences kernel.private
sequences.private strings sbufs tools.test vectors assocs
generic vocabs.loader ;
IN: sequences.tests

[ "empty" ] [ { } [ "empty" ] [ "not empty" ] if-empty ] unit-test
[ { 1 } "not empty" ] [ { 1 } [ "empty" ] [ "not empty" ] if-empty ] unit-test

[ V{ 1 2 3 4 } ] [ 1 5 dup iota <slice> >vector ] unit-test
[ 3 ] [ 1 4 dup iota <slice> length ] unit-test
[ 2 ] [ 1 3 { 1 2 3 4 } <slice> length ] unit-test
[ V{ 2 3 } ] [ 1 3 { 1 2 3 4 } <slice> >vector ] unit-test
[ V{ 4 5 } ] [ { 1 2 3 4 5 } 2 tail-slice* >vector ] unit-test
[ V{ 3 4 } ] [ 2 4 1 10 dup iota <slice> subseq >vector ] unit-test
[ V{ 3 4 } ] [ 0 2 2 4 1 10 dup iota <slice> <slice> subseq >vector ] unit-test
[ 0 10 "hello" <slice> ] must-fail
[ -10 3 "hello" <slice> ] must-fail
[ 2 1 "hello" <slice> ] must-fail

[ "cba" ] [ "abcdef" 3 head-slice reverse ] unit-test

[ 5040 ] [ [ 1 2 3 4 5 6 7 ] 1 [ * ] reduce ] unit-test

[ 5040 { 1 1 2 6 24 120 720 } ]
[ { 1 2 3 4 5 6 7 } 1 [ * ] accumulate ] unit-test

[ 5040 { 1 1 2 6 24 120 720 } ]
[ { 1 2 3 4 5 6 7 } 1 [ * ] accumulate! ] unit-test

[ t ]
[ { 1 2 3 4 5 6 7 } dup 1 [ * ] accumulate! nip eq? ] unit-test

[ f f ] [ [ ] [ ] find ] unit-test
[ 0 1 ] [ [ 1 ] [ ] find ] unit-test
[ 1 "world" ] [ [ "hello" "world" ] [ "world" = ] find ] unit-test
[ 2 3 ] [ [ 1 2 3 ] [ 2 > ] find ] unit-test
[ f f ] [ [ 1 2 3 ] [ 10 > ] find ] unit-test

[ 1 CHAR: e ]
[ "hello world" "aeiou" [ member? ] curry find ] unit-test

[ 4 CHAR: o ]
[ 3 "hello world" "aeiou" [ member? ] curry find-from ] unit-test

[ f ] [ 3 [ ]     member? ] unit-test
[ f ] [ 3 [ 1 2 ] member? ] unit-test
[ t ] [ 1 [ 1 2 ] member? ] unit-test
[ t ] [ 2 [ 1 2 ] member? ] unit-test

[ t ]
[ [ "hello" "world" ] [ second ] keep member-eq? ] unit-test

[ 4 ] [ CHAR: x "tuvwxyz" >vector index ] unit-test 

[ f ] [ CHAR: x 5 "tuvwxyz" >vector index-from ] unit-test 

[ f ] [ CHAR: a 0 "tuvwxyz" >vector index-from ] unit-test

[ f ] [ [ "Hello" { } 0.75 ] [ string? ] all? ] unit-test
[ t ] [ [ ] [ ] all? ] unit-test
[ t ] [ [ "hi" t 0.5 ] [ ] all? ] unit-test

[ [ 1 2 3 ] ] [ [ 1 4 2 5 3 6 ] [ 4 < ] filter ] unit-test
[ { 4 2 6 } ] [ { 1 4 2 5 3 6 } [ 2 mod 0 = ] filter ] unit-test

[ [ 3 ] ] [ [ 1 2 3 ] 2 [ swap < ] curry filter ] unit-test

[ V{ 1 2 3 } ] [ V{ 1 4 2 5 3 6 } clone [ 4 < ] filter! ] unit-test
[ V{ 4 2 6 } ] [ V{ 1 4 2 5 3 6 } clone [ 2 mod 0 = ] filter! ] unit-test

[ V{ 3 } ] [ V{ 1 2 3 } clone 2 [ swap < ] curry filter! ] unit-test

[ "hello world how are you" ]
[ { "hello" "world" "how" "are" "you" } " " join ]
unit-test

[ "" ] [ { } "" join ] unit-test

[ { } ] [ { } flip ] unit-test

[ { "b" "e" } ] [ 1 { { "a" "b" "c" } { "d" "e" "f" } } flip nth ] unit-test

[ { { 1 4 } { 2 5 } { 3 6 } } ]
[ { { 1 2 3 } { 4 5 6 } } flip ] unit-test

[ [ 2 3 4 ] ] [ [ 1 2 3 ] 1 [ + ] curry map ] unit-test

[ 1 ] [ 0 [ 1 2 ] nth ] unit-test
[ 2 ] [ 1 [ 1 2 ] nth ] unit-test

[ [ ]           ] [ [ ]   [ ]       append ] unit-test
[ [ 1 ]         ] [ [ 1 ] [ ]       append ] unit-test
[ [ 2 ]         ] [ [ ] [ 2 ]       append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] [ 4 ] append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] { 4 } append ] unit-test

[ "a" -1 append ] must-fail
[ -1 "a" append ] must-fail

[ [ ]       ] [ 1 [ ]           remove ] unit-test
[ [ ]       ] [ 1 [ 1 ]         remove ] unit-test
[ [ 3 1 1 ] ] [ 2 [ 3 2 1 2 1 ] remove ] unit-test

[ [ ]       ] [ [ ]       reverse ] unit-test
[ [ 1 ]     ] [ [ 1 ]     reverse ] unit-test
[ [ 3 2 1 ] ] [ [ 1 2 3 ] reverse ] unit-test

[ f ] [ f 0 head ] unit-test
[ [ ] ] [ [ 1 ] 0 head ] unit-test
[ [ 1 2 3 ] ] [ [ 1 2 3 4 ] 3 head ] unit-test
[ [ ] ] [ [ 1 2 3 ] 3 tail ] unit-test
[ [ 3 ] ] [ [ 1 2 3 ] 2 tail ] unit-test

[ "blah" ] [ "blahxx" 2 head* ] unit-test

[ "xx" ] [ "blahxx" 2 tail* ] unit-test

[ t ] [ "xxfoo" 2 head-slice "xxbar" 2 head-slice = ] unit-test
[ t ] [ "xxfoo" 2 head-slice "xxbar" 2 head-slice [ hashcode ] bi@ = ] unit-test

[ t ] [ "xxfoo" 2 head-slice SBUF" barxx" 2 tail-slice* = ] unit-test
[ t ] [ "xxfoo" 2 head-slice SBUF" barxx" 2 tail-slice* [ hashcode ] bi@ = ] unit-test

[ t ] [ [ 1 2 3 ] [ 1 2 3 ] sequence= ] unit-test
[ t ] [ [ 1 2 3 ] { 1 2 3 } sequence= ] unit-test
[ t ] [ { 1 2 3 } [ 1 2 3 ] sequence= ] unit-test
[ f ] [ [ ] [ 1 2 3 ] sequence= ] unit-test

[ { 1 3 2 4 } ] [ { 1 2 3 4 } clone 1 2 pick exchange ] unit-test

[ { "" "a" "aa" "aaa" } ]
[ 4 [ CHAR: a <string> ] { } map-integers ]
unit-test

[ V{ } ] [ "f" V{ } clone remove! ] unit-test
[ V{ } ] [ "f" V{ "f" } clone remove! ] unit-test
[ V{ } ] [ "f" V{ "f" "f" } clone remove! ] unit-test
[ V{ "x" } ] [ "f" V{ "f" "x" "f" } clone remove! ] unit-test
[ V{ "y" "x" } ] [ "f" V{ "y" "f" "x" "f" } clone remove! ] unit-test

[ V{ 0 1 4 5 } ] [ 6 iota >vector 2 4 pick delete-slice ] unit-test

[ 6 >vector 2 8 pick delete-slice ] must-fail

[ V{ } ] [ 6 iota >vector 0 6 pick delete-slice ] unit-test

[ { 1 2 "a" "b" 5 6 7 } ] [
    { "a" "b" } 2 4 { 1 2 3 4 5 6 7 }
    replace-slice
] unit-test

[ { 1 2 "a" "b" 6 7 } ] [
    { "a" "b" } 2 5 { 1 2 3 4 5 6 7 }
    replace-slice
] unit-test

[ { 1 2 "a" "b" 4 5 6 7 } ] [
    { "a" "b" } 2 3 { 1 2 3 4 5 6 7 }
    replace-slice
] unit-test

[ { 1 2 3 4 5 6 7 "a" "b" } ] [
    { "a" "b" } 7 7 { 1 2 3 4 5 6 7 }
    replace-slice
] unit-test

[ { "a" 3 } ] [
    { "a" } 0 2 { 1 2 3 } replace-slice
] unit-test

[ { 1 4 9 } ] [ { 1 2 3 } clone [ sq ] map! ] unit-test

[ 5 ] [ 1 >bignum { 1 5 7 } nth-unsafe ] unit-test
[ 5 ] [ 1 >bignum { 1 5 7 } nth-unsafe ] unit-test
[ 5 ] [ 1 >bignum "\u000001\u000005\u000007" nth-unsafe ] unit-test

[ SBUF" before&after" ] [
    "&" 6 11 SBUF" before and after" replace-slice
] unit-test

[ 3 "a" ] [ { "a" "b" "c" "a" "d" } [ "a" = ] find-last ] unit-test

[ f f ] [ 100 { 1 2 3 } [ 1 = ] find-from ] unit-test
[ f f ] [ 100 { 1 2 3 } [ 1 = ] find-last-from ] unit-test
[ f f ] [ -1 { 1 2 3 } [ 1 = ] find-from ] unit-test

[ 0 ] [ { "a" "b" "c" } { "A" "B" "C" } mismatch ] unit-test

[ 1 ] [ { "a" "b" "c" } { "a" "B" "C" } mismatch ] unit-test

[ f ] [ { "a" "b" "c" } { "a" "b" "c" } mismatch ] unit-test

[ V{ } V{ } ] [ { "a" "b" } { "a" "b" } drop-prefix [ >vector ] bi@ ] unit-test

[ V{ "C" } V{ "c" } ] [ { "a" "b" "C" } { "a" "b" "c" } drop-prefix [ >vector ] bi@ ] unit-test

[ -1 1 "abc" <slice> ] must-fail

[ V{ "a" "b" } V{ } ] [ { "X" "a" "b" } { "X" } drop-prefix [ >vector ] bi@ ] unit-test

[ 1 ] [ 0.5 { 1 2 3 } nth ] unit-test

! Pathological case
[ "ihbye" ] [ "hi" <reversed> "bye" append ] unit-test

[ t ] [ "hi" <reversed> SBUF" hi" <reversed> = ] unit-test

[ t ] [ "hi" <reversed> SBUF" hi" <reversed> = ] unit-test

[ t ] [ "hi" <reversed> SBUF" hi" <reversed> [ hashcode ] bi@ = ] unit-test

[ -10 "hi" "bye" copy ] must-fail
[ 10 "hi" "bye" copy ] must-fail

[ V{ 1 2 3 5 6 } ] [
    3 V{ 1 2 3 4 5 6 } clone remove-nth!
] unit-test

! erg's random tester found this one
[ SBUF" 12341234" ] [
    9 <sbuf> dup "1234" swap push-all dup dup swap push-all
] unit-test

[ f ] [ f V{ } like f V{ } like eq? ] unit-test

[ V{ f f f } ] [ 3 V{ } new-sequence ] unit-test
[ SBUF" \0\0\0" ] [ 3 SBUF" " new-sequence ] unit-test

[ 0 ] [ f length ] unit-test
[ f first ] must-fail
[ 3 ] [ 3 10 iota nth ] unit-test
[ 3 ] [ 3 10 iota nth-unsafe ] unit-test
[ -3 10 iota nth ] must-fail
[ 11 10 iota nth ] must-fail

[ -1/0. 0 remove-nth! ] must-fail
[ "" ] [ "" [ CHAR: \s = ] trim ] unit-test
[ "" ] [ "" [ CHAR: \s = ] trim-head ] unit-test
[ "" ] [ "" [ CHAR: \s = ] trim-tail ] unit-test
[ "" ] [ "  " [ CHAR: \s = ] trim-head ] unit-test
[ "" ] [ "  " [ CHAR: \s = ] trim-tail ] unit-test
[ "asdf" ] [ " asdf " [ CHAR: \s = ] trim ] unit-test
[ "asdf " ] [ " asdf " [ CHAR: \s = ] trim-head ] unit-test
[ " asdf" ] [ " asdf " [ CHAR: \s = ] trim-tail ] unit-test

[ 328350 ] [ 100 iota [ sq ] map-sum ] unit-test

[ 50 ] [ 100 iota [ even? ] count ] unit-test
[ 50 ] [ 100 iota [ odd?  ] count ] unit-test

[ { "b" "d" } ] [ { 1 3 } { "a" "b" "c" "d" } nths ] unit-test
[ { "a" "b" "c" "d" } ] [ { 0 1 2 3 } { "a" "b" "c" "d" } nths ] unit-test
[ { "d" "c" "b" "a" } ] [ { 3 2 1 0 } { "a" "b" "c" "d" } nths ] unit-test
[ { "d" "a" "b" "c" } ] [ { 3 0 1 2 } { "a" "b" "c" "d" } nths ] unit-test
                          
TUPLE: bogus-hashcode ;

M: bogus-hashcode hashcode* 2drop 0 >bignum ;

[ 0 ] [ { T{ bogus-hashcode } } hashcode ] unit-test

[ { 2 4 6 } { 1 3 5 7 } ] [ { 1 2 3 4 5 6 7 } [ even? ] partition ] unit-test

[ { 1 3 7 } ] [ 2 { 1 3 5 7 } remove-nth ] unit-test

[ { 1 3 "X" 5 7 } ] [ "X" 2 { 1 3 5 7 } insert-nth ] unit-test

[ V{ 0 2 } ] [ "a" { "a" "b" "a" } indices ] unit-test

[ "a,b" ] [ "a" "b" "," glue ] unit-test
[ "(abc)" ] [ "abc" "(" ")" surround ] unit-test

[ "HELLO" ] [
    "HELLO" { -1 -1 -1 -1 -1 } { 2 2 2 2 2 2 }
    [ * 2 + + ] 3map
] unit-test

{ 3 1 } [ [ 3array ] 3map ] must-infer-as

{ 3 0 } [ [ 3drop ] 3each ] must-infer-as

[ V{ 0 3 } ] [ "A" { "A" "B" "C" "A" "D" } indices ] unit-test

[ "asdf" iota ] must-fail
[ T{ iota { n 10 } } ] [ 10 iota ] unit-test
[ 0 ] [ 10 iota first ] unit-test

[ "hi" 3 ] [
    { 1 2 3 4 5 6 7 8 } [ H{ { 3 "hi" } } at ] map-find
] unit-test

[ f f ] [
    { 1 2 3 4 5 6 7 8 } [ H{ { 11 "hi" } } at ] map-find
] unit-test

USE: make

[ { "a" 1 "b" 1 "c" } ]
[ 1 { "a" "b" "c" } [ [ dup , ] [ , ] interleave drop ] { } make ] unit-test

[ t ] [ 0 array-capacity? ] unit-test
[ f ] [ -1 array-capacity? ] unit-test

[ +lt+ ] [ { 0 0 0 } { 1 1 1 } <=> ] unit-test
[ +lt+ ] [ { 0 0 0 } { 0 1 1 } <=> ] unit-test
[ +lt+ ] [ { 0 0 0 } { 0 0 0 0 } <=> ] unit-test
[ +gt+ ] [ { 1 1 1 } { 0 0 0 } <=> ] unit-test
[ +gt+ ] [ { 0 1 1 } { 0 0 0 } <=> ] unit-test
[ +gt+ ] [ { 0 0 0 0 } { 0 0 0 } <=> ] unit-test
[ +eq+ ] [ { } { } <=> ] unit-test
[ +eq+ ] [ { 1 2 3 } { 1 2 3 } <=> ] unit-test

[ { { { 1 "a" } { 1 "b" } } { { 2 "a" } { 2 "b" } } } ]
[ { 1 2 } { "a" "b" } cartesian-product ] unit-test
