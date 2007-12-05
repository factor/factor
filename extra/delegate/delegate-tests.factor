USING: delegate kernel arrays tools.test ;

TUPLE: hello this that ;
C: <hello> hello

TUPLE: goodbye these those ;
C: <goodbye> goodbye

GENERIC: foo ( x -- y )
GENERIC: bar ( a -- b )
PROTOCOL: baz foo bar ;

CONSULT: baz goodbye goodbye-these ;
M: hello foo hello-this ;
M: hello bar dup hello? swap hello-that 2array ;

GENERIC: bing ( c -- d )
CONSULT: hello goodbye goodbye-these ;
M: hello bing dup hello? swap hello-that 2array ;
MIMIC: bing goodbye hello

[ 1 { t 0 } ] [ 1 0 <hello> [ foo ] keep bar ] unit-test
[ { t 0 } ] [ 1 0 <hello> bing ] unit-test
[ 1 ] [ 1 0 <hello> f <goodbye> foo ] unit-test
[ { t 0 } ] [ 1 0 <hello> f <goodbye> bar ] unit-test
[ { f 0 } ] [ 1 0 <hello> f <goodbye> bing ] unit-test
