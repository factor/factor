USING: accessors arrays ascii grouping io io.streams.string
kernel make math prettyprint ranges sequences sequences.extras
strings tools.test ;

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
[ "a      b  \t \n \r  c   d \n    e   " [ ascii:blank? ] " " compact ] unit-test

{ " a b c d e " }
[ " a      b  c   d    e   " [ ascii:blank? ] " " collapse ] unit-test

{ { "hello," " " "world!" " " " " } }
[ "hello, world!  " [ ascii:blank? ] slice-when [ >string ] map ] unit-test

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

{ 120000 } [ { 10 20 30 40 50 60 } 1 [ * ] 3 reduce-from ] unit-test

{ 21 } [
    { 1 2 3 } { 4 5 6 } 0 [ + + ] 0 2reduce-from
] unit-test

{ 16 } [
    { 1 2 3 } { 4 5 6 } 0 [ + + ] 1 2reduce-from
] unit-test

{ V{ 0 4 16 36 64 } } [ 10 <iota> [ even? ] [ sq ] filter-map ] unit-test
{ V{ 0 4 16 36 64 } } [ 10 <iota> [ even? ] [ sq ] filter-map ] unit-test
{ V{ 2 6 10 14 18 } } [ 10 <iota> [ odd? ] [ 2 * ] V{ } filter-map-as ] unit-test
{ { 2 6 10 14 18 } } [ 10 <iota> [ odd? ] [ 2 * ] { } filter-map-as ] unit-test

{ V{ 1 9 25 49 81 } } [ 10 <iota> [ even? ] [ sq ] reject-map ] unit-test
{ V{ 1 9 25 49 81 } } [ 10 <iota> [ even? ] [ sq ] reject-map ] unit-test
{ V{ 0 4 8 12 16 }  } [ 10 <iota> [ odd? ] [ 2 * ] V{ } reject-map-as ] unit-test
{ { 0 4 8 12 16 }   } [ 10 <iota> [ odd? ] [ 2 * ] { } reject-map-as ] unit-test

{ V{ 0 4 16 36 64 } } [ 10 <iota> [ dup even? [ sq t ] [ f ] if ] filter-map* ] unit-test
{ V{ 0 4 16 36 64 } } [ 10 <iota> [ sq dup even? ] filter-map* ] unit-test
{ V{ 2 6 10 14 18 } } [ 10 <iota> [ dup odd? [ 2 * t ] [ f ] if ] V{ } filter-map-as* ] unit-test
{ { 2 6 10 14 18 } } [ 10 <iota> [ dup odd? [ 2 * t ] [ f ] if ] { } filter-map-as* ] unit-test

{ V{ 1 9 25 49 81 } } [ 10 <iota> [ dup even? [ t ] [ sq f ] if ] reject-map* ] unit-test
{ V{ 1 9 25 49 81 } } [ 10 <iota> [ sq dup even? ] reject-map* ] unit-test
{ V{ 0 4 8 12 16 }  } [ 10 <iota> [ dup odd? [ t ] [ 2 * f ] if ] V{ } reject-map-as* ] unit-test
{ { 0 4 8 12 16 }   } [ 10 <iota> [ dup odd? [ t ] [ 2 * f ] if ] { } reject-map-as* ] unit-test

{ 8 } [ 3 <iota> dup [ 1 + * ] 2map-sum ] unit-test
{ 4 } [ "hello" "jello" [ = ] 2count ] unit-test

{ { } } [ { } round-robin ] unit-test
{ "ADEBFC" } [ { "ABC" "D" "EF" } round-robin >string ] unit-test

{ { } } [ "ABC" [ ] { } trim-as ] unit-test
{ "ABC" } [ { 32 65 66 67 32 } [ ascii:blank? ] "" trim-as ] unit-test

{ t } [ "ABC" dup [ ascii:blank? ] ?trim [ identity-hashcode ] same? ] unit-test
{ "ABC" } [ " ABC " [ ascii:blank? ] ?trim ] unit-test

{ t } [ "ABC" dup [ ascii:blank? ] ?trim-head [ identity-hashcode ] same? ] unit-test
{ t } [ "ABC" dup [ ascii:blank? ] ?trim-tail [ identity-hashcode ] same? ] unit-test
{ "ABC " } [ " ABC " [ ascii:blank? ] ?trim-head ] unit-test
{ " ABC" } [ " ABC " [ ascii:blank? ] ?trim-tail ] unit-test

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

{ 10 } [ { 4 3 2 1 } [ 10 * ] map-minimum ] unit-test
{ 40 } [ { 4 3 2 1 } [ 10 * ] map-maximum ] unit-test

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

