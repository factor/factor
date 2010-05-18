! (c)2009 Joe Groff bsd license
USING: tools.test generalizations kernel math arrays sequences
sequences.generalizations ascii fry math.parser io io.streams.string ;
IN: sequences.generalizations.tests

[ 1 2 3 4 ] [ { 1 2 3 4 } 4 firstn ] unit-test
[ { 1 2 3 4 } ] [ 1 2 3 4 { f f f f } [ 4 set-firstn ] keep ] unit-test
[ 1 2 3 4 { f f f } [ 4 set-firstn ] keep ] must-fail
[ ] [ { } 0 firstn ] unit-test
[ "a" ] [ { "a" } 1 firstn ] unit-test

[ [ 1 2 ] ] [ 1 2 2 [ ] nsequence ] unit-test

[ { 1 2 3 4 } ] [ { 1 } { 2 } { 3 } { 4 } 4 nappend ] unit-test
[ V{ 1 2 3 4 } ] [ { 1 } { 2 } { 3 } { 4 } 4 V{ } nappend-as ] unit-test

[ 4 nappend ] must-infer
[ 4 { } nappend-as ] must-infer

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
: nproduce-as-test ( n -- a b )
    [ dup zero? not ]
    [ [ 2 - ] [ ] [ 1 - ] tri ] { } B{ } 2 nproduce-as
    [ drop ] 2dip ;
: nproduce-test ( n -- a b )
    [ dup zero? not ]
    [ [ 2 - ] [ ] [ 1 - ] tri ] 2 nproduce
    [ drop ] 2dip ;

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

[ { 10 8 6 4 2 } B{ 9 7 5 3 1 } ]
[ 10 nproduce-as-test ] unit-test

[ { 10 8 6 4 2 } { 9 7 5 3 1 } ]
[ 10 nproduce-test ] unit-test
