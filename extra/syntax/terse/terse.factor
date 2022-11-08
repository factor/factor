USING: math words ;
IN: syntax.terse

! shorthand/C-like bitwise ops
ALIAS: `& bitand
ALIAS: `| bitor
ALIAS: `^ bitxor
ALIAS: `~ bitnot
ALIAS: `<< shift
: `>> ( x n -- x/2^n ) neg shift ; inline
