USING: arrays ascii io io.streams.string kernel make math
math.vectors random sequences sequences.extras strings
tools.test ;

IN: sequences.extras.tests

[ 4 ] [ 5 iota [ ] supremum-by ] unit-test
[ 0 ] [ 5 iota [ ] infimum-by ] unit-test
{ "bar" } [ { "bar" "baz" "qux" } [ length ] supremum-by ] unit-test
{ "bar" } [ { "bar" "baz" "qux" } [ length ] infimum-by ] unit-test
[ { "foo" } ] [ { { "foo" } { "bar" } } [ first ] supremum-by ] unit-test
[ { "bar" } ] [ { { "foo" } { "bar" } } [ first ] infimum-by ] unit-test

[ { 0 0 255 } ] [
    {
        { 0 0 0 }
        { 95 255 95 }
        { 215 95 95 }
        { 95 135 255 }
        { 135 95 135 }
        { 135 255 255 }
        { 0 0 255 }
        { 0 95 95 }
        { 0 255 215 }
        { 135 0 95 }
        { 255 0 175 }
    } [ { 0 0 255 } distance ] infimum-by
] unit-test

{ V{ 0 1 2 3 4 5 6 7 8 9 } } [
    V{ } clone
    10 iota >array randomize
    [ swap insert-sorted ] each
] unit-test

[ { "a" "b" "c" "d" "ab" "bc" "cd" "abc" "bcd" "abcd" } ] [ "abcd" all-subseqs ] unit-test

[ { "a" "ab" "abc" "abcd" "b" "bc" "bcd" "c" "cd" "d" } ]
[ [ "abcd" [ , ] each-subseq ] { } make ] unit-test

[ "" ] [ "abc" "def" longest-subseq ] unit-test
[ "abcd" ] [ "abcd" "abcde" longest-subseq ] unit-test
[ "foo" ] [ "foo" "foobar" longest-subseq ] unit-test
[ "foo" ] [ "foobar" "foo" longest-subseq ] unit-test

[ "" "" ] [ "" "" CHAR: ? pad-longest ] unit-test
[ "abc" "def" ] [ "abc" "def" CHAR: ? pad-longest ] unit-test
[ "   " "abc" ] [ "" "abc" CHAR: \s pad-longest ] unit-test
[ "abc" "   " ] [ "abc" "" CHAR: \s pad-longest ] unit-test
[ "abc..." "foobar" ] [ "abc" "foobar" CHAR: . pad-longest ] unit-test

[ { 0 1 0 1 } ] [
    { 0 0 0 0 } { 1 3 } over [ 1 + ] change-nths
] unit-test

[ { 1 3 5 } ] [ { 1 2 3 4 5 6 } [ nip even? ] filter-index ] unit-test

[ V{ 1 3 5 } ] [ { 1 2 3 4 5 6 } [ nip even? ] V{ } filter-index-as ] unit-test

[ { 1 3 5 } ] [ { 1 2 3 4 5 6 } even-indices ] unit-test

[ { 2 4 6 } ] [ { 1 2 3 4 5 6 } odd-indices ] unit-test

{ "a b c d e" }
[ "a      b  \t \n \r  c   d \n    e   " [ blank? ] " " compact ] unit-test

{ " a b c d e " }
[ " a      b  c   d    e   " [ blank? ] " " collapse ] unit-test

{ { "hello," " " "world!" " " " " } }
[ "hello, world!  " [ blank? ] slice-when [ >string ] map ] unit-test

{ "hello" } [ "hello" 0 rotate ] unit-test
{ "llohe" } [ "hello" 2 rotate ] unit-test
{ "hello" } [ "hello" dup 0 rotate! ] unit-test
{ "lohel" } [ "hello" dup 3 rotate! ] unit-test

{ { } } [ { } [ ] map-concat ] unit-test
{ V{ 0 0 1 0 1 2 } } [ 4 iota [ iota ] map-concat ] unit-test
{ "abc" } [ "abc" [ 1string ] map-concat ] unit-test
{ "abc" } [ { 97 98 99 } [ 1string ] map-concat ] unit-test
{ { 97 98 99 } } [ "abc" [ 1string ] { } map-concat-as ] unit-test

