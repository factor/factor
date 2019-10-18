USING: accessors arrays ascii io io.streams.string kernel make
math math.vectors random sequences sequences.extras strings
tools.test vectors vocabs ;

{ V{ { 0 104 } { 2 108 } { 3 108 } } } [ "hello" [ even? ] find-all ] unit-test

{ { "a" "b" "c" "d" "ab" "bc" "cd" "abc" "bcd" "abcd" } } [ "abcd" all-subseqs ] unit-test

{ { "a" "ab" "abc" "abcd" "b" "bc" "bcd" "c" "cd" "d" } }
[ [ "abcd" [ , ] each-subseq ] { } make ] unit-test

{ B{ 115 } } [ 1 2 "asdf" B{ } subseq-as ] unit-test

{ "" } [ "abc" "def" longest-subseq ] unit-test
{ "abcd" } [ "abcd" "abcde" longest-subseq ] unit-test
{ "foo" } [ "foo" "foobar" longest-subseq ] unit-test
{ "foo" } [ "foobar" "foo" longest-subseq ] unit-test

{ "" "" } [ "" "" CHAR: ? pad-longest ] unit-test
{ "abc" "def" } [ "abc" "def" CHAR: ? pad-longest ] unit-test
{ "   " "abc" } [ "" "abc" CHAR: \s pad-longest ] unit-test
{ "abc" "   " } [ "abc" "" CHAR: \s pad-longest ] unit-test
{ "abc..." "foobar" } [ "abc" "foobar" CHAR: . pad-longest ] unit-test

{
    {
        "ABC"
        "ABC"
        "ABC"
        "ABC"
        "ABC-"
        "-ABC-"
        "-ABC--"
        "--ABC--"
    }
} [
    "ABC" 8 <iota> [ CHAR: - pad-center ] with map
] unit-test

{ { 0 1 0 1 } } [
    { 0 0 0 0 } { 1 3 } over [ 1 + ] change-nths
] unit-test

{ V{ f t f } } [
    { 1 2 3 } [ even? ] selector* [ each ] dip
] unit-test

{ { 1 3 5 } } [ { 1 2 3 4 5 6 } [ nip even? ] filter-index ] unit-test

{ V{ 1 3 5 } } [ { 1 2 3 4 5 6 } [ nip even? ] V{ } filter-index-as ] unit-test

{ { 1 3 5 } } [ { 1 2 3 4 5 6 } even-indices ] unit-test

{ { 2 4 6 } } [ { 1 2 3 4 5 6 } odd-indices ] unit-test

{ "a b c d e" }
[ "a      b  \t \n \r  c   d \n    e   " [ blank? ] " " compact ] unit-test

{ " a b c d e " }
[ " a      b  c   d    e   " [ blank? ] " " collapse ] unit-test

{ { "hello," " " "world!" " " " " } }
[ "hello, world!  " [ blank? ] slice-when [ >string ] map ] unit-test

{ t }
[ "abc" sequence>slice slice? ] unit-test

{ "abc" }
[ "abc" sequence>slice >string ] unit-test

{ t } [ "abcdef" [ 0 3 rot <slice> ] [ 2 4 rot <slice> ] bi slices-overlap? ] unit-test
{ t } [ "abcdef" [ 0 3 rot <slice> ] [ 1 2 rot <slice> ] bi slices-overlap? ] unit-test
{ f } [ "abcdef" [ 0 3 rot <slice> ] [ 3 6 rot <slice> ] bi slices-overlap? ] unit-test
{ t } [ "abcdef" [ 0 3 rot <slice> ] [ 2 4 rot <slice> ] bi slices-touch? ] unit-test
{ t } [ "abcdef" [ 0 3 rot <slice> ] [ 1 2 rot <slice> ] bi slices-touch? ] unit-test
{ t } [ "abcdef" [ 0 3 rot <slice> ] [ 3 6 rot <slice> ] bi slices-touch? ] unit-test
{ f } [ "abcdef" [ 0 3 rot <slice> ] [ 4 6 rot <slice> ] bi slices-touch? ] unit-test

{ "abcdef" } [
    "abcdef" [ 0 3 rot <slice> ] [ 3 6 rot <slice> ] bi merge-slices >string
] unit-test

{ "abcdef" } [
    "abcdef" [ 3 6 rot <slice> ] [ 0 3 rot <slice> ] bi merge-slices >string
] unit-test

{ "abc" } [
    "abcdef" [ 0 3 rot <slice> ] [ 0 3 rot <slice> ] bi merge-slices >string
] unit-test


{ "hello" "hello" } [ "hello" dup 0 rotate ] unit-test
{ "hello" "llohe" } [ "hello" dup 2 rotate ] unit-test
{ "hello" "lohel" } [ "hello" dup 13 rotate ] unit-test
{ "hello" "ohell" } [ "hello" dup -1 rotate ] unit-test
{ "hello" "lohel" } [ "hello" dup -12 rotate ] unit-test

