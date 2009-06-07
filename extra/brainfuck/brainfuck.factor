! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs fry io io.streams.string kernel macros math 
peg.ebnf quotations sequences strings ;

IN: brainfuck

<PRIVATE

TUPLE: brainfuck pointer memory ops ;

: <brainfuck> ( -- brainfuck ) 
    0 H{ } clone 0 brainfuck boa ;

: max-ops? ( brainfuck -- brainfuck ) 
    [ 1 + dup 10000 > [ "Max operations" throw ] when ] change-ops ;

: get-memory ( brainfuck -- brainfuck value )
    dup [ pointer>> ] [ memory>> ] bi at 0 or ;

: set-memory ( brainfuck value -- brainfuck )
    over [ pointer>> ] [ memory>> ] bi set-at ;

: (+) ( brainfuck -- brainfuck )
    get-memory 1 + 255 bitand set-memory max-ops? ;

: (-) ( brainfuck -- brainfuck )
    get-memory 1 - 255 bitand set-memory max-ops? ;

: (?) ( brainfuck -- brainfuck t/f )
    max-ops? get-memory 0 = not ;

: (.) ( brainfuck -- brainfuck )
    get-memory 1string write max-ops? ;

: (,) ( brainfuck -- brainfuck )
    read1 set-memory max-ops? ;

: (>) ( brainfuck -- brainfuck )
    [ 1 + ] change-pointer max-ops? ;

: (<) ( brainfuck -- brainfuck ) 
    [ 1 - ] change-pointer max-ops? ;

: compose-all ( seq -- quot ) 
    [ ] [ compose ] reduce ;

EBNF: parse-brainfuck

inc-ptr  = ">"  => [[ [ (>) ] ]]
dec-ptr  = "<"  => [[ [ (<) ] ]]
inc-mem  = "+"  => [[ [ (+) ] ]]
dec-mem  = "-"  => [[ [ (-) ] ]]
output   = "."  => [[ [ (.) ] ]]
input    = ","  => [[ [ (,) ] ]]
space    = (" "|"\t"|"\r\n"|"\n") => [[ [ ] ]] 
unknown  = (.)  => [[ "Invalid input" throw ]]

ops   = inc-ptr | dec-ptr | inc-mem | dec-mem | output | input | space
loop  = "[" {loop|ops}* "]" => [[ second compose-all 1quotation [ [ (?) ] ] prepend [ while ] append ]]

code  = (loop|ops|unknown)*  => [[ compose-all ]]

;EBNF

PRIVATE>

MACRO: run-brainfuck ( code -- )
    [ <brainfuck> ] swap parse-brainfuck [ drop flush ] 3append ;

: get-brainfuck ( code -- result ) 
    [ run-brainfuck ] with-string-writer ; inline 