{ { } } [ { } [ ] [ even? ] map-filter ] unit-test
{ "bcde" } [ "abcd" [ 1 + ] [ drop t ] map-filter ] unit-test
{ { 0 4 16 36 64 } } [ 10 iota [ sq ] [ even? ] { } map-filter-as ] unit-test

{ V{ 0 4 16 36 64 } } [ 10 iota [ even? ] [ sq ] filter-map ] unit-test
{ { 2 6 10 14 18 } } [ 10 iota [ odd? ] [ 2 * ] { } filter-map-as ] unit-test

{ 8 } [ 3 iota dup [ 1 + * ] 2map-sum ] unit-test
{ 4 } [ "hello" "jello" [ = ] 2count ] unit-test

{ { } } [ { } round-robin ] unit-test
{ "ADEBFC" } [ { "ABC" "D" "EF" } round-robin >string ] unit-test

{ { } } [ "ABC" [ ] { } trim-as ] unit-test
{ "ABC" } [ { 32 65 66 67 32 } [ blank? ] "" trim-as ] unit-test

{ t } [ "ABC" dup [ blank? ] ?trim [ identity-hashcode ] same? ] unit-test
{ "ABC" } [ " ABC " [ blank? ] ?trim ] unit-test

{ "" } [ "" "" "" unsurround ] unit-test
{ "" } [ "  " " " " " unsurround ] unit-test
{ "foo.com" } [ "http://foo.com" "http://" "/" unsurround ] unit-test

{ t } [ { 1 3 5 7 } [ even? ] none? ] unit-test
{ f } [ { 1 2 3 4 } [ even? ] none? ] unit-test
{ t } [ { } [ even? ] none? ] unit-test

{ f } [ { 1 2 3 4 } [ even? ] one? ] unit-test
{ t } [ { 1 2 3 } [ even? ] one? ] unit-test
{ f } [ { } [ even? ] one? ] unit-test

{ { { 5 8 0 } { 6 9 1 } { 7 10 2 } } } [ { 5 6 7 } { 8 9 10 } [ 3array ] 2map-index ] unit-test

{ { } } [ { } <evens> >array ] unit-test
{ { 0 2 } } [ 4 iota <evens> >array ] unit-test
{ { 0 2 4 } } [ 5 iota <evens> >array ] unit-test

{ { } } [ { } <odds> >array ] unit-test
{ { 1 3 } } [ 5 iota <odds> >array ] unit-test
{ { 1 3 5 } } [ 6 iota <odds> >array ] unit-test

{ 1 } [ { 1 7 3 7 6 3 7 } arg-max ] unit-test
{ 0 } [ { 1 7 3 7 6 3 7 } arg-min ] unit-test

{ t } [ { 1 2 3 4 5 } 1 first= ] unit-test
{ t } [ { 1 2 3 4 5 } 2 second= ] unit-test
{ t } [ { 1 2 3 4 5 } 3 third= ] unit-test
{ t } [ { 1 2 3 4 5 } 4 fourth= ] unit-test
{ t } [ { 1 2 3 4 5 } 5 last= ] unit-test
{ t } [ 4 { 1 2 3 4 5 } 5 nth= ] unit-test

{ t } [ { 1 2 3 4 5 } [ 1 = ] first? ] unit-test
{ t } [ { 1 2 3 4 5 } [ 2 = ] second? ] unit-test
{ t } [ { 1 2 3 4 5 } [ 3 = ] third? ] unit-test
{ t } [ { 1 2 3 4 5 } [ 4 = ] fourth? ] unit-test
{ t } [ { 1 2 3 4 5 } [ 5 = ] last? ] unit-test
{ t } [ 4 { 1 2 3 4 5 } [ 5 = ] nth? ] unit-test

{ { 97 115 100 102 } } [
    "asdf" [ [ read1 ] loop>array ] with-string-reader
] unit-test

{ V{ 97 115 100 102 } } [
    "asdf" [ [ read1 ] V{ } loop>sequence ] with-string-reader
] unit-test

{ "" } [ { } "" reverse-as ] unit-test
{ "ABC" } [ { 67 66 65 } "" reverse-as ] unit-test

{ V{ 1 } } [ 1 0 V{ } [ insert-nth! ] keep ] unit-test
{ V{ 1 2 3 4 } } [ 2 1 V{ 1 3 4 } [ insert-nth! ] keep ] unit-test
