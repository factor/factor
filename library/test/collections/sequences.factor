IN: temporary
USING: kernel lists math sequences sequences-internals strings
test vectors ;

[ { 1 2 3 4 } ] [ 1 5 <range> >vector ] unit-test
[ 3 ] [ 1 4 <range> length ] unit-test
[ 2 ] [ 1 3 { 1 2 3 4 } <slice> length ] unit-test
[ { 2 3 } ] [ 1 3 { 1 2 3 4 } <slice> >vector ] unit-test
[ { 4 5 } ] [ 2 { 1 2 3 4 5 } tail-slice* >vector ] unit-test
[ { 3 4 } ] [ 2 4 1 10 <range> subseq >vector ] unit-test
[ { 3 4 } ] [ 0 2 2 4 1 10 <range> <slice> subseq >vector ] unit-test
[ "cba" ] [ 3 "abcdef" head-slice reverse ] unit-test

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

[ @{ "b" "e" }@ ] [ 1 @{ @{ "a" "b" "c" }@ @{ "d" "e" "f" }@ }@ flip nth ] unit-test

[ @{ @{ 1 4 }@ @{ 2 5 }@ @{ 3 6 }@ }@ ]
[ @{ @{ 1 2 3 }@ @{ 4 5 6 }@ }@ flip ] unit-test

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

[ f ] [ 0 f head ] unit-test
[ f ] [ 0 [ 1 ] head ] unit-test
[ [ 1 2 3 ] ] [ 3 [ 1 2 3 4 ] head ] unit-test
[ f ] [ 3 [ 1 2 3 ] tail ] unit-test
[ [ 3 ] ] [ 2 [ 1 2 3 ] tail ] unit-test

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

[ 1 ] [ [ - ] { -5 4 -3 5 } seq-sorter sort-up sorter-start nip ] unit-test

[ 3 ] [ [ - ] { -5 4 -3 -6 5 } seq-sorter sort-down sorter-end nip ] unit-test

[ { 1 2 3 4 5 6 7 8 9 } ] [
    [ - ] { 9 8 7 6 5 4 3 2 1 } clone seq-sorter sort-step
    sorter-seq >vector nip
] unit-test

[ { 1 2 3 4 5 6 7 8 9 } ] [
    [ - ] { 1 2 3 4 5 6 7 8 9 } clone seq-sorter sort-step
    sorter-seq >vector nip
] unit-test

[ [ ] ] [ [ ] number-sort ] unit-test

[ t ] [
    100 [
        drop
        1000 [ drop 0 1000 random-int ] map number-sort [ <= ] monotonic?
    ] all?
] unit-test

[ @{ "" "a" "aa" "aaa" }@ ]
[ 4 [ CHAR: a fill ] map ]
unit-test

[ { } ] [ "f" { } clone [ delete ] keep ] unit-test
[ { } ] [ "f" { "f" } clone [ delete ] keep ] unit-test
[ { } ] [ "f" { "f" "f" } clone [ delete ] keep ] unit-test
[ { "x" } ] [ "f" { "f" "x" "f" } clone [ delete ] keep ] unit-test
[ { "y" "x" } ] [ "f" { "y" "f" "x" "f" } clone [ delete ] keep ] unit-test

[ { 1 4 9 } ] [ { 1 2 3 } clone dup [ sq ] inject ] unit-test

[ { 3 4 5 } ] [ 2 { 1 2 3 } clone [ [ + ] inject-with ] keep ] unit-test

[ { "one" "two" "three" 4 5 6 } ]
[
    { "one" "two" "three" }
    { 1 2 3 } { 1 2 3 4 5 6 } clone [ subst ] keep
] unit-test

[ ] [ { 1 2 } [ 2drop 1 ] sort drop ] unit-test

[ 5 ] [ 1 >bignum { 1 5 7 } nth-unsafe ] unit-test
[ 5 ] [ 1 >bignum @{ 1 5 7 }@ nth-unsafe ] unit-test
[ 5 ] [ 1 >bignum "\u0001\u0005\u0007" nth-unsafe ] unit-test