{ V{ 1 3 } } [ V{ 1 2 3 } 1 2 delete-slice-of ] unit-test
{ V{ 1 2 } } [ V{ 1 2 3 } 2 remove-nth-of! ] unit-test

{
    T{ slice { to 1 } { seq V{ 1 2 3 4 5 } } }
    T{ slice { from 2 } { to 5 } { seq V{ 1 2 3 4 5 } } }
} [
    V{ 1 2 3 4 5 } 1 2 snip-slice-of
] unit-test

{ V{ 1 } V{ 3 4 5 } } [
    V{ 1 2 3 4 5 } 1 2 snip-of
] unit-test

{ "abc" } [ B{ 97 98 99 100 101 102 103 } 3 "" head-as ] unit-test
{ "abcd" } [ B{ 97 98 99 100 101 102 103 } 3 "" head*-as ] unit-test
{ "defg" } [ B{ 97 98 99 100 101 102 103 } 3 "" tail-as ] unit-test
{ "efg" } [ B{ 97 98 99 100 101 102 103 } 3 "" tail*-as ] unit-test

{ { 1 0 0 1 0 0 0 1 0 0 } }
[ 1 { 0 3 7 } 10 0 <array> [ set-nths ] keep ] unit-test

{ { 1 0 0 1 0 0 0 1 0 0 } }
[ 1 { 0 3 7 } 10 0 <array> [ set-nths-unsafe ] keep ] unit-test

{ t 3 3 } [ 10 <iota> [ [ odd? ] [ 1 > ] bi* and ] map-find-index ] unit-test
{ f f f } [ 10 <iota> [ [ odd? ] [ 9 > ] bi* and ] map-find-index ] unit-test

{ { 0 400 900 } }
[ { 10 20 30 } [ sq ] 1 map-from ] unit-test

{ V{ f 400 900 } }
[ { 10 20 30 } [ sq ] 1 V{ } map-from-as ] unit-test

{ "abcdef" } [ f f "abcdef" subseq* ] unit-test
{ "abcdef" } [ 0 f "abcdef" subseq* ] unit-test
{ "ab" } [ f 2 "abcdef" subseq* ] unit-test
{ "cdef" } [ 2 f "abcdef" subseq* ] unit-test
{ "cd" } [ -4 -2 "abcdef" subseq* ] unit-test

{ "foo" "" } [ "foo" [ ascii:blank? ] cut-when ] unit-test
{ "foo" " " } [ "foo " [ ascii:blank? ] cut-when ] unit-test
{ "" " foo" } [ " foo" [ ascii:blank? ] cut-when ] unit-test
{ "foo" " bar" } [ "foo bar" [ ascii:blank? ] cut-when ] unit-test

{ { 4 0 3 1 2 } } [ { 0 4 1 3 2 } 5 <iota> [ nth* ] curry map ] unit-test

{ 1 "beef" } [ { "chicken" "beef" "moose" } [ length ] minimum-by* ] unit-test
{ 0 "chicken" } [ { "chicken" "beef" "moose" } [ length ] maximum-by* ] unit-test
{ 2 "moose" } [ { "chicken" "beef" "moose" } [ first ] maximum-by* ] unit-test
{ f } [ f ?maximum ] unit-test
{ f } [ { } ?maximum ] unit-test
{ f } [ { f } ?maximum ] unit-test
{ 3 } [ { 1 f 3 2 } ?maximum ] unit-test
{ 3 } [ { 1 3 2 } ?maximum ] unit-test
{ f } [ f ?minimum ] unit-test
{ f } [ { } ?minimum ] unit-test
{ f } [ { f } ?minimum ] unit-test
{ 1 } [ { 1 f 3 2 } ?minimum ] unit-test
{ 1 } [ { 1 3 2 } ?minimum ] unit-test

{ 3/10 } [ 10 <iota> [ 3 < ] percent-of ] unit-test

{ { 0 } } [ "ABABA" "ABA" start-all ] unit-test
{ { 0 2 } } [ "ABABA" "ABA" start-all* ] unit-test
{ { 0 3 } } [ "ABAABA" "ABA" start-all ] unit-test
{ 1 } [ "ABABA" "ABA" count-subseq ] unit-test
{ 2 } [ "ABABA" "ABA" count-subseq* ] unit-test

{ 0 } [ { } [ + ] 0reduce ] unit-test
{ 107 } [ { 100 1 2 4 } [ + ] 0reduce ] unit-test
{ 0 } [ { 100 1 2 4 } [ * ] 0reduce ] unit-test

