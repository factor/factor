! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs command-line fry io io.encodings.binary
io.files io.streams.string kernel macros math namespaces
peg.ebnf prettyprint sequences multiline ;

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

: (?) ( brainfuck -- brainfuck t/f )
    get-memory zero? not ;

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

: compose-all ( seq -- quot )
    [ ] [ compose ] reduce ;

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
loop  = "[" {loop|ops}+ "]" => [[ second compose-all '[ [ (?) ] _ while ] ]]

code  = (loop|ops|unknown)*  => [[ compose-all ]]

]=]

PRIVATE>

MACRO: run-brainfuck ( code -- quot )
    parse-brainfuck '[ <brainfuck> @ drop flush ] ;

: get-brainfuck ( code -- result )
    [ run-brainfuck ] with-string-writer ; inline

<PRIVATE

: (run-brainfuck) ( code -- )
    [ <brainfuck> ] dip parse-brainfuck call( x -- x ) drop flush ;

PRIVATE>

: brainfuck-main ( -- )
    command-line get [
        contents (run-brainfuck)
    ] [
        [ binary file-contents (run-brainfuck) ] each
    ] if-empty ;

MAIN: brainfuck-main
