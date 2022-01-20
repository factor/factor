USING: accessors kernel math math.parser multiline peg.ebnf ;
IN: rosetta-code.arithmetic-evaluation

! http://rosettacode.org/wiki/Arithmetic_evaluation

! Create a program which parses and evaluates arithmetic
! expressions.

! Requirements

! * An abstract-syntax tree (AST) for the expression must be
!   created from parsing the input.
! * The AST must be used in evaluation, also, so the input may not
!   be directly evaluated (e.g. by calling eval or a similar
!   language feature.)
! * The expression will be a string or list of symbols like
!   "(1+3)*7".
! * The four symbols + - * / must be supported as binary operators
!   with conventional precedence rules.
! * Precedence-control parentheses must also be supported.

! Note

! For those who don't remember, mathematical precedence is as
! follows:

! * Parentheses
! * Multiplication/Division (left to right)
! * Addition/Subtraction (left to right)

TUPLE: operator left right ;
TUPLE: add < operator ;   C: <add> add
TUPLE: sub < operator ;   C: <sub> sub
TUPLE: mul < operator ;   C: <mul> mul
TUPLE: div < operator ;   C: <div> div

EBNF: expr-ast [=[
spaces   = [\n\t ]*
digit    = [0-9]
number   = (digit)+                         => [[ string>number ]]

value    =   spaces number:n                => [[ n ]]
           | spaces "(" exp:e spaces ")"    => [[ e ]]

fac      =   fac:a spaces "*" value:b       => [[ a b <mul> ]]
           | fac:a spaces "/" value:b       => [[ a b <div> ]]
           | value

exp      =   exp:a spaces "+" fac:b         => [[ a b <add> ]]
           | exp:a spaces "-" fac:b         => [[ a b <sub> ]]
           | fac

main     = exp:e spaces !(.)                => [[ e ]]
]=]

GENERIC: eval-ast ( ast -- result )

M: number eval-ast ;

: recursive-eval ( ast -- left-result right-result )
    [ left>> eval-ast ] [ right>> eval-ast ] bi ;

M: add eval-ast recursive-eval + ;
M: sub eval-ast recursive-eval - ;
M: mul eval-ast recursive-eval * ;
M: div eval-ast recursive-eval / ;

: evaluate ( string -- result )
    expr-ast eval-ast ;
