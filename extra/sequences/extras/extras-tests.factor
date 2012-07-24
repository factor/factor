USING: ascii kernel make math sequences sequences.extras strings
tools.test ;

IN: sequences.extras.tests

[ 1 ] [ 1 2 [ ] min-by ] unit-test
[ 2 ] [ 1 2 [ ] max-by ] unit-test
[ "12345" ] [ "123" "12345" [ length ] max-by ] unit-test
[ "123" ] [ "123" "12345" [ length ] min-by ] unit-test

[ 4 ] [ 5 iota [ ] maximum ] unit-test
[ 0 ] [ 5 iota [ ] minimum ] unit-test
[ { "foo" } ] [ { { "foo" } { "bar" } } [ first ] maximum ] unit-test
[ { "bar" } ] [ { { "foo" } { "bar" } } [ first ] minimum ] unit-test

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
