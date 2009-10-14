USING: tools.test generalizations kernel math arrays sequences
ascii fry math.parser io io.streams.string ;
IN: generalizations.tests

{ 1 2 3 4 1 } [ 1 2 3 4 4 npick ] unit-test
{ 1 2 3 4 2 } [ 1 2 3 4 3 npick ] unit-test
{ 1 2 3 4 3 } [ 1 2 3 4 2 npick ] unit-test
{ 1 2 3 4 4 } [ 1 2 3 4 1 npick ] unit-test

[ 1 1 ndup ] must-infer
{ 1 1 } [ 1 1 ndup ] unit-test
{ 1 2 1 2 } [ 1 2 2 ndup ] unit-test
{ 1 2 3 1 2 3 } [ 1 2 3 3 ndup ] unit-test
{ 1 2 3 4 1 2 3 4 } [ 1 2 3 4 4 ndup ] unit-test
[ 1 2 2 nrot ] must-infer
{ 2 1 } [ 1 2 2 nrot ] unit-test
{ 2 3 1 } [ 1 2 3 3 nrot ] unit-test
{ 2 3 4 1 } [ 1 2 3 4 4 nrot ] unit-test
[ 1 2 2 -nrot ] must-infer
{ 2 1 } [ 1 2 2 -nrot ] unit-test
{ 3 1 2 } [ 1 2 3 3 -nrot ] unit-test
{ 4 1 2 3 } [ 1 2 3 4 4 -nrot ] unit-test
[ 1 2 3 4 3 nnip ] must-infer
{ 4 } [ 1 2 3 4 3 nnip ] unit-test
[ 1 2 3 4 4 ndrop ] must-infer
{ 0 } [ 0 1 2 3 4 4 ndrop ] unit-test
[ [ 1 ] 5 ndip ] must-infer
[ 1 2 3 4 ] [ 2 3 4 [ 1 ] 3 ndip ] unit-test
[ 5 nspin ] must-infer
[ 1 5 4 3 2 ] [ 1 2 3 4 5 4 nspin ] unit-test

[ 1 2 3 4 5 [ drop drop drop drop drop 2 ] 5 nkeep ] must-infer
{ 2 1 2 3 4 5 } [ 1 2 3 4 5 [ drop drop drop drop drop 2 ] 5 nkeep ] unit-test
[ [ 1 2 3 + ] ] [ 1 2 3 [ + ] 3 ncurry ] unit-test

[ "HELLO" ] [ "hello" [ >upper ] 1 napply ] unit-test
[ { 1 2 } { 2 4 } { 3 8 } { 4 16 } { 5 32 } ] [ 1 2 3 4 5 [ dup 2^ 2array ] 5 napply ] unit-test
[ [ dup 2^ 2array ] 5 napply ] must-infer

[ { "xyc" "xyd" } ] [ "x" "y" { "c" "d" } [ 3append ] 2 nwith map ] unit-test

[ 1 2 3 4 ] [ { 1 2 3 4 } 4 firstn ] unit-test
[ { 1 2 3 4 } ] [ 1 2 3 4 { f f f f } [ 4 set-firstn ] keep ] unit-test
[ 1 2 3 4 { f f f } [ 4 set-firstn ] keep ] must-fail
[ ] [ { } 0 firstn ] unit-test
[ "a" ] [ { "a" } 1 firstn ] unit-test

[ [ 1 2 ] ] [ 1 2 2 [ ] nsequence ] unit-test

[ 4 5 1 2 3 ] [ 1 2 3 4 5 2 3 mnswap ] unit-test

[ 1 2 3 4 5 6 ] [ 1 2 3 4 5 6 2 4 mnswap 4 2 mnswap ] unit-test

[ { 1 2 3 4 } ] [ { 1 } { 2 } { 3 } { 4 } 4 nappend ] unit-test
[ V{ 1 2 3 4 } ] [ { 1 } { 2 } { 3 } { 4 } 4 V{ } nappend-as ] unit-test

[ 4 nappend ] must-infer
[ 4 { } nappend-as ] must-infer

[ 17 ] [ 3 1 3 3 7 5 nsum ] unit-test
{ 4 1 } [ 4 nsum ] must-infer-as

[ "e1" "o1" "o2" "e2" "o1" "o2" ] [ "e1" "e2" "o1" "o2" 2 nweave ] unit-test
{ 3 5 } [ 2 nweave ] must-infer-as

