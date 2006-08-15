IN: temporary
USING: arrays kernel math namespaces sequences
sequences-internals strings test vectors ;

[ V{ 1 2 3 4 } ] [ 1 5 dup <slice> >vector ] unit-test
[ 3 ] [ 1 4 dup <slice> length ] unit-test
[ 2 ] [ 1 3 { 1 2 3 4 } <slice> length ] unit-test
[ V{ 2 3 } ] [ 1 3 { 1 2 3 4 } <slice> >vector ] unit-test
[ V{ 4 5 } ] [ { 1 2 3 4 5 } 2 tail-slice* >vector ] unit-test
[ V{ 3 4 } ] [ 2 4 1 10 dup <slice> subseq >vector ] unit-test
[ V{ 3 4 } ] [ 0 2 2 4 1 10 dup <slice> <slice> subseq >vector ] unit-test
[ "cba" ] [ "abcdef" 3 head-slice reverse ] unit-test

[ 5040 ] [ [ 1 2 3 4 5 6 7 ] 1 [ * ] reduce ] unit-test

[ [ 1 1 2 6 24 120 720 ] ]
[ [ 1 2 3 4 5 6 7 ] 1 [ * ] accumulate ] unit-test

[ -1 f ] [ [ ] [ ] find ] unit-test
[ 0 1 ] [ [ 1 ] [ ] find ] unit-test
[ 1 "world" ] [ [ "hello" "world" ] [ "world" = ] find ] unit-test
[ 2 3 ] [ [ 1 2 3 ] [ 2 > ] find ] unit-test
[ -1 f ] [ [ 1 2 3 ] [ 10 > ] find ] unit-test

[ 1 CHAR: e ]
[ "aeiou" "hello world" [ swap member? ] find-with ] unit-test

[ 4 CHAR: o ]
[ "aeiou" 3 "hello world" [ swap member? ] find-with* ] unit-test

[ f         ] [ 3 [ ]     member? ] unit-test
[ f         ] [ 3 [ 1 2 ] member? ] unit-test
[ t ] [ 1 [ 1 2 ] member? ] unit-test
[ t ] [ 2 [ 1 2 ] member? ] unit-test

[ t ]
[ [ "hello" "world" ] [ second ] keep memq? ] unit-test

[ 4 ] [ CHAR: x "tuvwxyz" >vector index ] unit-test 

[ -1 ] [ CHAR: x 5 "tuvwxyz" >vector index* ] unit-test 

[ -1 ] [ CHAR: a 0 "tuvwxyz" >vector index* ] unit-test

[ f ] [ [ "Hello" { } 4/3 ] [ string? ] all? ] unit-test
[ t ] [ [ ] [ ] all? ] unit-test
[ t ] [ [ "hi" t 1/2 ] [ ] all? ] unit-test

[ [ 1 2 3 ] ] [ [ 1 4 2 5 3 6 ] [ 4 < ] subset ] unit-test
[ { 4 2 6 } ] [ { 1 4 2 5 3 6 } [ 2 mod 0 = ] subset ] unit-test

[ [ 3 ] ] [ 2 [ 1 2 3 ] [ < ] subset-with ] unit-test

[ "hello world how are you" ]
[ { "hello" "world" "how" "are" "you" } " " join ]
unit-test

[ "" ] [ { } "" join ] unit-test

[ { } ] [ { } flip ] unit-test

[ { "b" "e" } ] [ 1 { { "a" "b" "c" } { "d" "e" "f" } } flip nth ] unit-test

[ { { 1 4 } { 2 5 } { 3 6 } } ]
[ { { 1 2 3 } { 4 5 6 } } flip ] unit-test

[ f ] [ [ { } { } "Hello" ] all-equal? ] unit-test
[ f ] [ [ { 2 } { } { } ] all-equal? ] unit-test
[ t ] [ [ ] all-equal? ] unit-test
[ t ] [ [ 1/2 ] all-equal? ] unit-test
[ t ] [ [ 1.0 10/10 1 ] all-equal? ] unit-test
[ t ] [ { 1 2 3 4 } [ < ] monotonic? ] unit-test
[ f ] [ { 1 2 3 4 } [ > ] monotonic? ] unit-test
[ [ 2 3 4 ] ] [ 1 [ 1 2 3 ] [ + ] map-with ] unit-test

[ 1 ] [ 0 [ 1 2 ] nth ] unit-test
[ 2 ] [ 1 [ 1 2 ] nth ] unit-test

[ [ ]           ] [ [ ]   [ ]       append ] unit-test
[ [ 1 ]         ] [ [ 1 ] [ ]       append ] unit-test
[ [ 2 ]         ] [ [ ] [ 2 ]       append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] [ 4 ] append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] { 4 } append ] unit-test

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

[ t ] [ [ 1 2 3 ] [ 1 2 3 ] sequence= ] unit-test
[ t ] [ [ 1 2 3 ] { 1 2 3 } sequence= ] unit-test
[ t ] [ { 1 2 3 } [ 1 2 3 ] sequence= ] unit-test
[ f ] [ [ ] [ 1 2 3 ] sequence= ] unit-test

[ { 1 3 2 4 } ] [ { 1 2 3 4 } clone 1 2 pick exchange ] unit-test

[ 3 ] [ { 1 2 3 4 } midpoint ] unit-test