{ f } [ { } [ + ] 1reduce ] unit-test
{ 107 } [ { 100 1 2 4 } [ + ] 1reduce ] unit-test
{ 800 } [ { 100 1 2 4 } [ * ] 1reduce ] unit-test

{ 800 } [ { 100 1 2 4 } [ * ] 1 reduce-of ] unit-test
{ 800 { 1 100 100 200 } } [ { 100 1 2 4 } [ * ] 1 accumulate-of ] unit-test

{ { } } [ { } [ + ] 0accumulate ] unit-test
{ { 100 101 103 107 } } [ { 100 1 2 4 } [ + ] 0accumulate ] unit-test

{ { "y" "o" "y" "p" "o" "y" } }
[ { "y" "o" "y" "p" "o" "y" } [ classify ] [ deduplicate ] bi nths ] unit-test

{ { "take" "drop" "pick" } }
[ { "take" "drop" "drop" "pick" "take" "take" } deduplicate ] unit-test

{ { "drop" "pick" "take" } }
[ { "take" "drop" "drop" "pick" "take" "take" } deduplicate-last ] unit-test

{ { } }
[ "" mark-firsts ] unit-test

{ { 1 1 0 0 1 0 } }
[ "abaacb" mark-firsts ] unit-test

{
    H{ { t 6 } { f 5 } }
    { 0 0 1 1 2 3 4 2 3 4 5 }
} [
    { 2 7 1 8 1 7 1 8 2 8 4 } [ even? ] occurrence-count-by
] unit-test

{
    H{ { 8 3 } { 1 3 } { 2 2 } { 4 1 } { 7 2 } }
    { 0 0 0 0 1 1 2 1 1 2 0 }
} [
    { 2 7 1 8 1 7 1 8 2 8 4 } [ ] occurrence-count-by
] unit-test

{ { 1 4 2 } } [
    { 0 1 2 3 } { 1 8 2 } bqn-index
] unit-test

{
    H{
        { 97 1 } { 98 1 } { 99 1 } { 100 1 } { 101 1 } { 102 1 }
        { 103 1 } { 104 1 } { 105 1 } { 106 1 } { 107 1 } { 108 1 }
        { 109 1 } { 110 1 } { 111 1 } { 112 1 }
    }
    { 1 2 0 3 3 3 3 3 3 3 3 3 3 3 3 3 }
} [
    "cab" "abcdefghijklmnop" progressive-index
] unit-test

{ H{ { 97 5 } } { 0 1 2 3 3 } } [
    "aaa" "aaaaa" progressive-index
] unit-test

{ H{ { 97 5 } { 98 5 } } { 0 3 1 4 2 5 5 5 5 5 } } [
    "aaabb" "ababababab" progressive-index
] unit-test

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

{ t } [ { 1 2 3 4 } [ 5 > ] 0 count= ] unit-test
{ f } [ { 1 2 3 4 } [ 5 > ] 1 count= ] unit-test
{ 1 t } [ 1 { 1 1 3 4 } [ dupd = ] 2 count= ] unit-test
{ 1 f } [ 1 { 1 1 3 4 } [ dupd = ] 3 count= ] unit-test
{ 4 t } [ 0 { 1 1 3 4 } [ [ 1 + dup ] dip = ] 3 count= ] unit-test
{ 5 8 f } [ 0 1 { 1 1 2 3 5 8 } [ [ swap dupd + ] dip pick = ] 4 count= ] unit-test
{ 8 13 t } [ 0 1 { 1 1 0 3 0 8 } [ [ swap dupd + ] dip pick = ] 4 count= ] unit-test
{ 8 13 f } [ 0 1 { 1 1 2 3 5 8 } [ [ swap dupd + ] dip pick = ] 8 count= ] unit-test

{ SBUF" aco" SBUF" ftr"  } [ SBUF" factor" dup [ even? ] extract! ] unit-test

{ 25 5 1 } [ { 4 5 6 } [ sq ] [ 20 > ] find-pred ] unit-test
{ f f f } [ { 4 5 6 } [ sq ] [ 200 > ] find-pred ] unit-test

{ -1/0. } [ { } max-subarray-sum ] unit-test
{ -2 } [ { -3 -2 } max-subarray-sum ] unit-test
{ 7 } [ { 1 2 3 -4 5 } max-subarray-sum ] unit-test
{ 6 } [ { 1 2 3 -4 1 1 } max-subarray-sum ] unit-test