[ { 0 1 2 } { 3 5 4 } { 7 8 6 } ]
[ 9 [ ] each { [ 3array ] [ swap 3array ] [ rot 3array ] } 3 nspread ] unit-test

[ 1 2 3 4 1 2 3 ] [ 1 2 3 4 3 nover ] unit-test

[ [ 1 2 3 ] [ 1 2 3 ] ]
[ 1 2 3 [ ] [ ] 3 nbi-curry ] unit-test

[ 15 3 ] [ 1 2 3 4 5 [ + + + + ] [ - - - - ] 5 nbi ] unit-test

: nover-test ( -- a b c d e f g )
   1 2 3 4 3 nover ;

[ 1 2 3 4 1 2 3 ] [ nover-test ] unit-test

[ '[ number>string _ append ] 4 napply ] must-infer

: neach-test ( a b c d -- )
    [ 4 nappend print ] 4 neach ;
: nmap-test ( a b c d -- e )
    [ 4 nappend ] 4 nmap ;
: nmap-as-test ( a b c d -- e )
    [ 4 nappend ] [ ] 4 nmap-as ;
: mnmap-3-test ( a b c d -- e f g )
    [ append ] 4 3 mnmap ;
: mnmap-2-test ( a b c d -- e f )
    [ [ append ] 2bi@ ] 4 2 mnmap ;
: mnmap-as-test ( a b c d -- e f )
    [ [ append ] 2bi@ ] { } [ ] 4 2 mnmap-as ;
: mnmap-1-test ( a b c d -- e )
    [ 4 nappend ] 4 1 mnmap ;
: mnmap-0-test ( a b c d -- )
    [ 4 nappend print ] 4 0 mnmap ;

[ """A1a!
B2b@
C3c#
D4d$
""" ] [
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a" "b" "c" "d" }
    { "!" "@" "#" "$" }
    [ neach-test ] with-string-writer
] unit-test

[ { "A1a!" "B2b@" "C3c#" "D4d$" } ]
[ 
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a" "b" "c" "d" }
    { "!" "@" "#" "$" }
    nmap-test
] unit-test

[ [ "A1a!" "B2b@" "C3c#" "D4d$" ] ]
[ 
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a" "b" "c" "d" }
    { "!" "@" "#" "$" }
    nmap-as-test
] unit-test

[
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a!" "b@" "c#" "d$" }
] [ 
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a" "b" "c" "d" }
    { "!" "@" "#" "$" }
    mnmap-3-test
] unit-test

[
    { "A1" "B2" "C3" "D4" }
    { "a!" "b@" "c#" "d$" }
] [ 
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a" "b" "c" "d" }
    { "!" "@" "#" "$" }
    mnmap-2-test
] unit-test

[
    { "A1" "B2" "C3" "D4" }
    [ "a!" "b@" "c#" "d$" ]
] [ 
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a" "b" "c" "d" }
    { "!" "@" "#" "$" }
    mnmap-as-test
] unit-test

[ { "A1a!" "B2b@" "C3c#" "D4d$" } ]
[ 
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a" "b" "c" "d" }
    { "!" "@" "#" "$" }
    mnmap-1-test
] unit-test

[ """A1a!
B2b@
C3c#
D4d$
""" ] [
    { "A" "B" "C" "D" }
    { "1" "2" "3" "4" }
    { "a" "b" "c" "d" }
    { "!" "@" "#" "$" }
    [ mnmap-0-test ] with-string-writer
] unit-test

[ 6 8 10 12 ] [
    1 2 3 4
    5 6 7 8 [ + ] 4 apply-curry 4 spread*
] unit-test

[ 6 ] [ 5 [ 1 + ] 1 spread* ] unit-test
[ 6 ] [ 5 [ 1 + ] 1 cleave* ] unit-test
[ 6 ] [ 5 [ 1 + ] 1 napply  ] unit-test

[ 6 ] [ 6 0 spread* ] unit-test
[ 6 ] [ 6 0 cleave* ] unit-test
[ 6 ] [ 6 [ 1 + ] 0 napply ] unit-test

[ 6 7 8 9 ] [
    1
    5 6 7 8 [ + ] 4 apply-curry 4 cleave*
] unit-test

[ 8 3 8 3/2 ] [
    6 5 4 3
    2 [ + ] [ - ] [ * ] [ / ] 4 cleave-curry 4 spread*
] unit-test

[ 8 4 0 -3 ] [
    6 5 4  3
    2 1 0 -1 [ + ] [ - ] [ * ] [ / ] 4 spread-curry 4 spread*
] unit-test

