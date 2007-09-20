USING: kernel math sequences namespaces math-contrib ;
IN: crypto-internals

! http://en.wikipedia.org/wiki/RC4_%28cipher%29

SYMBOL: i
SYMBOL: j
SYMBOL: s
SYMBOL: key
SYMBOL: l


! key scheduling algorithm, initialize s
: ksa ( -- )
    256 [ ] map s set
    0 j set
    256 [
        dup s get nth j get + over l get mod key get nth + 255 bitand j set
        dup j get s get exchange
    ] repeat ;

: generate ( -- n )
    i get 1+ 255 bitand i set
    j get i get s get nth + 255 bitand j set
    i get j get s get exchange
    i get s get nth j get s get nth + 255 bitand s get nth ;

IN: crypto

: rc4 ( key -- )
    [ key set ] keep
    length l set
    ksa
    0 i set
    0 j set ;

