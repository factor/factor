! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io kernel math math.parser
prettyprint random sequences sequences.extras ;
IN: math-quiz

GENERIC: question-quot ( question -- quot )
GENERIC: answer-quot ( question -- quot )

TUPLE: multiplication count n ;
SINGLETON: basic-multiplication
SINGLETON: intermediate-multiplication

M: multiplication question-quot [ count>> ] [ n>> ] bi '[ _ random 2 + ] replicate '[ _ product ] ;
M: multiplication answer-quot drop [ string>number ] ;

M: basic-multiplication question-quot drop 13 random 13 random '[ _ _ * ] ;
M: basic-multiplication answer-quot drop [ string>number ] ;

M: intermediate-multiplication question-quot drop 31 random 31 random '[ _ _ * ] ;
M: intermediate-multiplication answer-quot drop [ string>number ] ;

TUPLE: question obj question-quot answer-quot answer input input-answer correct? ;
: <question> ( obj -- question )
    question new
        swap >>obj
        dup obj>> question-quot >>question-quot
        dup obj>> answer-quot >>answer-quot
        dup question-quot>> call( -- answer ) >>answer ;

: score-question ( question input -- question/f )
    dup "q" = [
        2drop f
    ] [
        >>input
        dup [ input>> ] [ answer-quot>> ] bi call( input -- answer ) >>input-answer
        dup [ answer>> ] [ input-answer>> ] bi = >>correct?
        dup answer>> .
    ] if ;

: run-one-question ( question -- question/f )
    {
        [ question-quot>> . ]
        [ readln score-question ]
    } cleave ;

: run-quiz ( seq -- questions )
    '[ _ random <question> run-one-question ] loop>array ;

: run-basic-quiz ( -- questions )
    {
        basic-multiplication
        intermediate-multiplication
    } run-quiz ;

: run-product-quiz ( -- )
    {
        T{ multiplication { count 5 } { n 5 } }
    } run-quiz drop ;

MAIN: run-product-quiz