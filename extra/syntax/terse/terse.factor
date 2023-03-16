USING: math words ;
IN: syntax.terse

! shorthand/C-like bitwise ops
ALIAS: `& bitand
ALIAS: `| bitor
ALIAS: `^ bitxor
ALIAS: `~ bitnot
ALIAS: `<< shift
: `>> ( x n -- x/2^n ) neg shift ; inline

: 0? ( n -- n ? )   dup zero? ; inline
: 0≠ ( n -- ? )   0 = not ; inline
: != ( n n -- ? )   = not ; inline
: 0= ( n -- ? )   0 = ; inline
: 1+ ( n -- n )   1 + ; inline
: 1- ( n -- n )   1 - ; inline
: 2+ ( n -- n )   2 + ; inline
: 2- ( n -- n )   2 - ; inline
: 3+ ( n -- n )   3 + ; inline
: 3- ( n -- n )   3 - ; inline
: 4+ ( n -- n )   4 + ; inline
: 4- ( n -- n )   4 - ; inline
: 8+ ( n -- n )   8 + ; inline
: 8- ( n -- n )   8 - ; inline

                                   