{ "hello" } [ "hello" dup 0 rotate! ] unit-test
{ "llohe" } [ "hello" dup 2 rotate! ] unit-test
{ "lohel" } [ "hello" dup 13 rotate! ] unit-test
{ "ohell" } [ "hello" dup -1 rotate! ] unit-test
{ "lohel" } [ "hello" dup -12 rotate! ] unit-test

{ { } } [ { } [ ] map-concat ] unit-test
{ V{ 0 0 1 0 1 2 } } [ 4 <iota> [ <iota> ] map-concat ] unit-test
{ "abc" } [ "abc" [ 1string ] map-concat ] unit-test
{ "abc" } [ { 97 98 99 } [ 1string ] map-concat ] unit-test
{ { 97 98 99 } } [ "abc" [ 1string ] { } map-concat-as ] unit-test
{ "baz" { "foobaz" "barbaz" } }
[ "baz" { { "foo" } { "bar" } } [ [ over append ] map ] map-concat ] unit-test

{ { } } [ { } [ ] [ even? ] map-filter ] unit-test
{ "bcde" } [ "abcd" [ 1 + ] [ drop t ] map-filter ] unit-test
{ { 0 4 16 36 64 } } [ 10 <iota> [ sq ] [ even? ] { } map-filter-as ] unit-test

{ V{ 0 4 16 36 64 } } [ 10 <iota> [ even? ] [ sq ] filter-map ] unit-test
{ { 2 6 10 14 18 } } [ 10 <iota> [ odd? ] [ 2 * ] { } filter-map-as ] unit-test

{ 8 } [ 3 <iota> dup [ 1 + * ] 2map-sum ] unit-test
{ 4 } [ "hello" "jello" [ = ] 2count ] unit-test

{ { } } [ { } round-robin ] unit-test
{ "ADEBFC" } [ { "ABC" "D" "EF" } round-robin >string ] unit-test

{ { } } [ "ABC" [ ] { } trim-as ] unit-test
{ "ABC" } [ { 32 65 66 67 32 } [ blank? ] "" trim-as ] unit-test

{ t } [ "ABC" dup [ blank? ] ?trim [ identity-hashcode ] same? ] unit-test
{ "ABC" } [ " ABC " [ blank? ] ?trim ] unit-test

{ t } [ "ABC" dup [ blank? ] ?trim-head [ identity-hashcode ] same? ] unit-test
{ t } [ "ABC" dup [ blank? ] ?trim-tail [ identity-hashcode ] same? ] unit-test
{ "ABC " } [ " ABC " [ blank? ] ?trim-head ] unit-test
{ " ABC" } [ " ABC " [ blank? ] ?trim-tail ] unit-test

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
{ { 0 2 } } [ 4 <iota> <evens> >array ] unit-test
{ { 0 2 4 } } [ 5 <iota> <evens> >array ] unit-test
{ "bbddff" } [ "abcdef" <evens> [ 1 + ] map! seq>> ] unit-test

{ { } } [ { } <odds> >array ] unit-test
{ { 1 3 } } [ 5 <iota> <odds> >array ] unit-test
{ { 1 3 5 } } [ 6 <iota> <odds> >array ] unit-test
{ "acceeg" } [ "abcdef" <odds> [ 1 + ] map! seq>> ] unit-test

{ 1 } [ { 1 7 3 7 6 3 7 } arg-max ] unit-test
{ 2 } [ { 0 1 99 } arg-max ] unit-test
{ 0 } [ { 1 7 3 7 6 3 7 } arg-min ] unit-test
{ V{ 0 4 } } [ { 5 3 2 10 5 } [ 5 = ] arg-where ] unit-test
{ { 2 1 0 4 3 } } [ { 5 3 2 10 5 } arg-sort ] unit-test

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

{ "abc" } [ B{ 97 98 99 100 101 102 103 } 3 "" head-as ] unit-test
{ "abcd" } [ B{ 97 98 99 100 101 102 103 } 3 "" head*-as ] unit-test
{ "defg" } [ B{ 97 98 99 100 101 102 103 } 3 "" tail-as ] unit-test
{ "efg" } [ B{ 97 98 99 100 101 102 103 } 3 "" tail*-as ] unit-test

{ { 1 0 0 1 0 0 0 1 0 0 } }
[ 1 { 0 3 7 } 10 0 <array> [ set-nths ] keep ] unit-test

{ { 1 0 0 1 0 0 0 1 0 0 } }
[ 1 { 0 3 7 } 10 0 <array> [ set-nths-unsafe ] keep ] unit-test

{ V{ 1 } } [ 1 flatten1 ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } flatten1 ] unit-test
{ { 1 2 3 { { 4 } } } } [ { 1 { 2 } { 3 { { 4 } } } } flatten1 ] unit-test

