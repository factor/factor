! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs combinators io io.streams.string kernel math 
namespaces sequences strings ;

IN: brainfuck

<PRIVATE

TUPLE: brainfuck code cp dp steps memory loop ;

: (set-loop) ( brainfuck in out -- brainfuck )
    pick loop>> [ set-at ] [ [ swap ] dip set-at ] 3bi ;

SYMBOL: tmp

: <brainfuck> ( code -- brainfuck ) 
    0 0 0 H{ } clone H{ } clone brainfuck boa 
    V{ } clone tmp set
    dup code>> <enum> [ 
        {
            { CHAR: [ [ tmp get push ] }
            { CHAR: ] [ tmp get pop (set-loop) ] }
            [ 2drop ]
        } case
    ] assoc-each ;


: (get-memory) ( brainfuck -- brainfuck value ) 
    dup [ dp>> ] [ memory>> ] bi at 0 or ;

: (set-memory) ( intepreter value -- brainfuck ) 
    over [ dp>> ] [ memory>> ] bi set-at ;

: (inc-memory) ( brainfuck -- brainfuck ) 
    (get-memory) 1 + 255 bitand (set-memory) ; 

: (dec-memory) ( brainfuck -- brainfuck ) 
    (get-memory) 1 - 255 bitand (set-memory)  ; 

: (out-memory) ( brainfuck -- brainfuck )
    (get-memory) 1string write ;


: (inc-data) ( brainfuck -- brainfuck )
    [ 1 + ] change-dp ;

: (dec-data) ( brainfuck -- brainfuck )
    [ 1 - ] change-dp ;


: (loop-start) ( brainfuck -- brainfuck ) 
    (get-memory) 0 = [ dup [ cp>> ] [ loop>> ] bi at >>cp ] when ;

: (loop-end) ( brainfuck -- brainfuck ) 
    dup [ cp>> ] [ loop>> ] bi at 1 - >>cp ;


: (get-input) ( brainfuck -- brainfuck ) 
    read1 (set-memory) ;


: can-step ( brainfuck -- brainfuck t/f )
    dup [ steps>> 100000 < ] [ cp>> ] [ code>> length ] tri < and ;

: step ( brainfuck -- brainfuck ) 
    dup [ cp>> ] [ code>> ] bi nth 
    { 
        { CHAR: >  [ (inc-data) ] }
        { CHAR: <  [ (dec-data) ] }
        { CHAR: +  [ (inc-memory) ] } 
        { CHAR: -  [ (dec-memory) ] }
        { CHAR: .  [ (out-memory) ] }
        { CHAR: ,  [ (get-input) ] }
        { CHAR: [  [ (loop-start) ] }
        { CHAR: ]  [ (loop-end) ] }
        { CHAR: \s [ ] }
        { CHAR: \t [ ] }
        { CHAR: \r [ ] }
        { CHAR: \n [ ] }
        [ "invalid input" throw ] 
    } case [ 1 + ] change-cp [ 1 + ] change-steps ;

PRIVATE>

: run-brainfuck ( code -- )
    <brainfuck> [ can-step ] [ step ] while drop ;

: get-brainfuck ( code -- result )
    [ run-brainfuck ] with-string-writer ;