[ -1 ] [ 3 { } [ - ] binsearch ] unit-test
[ 0 ] [ 3 { 3 } [ - ] binsearch ] unit-test
[ 1 ] [ 2 { 1 2 3 } [ - ] binsearch ] unit-test
[ 3 ] [ 4 { 1 2 3 4 5 6 } [ - ] binsearch ] unit-test
[ 1 ] [ 3.5 { 1 2 3 4 5 6 7 8 } [ - ] binsearch ] unit-test
[ 3 ] [ 5.5 { 1 2 3 4 5 6 7 8 } [ - ] binsearch ] unit-test
[ 10 ] [ 10 20 >vector [ - ] binsearch ] unit-test

: seq-sorter 0 over length 1- <sorter> ;

[ { 4 2 3 1 } ]
[ { 1 2 3 4 } clone dup seq-sorter sorter-exchange ] unit-test

[ -1 ] [ [ - ] { 1 2 3 4 } seq-sorter 1 compare ] unit-test

[ 1 ] [ [ - ] { -5 4 -3 5 } seq-sorter 2dup sort-up sorter-start nip ] unit-test

[ 3 ] [ [ - ] { -5 4 -3 -6 5 } seq-sorter 2dup sort-down sorter-end nip ] unit-test

[ { 1 2 3 4 5 6 7 8 9 } ] [
    [ - ] { 9 8 7 6 5 4 3 2 1 } clone seq-sorter 2dup sort-step
    sorter-seq >array nip
] unit-test

[ { 1 2 3 4 5 6 7 8 9 } ] [
    [ - ] { 1 2 3 4 5 6 7 8 9 } clone seq-sorter 2dup sort-step
    sorter-seq >array nip
] unit-test

[ [ ] ] [ [ ] natural-sort ] unit-test

[ t ] [
    100 [
        drop
        100 [ drop 20 random-int [ drop 1000 random-int ] map ] map natural-sort [ <=> 0 <= ] monotonic?
    ] all?
] unit-test

[ { "" "a" "aa" "aaa" } ]
[ 4 [ CHAR: a <string> ] map ]
unit-test

[ V{ } ] [ "f" V{ } clone [ delete ] keep ] unit-test
[ V{ } ] [ "f" V{ "f" } clone [ delete ] keep ] unit-test
[ V{ } ] [ "f" V{ "f" "f" } clone [ delete ] keep ] unit-test
[ V{ "x" } ] [ "f" V{ "f" "x" "f" } clone [ delete ] keep ] unit-test
[ V{ "y" "x" } ] [ "f" V{ "y" "f" "x" "f" } clone [ delete ] keep ] unit-test

[ { 1 4 9 } ] [ { 1 2 3 } clone dup [ sq ] inject ] unit-test

[ { "one" "two" "three" 4 5 6 } ]
[
    { "one" "two" "three" }
    { 1 2 3 } { 1 2 3 4 5 6 } clone [ subst ] keep
] unit-test

[ ] [ { 1 2 } [ 2drop 1 ] sort drop ] unit-test

[ 5 ] [ 1 >bignum { 1 5 7 } nth-unsafe ] unit-test
[ 5 ] [ 1 >bignum { 1 5 7 } nth-unsafe ] unit-test
[ 5 ] [ 1 >bignum "\u0001\u0005\u0007" nth-unsafe ] unit-test

[ "before&after" ] [ "&" 6 11 "before and after" replace-slice ] unit-test

[ 3 "a" ] [ { "a" "b" "c" "a" "d" } [ "a" = ] find-last ] unit-test

[ -1 f ] [ -1 { 1 2 3 } [ 1 = ] find* ] unit-test

[ 0 ] [ { "a" "b" "c" } { "A" "B" "C" } mismatch ] unit-test

[ 1 ] [ { "a" "b" "c" } { "a" "B" "C" } mismatch ] unit-test

[ -1 ] [ { "a" "b" "c" } { "a" "b" "c" } mismatch ] unit-test

[ V{ } V{ } ] [ { "a" "b" } { "a" "b" } drop-prefix [ >vector ] 2apply ] unit-test

[ V{ "C" } V{ "c" } ] [ { "a" "b" "C" } { "a" "b" "c" } drop-prefix [ >vector ] 2apply ] unit-test

[ -1 1 "abc" <slice> ] unit-test-fails

[ V{ "a" "b" } V{ } ] [ { "X" "a" "b" } { "X" } drop-prefix [ >vector ] 2apply ] unit-test

[ -1 ] [ "ab" "abc" <=> ] unit-test
[ 1 ] [ "abc" "ab" <=> ] unit-test

[ 1 4 9 16 16 V{ f 1 4 9 16 } ] [
    V{ } clone "cache-test" set
    1 "cache-test" get [ sq ] cache-nth
    2 "cache-test" get [ sq ] cache-nth
    3 "cache-test" get [ sq ] cache-nth
    4 "cache-test" get [ sq ] cache-nth
    4 "cache-test" get [ "wrong" ] cache-nth
    "cache-test" get
] unit-test

[ 1 ] [ 1/2 { 1 2 3 } nth ] unit-test

[ { } ] [ { } 0 group ] unit-test

! Pathological case
[ "ihbye" ] [ "hi" <reversed> "bye" append ] unit-test

[ 10 "hi" "bye" copy-into ] unit-test-fails

[ { 1 2 3 5 6 } ] [ 3 { 1 2 3 4 5 6 } remove-nth ] unit-test

[ V{ 1 2 3 } ]
[ 3 V{ 1 2 } clone [ push-new ] keep ] unit-test

[ V{ 1 2 3 } ]
[ 3 V{ 1 3 2 } clone [ push-new ] keep ] unit-test
