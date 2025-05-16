! Copyright (C) 2009 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs combinators command-line io
io.encodings.binary io.files io.streams.string kernel lexer math
multiline namespaces parser peg.ebnf prettyprint quotations
sequences words ;

IN: brainfuck

<PRIVATE

TUPLE: brainfuck pointer memory ;

: <brainfuck> ( -- brainfuck )
    0 H{ } clone brainfuck boa ;

: get-memory ( brainfuck -- brainfuck value )
    dup [ pointer>> ] [ memory>> ] bi at 0 or ;

: set-memory ( brainfuck value -- brainfuck )
    over [ pointer>> ] [ memory>> ] bi set-at ;

: (+) ( brainfuck n -- brainfuck )
    [ get-memory ] dip + 255 bitand set-memory ;

: (-) ( brainfuck n -- brainfuck )
    [ get-memory ] dip - 255 bitand set-memory ;

: (.) ( brainfuck -- brainfuck )
    get-memory write1 ;

: (,) ( brainfuck -- brainfuck )
    read1 set-memory ;

: (>) ( brainfuck n -- brainfuck )
    '[ _ + ] change-pointer ;

: (<) ( brainfuck n -- brainfuck )
    '[ _ - ] change-pointer ;

: (#) ( brainfuck -- brainfuck )
    dup
    [ "ptr=" write pointer>> pprint ]
    [ ",mem=" write memory>> pprint nl ] bi ;

EBNF: parse-brainfuck [=[

inc-ptr  = (">")+  => [[ length '[ _ (>) ] ]]
dec-ptr  = ("<")+  => [[ length '[ _ (<) ] ]]
inc-mem  = ("+")+  => [[ length '[ _ (+) ] ]]
dec-mem  = ("-")+  => [[ length '[ _ (-) ] ]]
output   = "."  => [[ [ (.) ] ]]
input    = ","  => [[ [ (,) ] ]]
debug    = "#"  => [[ [ (#) ] ]]
space    = [ \t\n\r]+ => [[ [ ] ]]
unknown  = (.)  => [[ "Invalid input" throw ]]

ops   = inc-ptr|dec-ptr|inc-mem|dec-mem|output|input|debug|space
loop  = "[" {loop|ops}+ "]" => [[ second compose-all '[ [ get-memory zero? ] _ until ] ]]

code  = (loop|ops|unknown)*  => [[ compose-all ]]

]=]

PRIVATE>

MACRO: run-brainfuck ( code -- quot )
    parse-brainfuck '[ <brainfuck> @ drop flush ] ;

: get-brainfuck ( code -- result )
    [ run-brainfuck ] with-string-writer ; inline

SYNTAX: BRAINFUCK:
    scan-new-word ";" parse-tokens concat
    '[ _ run-brainfuck ] ( -- ) define-declared ;

<PRIVATE

: end-loop ( str i -- str j/f )
    CHAR: ] swap pick index-from dup [ 1 + ] when ;

: start-loop ( str i -- str j/f )
    1 - CHAR: [ swap pick last-index-from dup [ 1 + ] when ;

: interpret-brainfuck-at ( str i brainfuck -- str next/f brainfuck )
    2over swap ?nth [ 1 + ] 2dip {
        { CHAR: > [ 1 (>) ] }
        { CHAR: < [ 1 (<) ] }
        { CHAR: + [ 1 (+) ] }
        { CHAR: - [ 1 (-) ] }
        { CHAR: . [ (.) ] }
        { CHAR: , [ (,) ] }
        { CHAR: # [ (#) ] }
        { CHAR: [ [ get-memory zero? [ [ end-loop ] dip ] when ] }
        { CHAR: ] [ get-memory zero? [ [ start-loop ] dip ] unless ] }
        { f [ [ drop f ] dip ] }
        [ blank? [ "Invalid input" throw ] unless ]
    } case ;

PRIVATE>

: interpret-brainfuck ( str -- )
    0 <brainfuck> [ interpret-brainfuck-at over ] loop 3drop ;

<PRIVATE

: (run-brainfuck) ( code -- )
    [ <brainfuck> ] dip parse-brainfuck call( x -- x ) drop flush ;

PRIVATE>

: brainfuck-main ( -- )
    command-line get [
        read-contents (run-brainfuck)
    ] [
        [ binary file-contents (run-brainfuck) ] each
    ] if-empty ;

MAIN: brainfuck-main