{ { 9 7 5 } } [ -1 -6 -2 10 <iota> <step-slice> >array ] unit-test
{ { 9 7 } } [ -1 -5 -2 10 <iota> <step-slice> >array ] unit-test
{ { 9 7 } } [ -1 -4 -2 10 <iota> <step-slice> >array ] unit-test
{ { 9 } } [ -1 -3 -2 10 <iota> <step-slice> >array ] unit-test
{ { } } [ -4 10 -2 10 <iota> <step-slice> >array ] unit-test
{ { 6 8 } } [ -4 15 2 10 <iota> <step-slice> >array ] unit-test
{ { 1 3 } } [ 1 4 2 10 <iota> <step-slice> >array ] unit-test
{ { 1 3 } } [ 1 5 2 10 <iota> <step-slice> >array ] unit-test
{ { 1 3 5 } } [ 1 6 2 10 <iota> <step-slice> >array ] unit-test

{ { 102 306 1530 } } [
    { 2 3 5 } [ swap [ * ] [ 100 + ] if* ] map-with-previous
] unit-test

{ { } } [
    { } [ nip ] map-with-previous
] unit-test

{ { -1 2 -3 4 -5 } } [ { 1 2 3 4 5 } [ odd? ] [ neg ] map-if ] unit-test

{ { { 100 0 } { 200 1 } { 300 2 } { 400 3 } } } [
    { 100 200 300 400 } <zip-index> >array
] unit-test

{ } [
    { } [ - . ] each-prior
] unit-test

{ } [
    1000 { } [ - . ] each-prior-from
] unit-test

{ } [
    { 5 16 42 103 } [ - . ] each-prior
] unit-test

{ } [
    1 { 5 16 42 103 } [ - . ] each-prior-from
] unit-test


{ { } } [
    { } [ - ] map-prior
] unit-test

{ V{ 5 11 26 61 } } [
    V{ 5 16 42 103 } [ - ] map-prior
] unit-test

{ V{ f f 26 61 } } [
    2 V{ 5 16 42 103 } [ - ] map-prior-from
] unit-test

{ V{ f f 26 61 } } [
    2 { 5 16 42 103 } [ - ] V{ } map-prior-from-as
] unit-test

{ V{ } } [
    { } [ - ] V{ } map-prior-as
] unit-test

{ { 5 11 26 61 } } [
    V{ 5 16 42 103 } [ - ] { } map-prior-as
] unit-test

{ f } [ 0 CHAR: a "foo" nth-index ] unit-test
{ 0 } [ 0 CHAR: a "abba" nth-index ] unit-test
{ 3 } [ 1 CHAR: a "abba" nth-index ] unit-test
{ f } [ 2 CHAR: a "abba" nth-index ] unit-test

{ 1 5 } [ 1 { 3 5 7 9 11 } [ odd? ] find-nth ] unit-test
{ 3 9 } [ 3 { 3 5 7 9 11 } [ odd? ] find-nth ] unit-test
{ 4 11 } [ 3 1 { 3 5 7 9 11 } [ odd? ] find-nth-from ] unit-test
{ 3 9 } [ 1 { 3 5 7 9 11 } [ odd? ] find-nth-last ] unit-test
{ 1 5 } [ 3 { 3 5 7 9 11 } [ odd? ] find-nth-last ] unit-test
{ 1 5 } [ 1 2 { 3 5 7 9 11 } [ odd? ] find-nth-last-from ] unit-test

