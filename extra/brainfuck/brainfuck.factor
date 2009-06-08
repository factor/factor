! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs fry io io.streams.string kernel macros math 
peg.ebnf prettyprint quotations sequences strings ;

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
    get-memory 0 = not ;

: (.) ( brainfuck -- brainfuck )
    get-memory 1string write ;

: (,) ( brainfuck -- brainfuck )
    read1 set-memory ;

: (>) ( brainfuck n -- brainfuck )
    [ dup pointer>> ] dip + >>pointer ;

: (<) ( brainfuck n -- brainfuck ) 
    [ dup pointer>> ] dip - >>pointer ;

: (#) ( brainfuck -- brainfuck ) 
    dup 
    [ "ptr=" write pointer>> pprint ] 
    [ ",mem=" write memory>> pprint nl ] bi ;

: compose-all ( seq -- quot ) 
    [ ] [ compose ] reduce ;

EBNF: parse-brainfuck

inc-ptr  = (">")+  => [[ length 1quotation [ (>) ] append ]]
dec-ptr  = ("<")+  => [[ length 1quotation [ (<) ] append ]]
inc-mem  = ("+")+  => [[ length 1quotation [ (+) ] append ]]
dec-mem  = ("-")+  => [[ length 1quotation [ (-) ] append ]]
output   = "."  => [[ [ (.) ] ]]
input    = ","  => [[ [ (,) ] ]]
debug    = "#"  => [[ [ (#) ] ]]
space    = (" "|"\t"|"\r\n"|"\n")+ => [[ [ ] ]] 
unknown  = (.)  => [[ "Invalid input" throw ]]

ops   = inc-ptr|dec-ptr|inc-mem|dec-mem|output|input|debug|space
loop  = "[" {loop|ops}+ "]" => [[ second compose-all 1quotation [ [ (?) ] ] prepend [ while ] append ]]

code  = (loop|ops|unknown)*  => [[ compose-all ]]

;EBNF

PRIVATE>

MACRO: run-brainfuck ( code -- )
    [ <brainfuck> ] swap parse-brainfuck [ drop flush ] 3append ;

: get-brainfuck ( code -- result ) 
    [ run-brainfuck ] with-string-writer ; inline 

