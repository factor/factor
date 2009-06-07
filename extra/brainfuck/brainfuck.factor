! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs fry io io.streams.string kernel macros math peg.ebnf sequences strings ;

IN: brainfuck

<PRIVATE

TUPLE: brainfuck ptr mem ops ;

: <brainfuck> ( -- brainfuck ) 
    0 H{ } clone 0 brainfuck boa ;

: ops? ( brainfuck -- brainfuck ) 
    [ 1 + ] change-ops
    dup ops>> 10000 > [ "Max operations" throw ] when ;

: (get-mem) ( brainfuck -- brainfuck value )
    dup [ ptr>> ] [ mem>> ] bi at 0 or ;

: (set-mem) ( brainfuck value -- brainfuck )
    over [ ptr>> ] [ mem>> ] bi set-at ;

: mem++ ( brainfuck -- brainfuck )
    (get-mem) 1 + 255 bitand (set-mem) ops? ;

: mem-- ( brainfuck -- brainfuck )
    (get-mem) 1 - 255 bitand (set-mem) ops? ;

: mem? ( brainfuck -- brainfuck t/f )
    ops? (get-mem) 0 = not ;

: out ( brainfuck -- brainfuck )
    (get-mem) 1string write ops? ;

: in ( brainfuck -- brainfuck )
    read1 (set-mem) ops? ;

: ptr++ ( brainfuck -- brainfuck )
    [ 1 + ] change-ptr ops? ;

: ptr-- ( brainfuck -- brainfuck )
    [ 1 - ] change-ptr ops? ;

: compose-all ( seq -- quot ) 
    [ ] [ compose ] reduce ;

EBNF: parse-brainfuck

inc-ptr  = ">"  => [[ [ ptr++ ] ]]
dec-ptr  = "<"  => [[ [ ptr-- ] ]]
inc-mem  = "+"  => [[ [ mem++ ] ]]
dec-mem  = "-"  => [[ [ mem-- ] ]]
output   = "."  => [[ [ out ] ]]
input    = ","  => [[ [ in ] ]]
space    = (" "|"\t"|"\r\n"|"\n") => [[ [ ] ]] 
unknown  = (.)  => [[ "Invalid input" throw ]]

ops   = inc-ptr | dec-ptr | inc-mem | dec-mem | output | input | space
loop  = "[" {loop|ops}* "]" => [[ second compose-all '[ [ mem? ] _ while ] ]]

code  = (loop|ops|unknown)*  => [[ compose-all ]]

;EBNF

PRIVATE>

MACRO: run-brainfuck ( code -- )
    [ <brainfuck> ] swap parse-brainfuck [ drop flush ] 3append ;

: get-brainfuck ( code -- result ) 
    [ run-brainfuck ] with-string-writer ; inline 