{ t 3 3 } [ 10 <iota> [ [ odd? ] [ 1 > ] bi* and ] map-find-index ] unit-test
{ f f f } [ 10 <iota> [ [ odd? ] [ 9 > ] bi* and ] map-find-index ] unit-test

{ "abcdef" } [ f f "abcdef" subseq* ] unit-test
{ "abcdef" } [ 0 f "abcdef" subseq* ] unit-test
{ "ab" } [ f 2 "abcdef" subseq* ] unit-test
{ "cdef" } [ 2 f "abcdef" subseq* ] unit-test
{ "cd" } [ -4 -2 "abcdef" subseq* ] unit-test

{ "foo" "" } [ "foo" [ blank? ] cut-when ] unit-test
{ "foo" " " } [ "foo " [ blank? ] cut-when ] unit-test
{ "" " foo" } [ " foo" [ blank? ] cut-when ] unit-test
{ "foo" " bar" } [ "foo bar" [ blank? ] cut-when ] unit-test

{ { 4 0 3 1 2 } } [ { 0 4 1 3 2 } 5 <iota> [ nth* ] curry map ] unit-test

{ 1 "beef" } [ { "chicken" "beef" "moose" } [ length ] infimum-by* ] unit-test
{ 0 "chicken" } [ { "chicken" "beef" "moose" } [ length ] supremum-by* ] unit-test
{ 2 "moose" } [ { "chicken" "beef" "moose" } [ first ] supremum-by* ] unit-test
{ f } [ f ?supremum ] unit-test
{ f } [ { } ?supremum ] unit-test
{ f } [ { f } ?supremum ] unit-test
{ 3 } [ { 1 f 3 2 } ?supremum ] unit-test
{ 3 } [ { 1 3 2 } ?supremum ] unit-test
{ f } [ f ?infimum ] unit-test
{ f } [ { } ?infimum ] unit-test
{ f } [ { f } ?infimum ] unit-test
{ 1 } [ { 1 f 3 2 } ?infimum ] unit-test
{ 1 } [ { 1 3 2 } ?infimum ] unit-test

{ 3/10 } [ 10 <iota> [ 3 < ] count* ] unit-test

{ { 0 } } [ "ABA" "ABABA" start-all ] unit-test
{ { 0 2 } } [ "ABA" "ABABA" start-all* ] unit-test
{ { 0 3 } } [ "ABA" "ABAABA" start-all ] unit-test
{ 1 } [ "ABA" "ABABA" count-subseq ] unit-test
{ 2 } [ "ABA" "ABABA" count-subseq* ] unit-test

{ 120000 } [ { 10 20 30 40 50 60 } 1 [ * ] 3 reduce-from ] unit-test

{
    {
        { 2 4 }
        { 3 6 }
        { 4 8 }
    }
} [ { 2 3 4 } [ 2 * ] map-zip ] unit-test

{ }
[ "test:" all-words [ name>> over prepend ] map-zip 2drop ] unit-test

{ { 0 1 2 3 } } [ 8 <iota> [ 4 < ] take-while >array ] unit-test
{ { } } [ { 15 16 } [ 4 < ] take-while >array ] unit-test
{ { 0 1 2 } } [ 3 <iota> [ 4 < ] take-while >array ] unit-test

{ { 4 5 6 7 } } [ 8 <iota> [ 4 < ] drop-while >array ] unit-test
{ { 15 16 } } [ { 15 16 } [ 4 < ] drop-while >array ] unit-test
{ { } } [ 3 <iota> [ 4 < ] drop-while >array ] unit-test

{ { } } [ { } ", " interleaved ] unit-test
{ { 1 } } [ { 1 } ", " interleaved ] unit-test
{ { 1 ", " 2 } } [ { 1 2 } ", " interleaved ] unit-test
{ "" } [ "" CHAR: _ interleaved ] unit-test
{ "a" } [ "a" CHAR: _ interleaved ] unit-test
{ "a_b" } [ "ab" CHAR: _ interleaved ] unit-test
{ "a_b_c" } [ "abc" CHAR: _ interleaved ] unit-test
{ "a_b_c_d" } [ "abcd" CHAR: _ interleaved ] unit-test

{ 0 } [ { 1 2 3 4 } [ 5 > ] count-head ] unit-test
{ 2 } [ { 1 2 3 4 } [ 3 < ] count-head ] unit-test
{ 4 } [ { 1 2 3 4 } [ 5 < ] count-head ] unit-test

{ 0 } [ { 1 2 3 4 } [ 5 > ] count-tail ] unit-test
{ 2 } [ { 1 2 3 4 } [ 2 > ] count-tail ] unit-test
{ 4 } [ { 1 2 3 4 } [ 5 < ] count-tail ] unit-test