{ f f  } [ -2 2 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test
{ 0 11 } [ -1 2 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test
{ 2 13 } [  0 2 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test
{ 4 15 } [  1 2 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test
{ f f  } [  2 2 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test

{ f f  } [ -2 2 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test
{ 4 15 } [ -1 2 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test
{ 2 13 } [  0 2 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test
{ 0 11 } [  1 2 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test
{ f f  } [  2 2 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test

{ f f  } [ -2 2 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test
{ 1 12 } [ -1 2 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test
{ 3 14 } [  0 2 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test
{ f f  } [  1 2 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test
{ f f  } [  2 2 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test

{ f f  } [ -2 2 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test
{ 3 14 } [ -1 2 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test
{ 1 12 } [  0 2 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test
{ f f  } [  1 2 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test
{ f f  } [  2 2 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test


{ f f  } [ -2 1 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test
{ 0 11 } [ -1 1 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test
{ 2 13 } [  0 1 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test
{ 4 15 } [  1 1 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test
{ f f  } [  2 1 { 11 12 13 14 15 } [ odd? ] find-nth-from ] unit-test

{ 4 15 } [ -2 1 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test
{ 2 13 } [ -1 1 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test
{ 0 11 } [  0 1 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test
{ f f  } [  1 1 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test
{ f f  } [  2 1 { 11 12 13 14 15 } [ odd? ] find-nth-last-from ] unit-test

{ f f  } [ -2 1 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test
{ f f  } [ -1 1 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test
{ 1 12 } [  0 1 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test
{ 3 14 } [  1 1 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test
{ f f  } [  2 1 { 11 12 13 14 15 } [ even? ] find-nth-from ] unit-test

{ f f  } [ -2 1 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test
{ 3 14 } [ -1 1 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test
{ 1 12 } [  0 1 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test
{ f f  } [  1 1 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test
{ f f  } [  2 1 { 11 12 13 14 15 } [ even? ] find-nth-last-from ] unit-test

{ { -995 11 26 61 } } [
    1000 V{ 5 16 42 103 } [ - ] { } map-prior-identity-as
] unit-test

{ V{ 1 4 9 } } [
    { 1 2 3 } { 1 2 3 }
    [ 2dup 2array all-eq? [ * ] [ 2drop f ] if ]
    V{ } 2nested-filter-as
] unit-test

{ V{ 1 8 27 } } [
    { 1 2 3 } { 1 2 3 } { 1 2 3 }
    [ 3dup 3array all-eq? [ * * ] [ 3drop f ] if ]
    V{ } 3nested-filter-as
] unit-test

{ V{ 0 2 0 3 6 4 12 0 5 10 15 20 } } [
    6 [1..b)
    [ [0..b) ]
    [ 2dup [ odd? ] bi@ or [ * ] [ 2drop f ] if  ]
    2nested-filter*
] unit-test

{ 20 1 } [ { 10 20 30 } [ 20 = ] find* ] unit-test
{ f f } [ { 10 20 30 } [ 21 = ] find* ] unit-test

{ 20 1 } [ 0 { 10 20 30 } [ 20 = ] find-from* ] unit-test
{ f f } [ 0 { 10 20 30 } [ 21 = ] find-from* ] unit-test
{ 20 1 } [ 0 { 10 20 30 } [ 20 = ] find-from* ] unit-test
{ 20 1 } [ 1 { 10 20 30 } [ 20 = ] find-from* ] unit-test
{ f f } [ 2 { 10 20 30 } [ 20 = ] find-from* ] unit-test

{ 20 1 } [ { 10 20 30 } [ 20 = ] find-last* ] unit-test
{ f f } [ { } [ 21 = ] find-last* ] unit-test
{ f f } [ { 10 20 30 } [ 21 = ] find-last* ] unit-test

{ f f } [ 0 { 10 20 30 } [ 20 = ] find-last-from* ] unit-test
{ 20 1 } [ 1 { 10 20 30 } [ 20 = ] find-last-from* ] unit-test
{ 20 1 } [ 2 { 10 20 30 } [ 20 = ] find-last-from* ] unit-test

{ 20 1 } [ { 10 20 30 } [ drop 20 = ] find-index* ] unit-test
{ f f } [ { 10 20 30 } [ drop 21 = ] find-index* ] unit-test

{ 20 1 } [ 0 { 10 20 30 } [ drop 20 = ] find-index-from* ] unit-test
{ f f } [ 0 { 10 20 30 } [ drop 21 = ] find-index-from* ] unit-test

{ { { 1 1 } { 2 2 } { 0 3 } { 0 4 } { 0 5 } } } [
    { 1 2 } { 1 2 3 4 5 } 0 zip-longest-with
] unit-test

{ { { 1 1 } { 2 2 } { f 3 } { f 4 } { f 5 } } } [
    { 1 2 } { 1 2 3 4 5 } zip-longest
] unit-test

{ "34_01_" } [ 2 0 3 "01_34_" [ exchange-subseq ] keep ] unit-test
{ "cdebaf" } [ 3 0 2 "abcdef" [ exchange-subseq ] keep ] unit-test

{ { } } [ { } sequence-cartesian-product ] unit-test
{ { } } [ { { } } sequence-cartesian-product ] unit-test
{ { } } [ { { 1 2 } { } } sequence-cartesian-product ] unit-test
{ { { 1 } { 2 } } } [ { { 1 2 } } sequence-cartesian-product ] unit-test

{
    {
        { 1 3 5 6 { 9 } }
        { 1 3 5 7 { 9 } }
        { 1 4 5 6 { 9 } }
        { 1 4 5 7 { 9 } }
        { 2 3 5 6 { 9 } }
        { 2 3 5 7 { 9 } }
        { 2 4 5 6 { 9 } }
        { 2 4 5 7 { 9 } }
    }
} [
    { { 1 2 } { 3 4 } { 5 } { 6 7 } { { 9 } } } sequence-cartesian-product
] unit-test
