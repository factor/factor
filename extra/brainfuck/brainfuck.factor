! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs fry io io.streams.string kernel
macros math peg.ebnf prettyprint sequences strings ;

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

EBNF: parse-brainfuck

inc-ptr  = (">")+  => [[ length '[ _ (>) ] ]]
dec-ptr  = ("<")+  => [[ length '[ _ (<) ] ]]
inc-mem  = ("+")+  => [[ length '[ _ (+) ] ]]
dec-mem  = ("-")+  => [[ length '[ _ (-) ] ]]
output   = "."  => [[ [ (.) ] ]]
input    = ","  => [[ [ (,) ] ]]
debug    = "#"  => [[ [ (#) ] ]]
space    = (" "|"\t"|"\r\n"|"\n")+ => [[ [ ] ]]
unknown  = (.)  => [[ "Invalid input" throw ]]

ops   = inc-ptr|dec-ptr|inc-mem|dec-mem|output|input|debug|space
loop  = "[" {loop|ops}+ "]" => [[ second compose-all '[ [ (?) ] _ while ] ]]

code  = (loop|ops|unknown)*  => [[ compose-all ]]

;EBNF

PRIVATE>

MACRO: run-brainfuck ( code -- )
    [ blank? not ] filter parse-brainfuck
    '[ <brainfuck> @ drop flush ] ;

: get-brainfuck ( code -- result )
    [ run-brainfuck ] with-string-writer ; inline
