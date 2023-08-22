! Copyright (C) 2009 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: brainfuck io.streams.string kernel literals math
math.parser ranges sequences splitting tools.test ;

[ "+" run-brainfuck ] must-infer
[ "+" get-brainfuck ] must-infer

! Hello World!

{ "Hello World!\n" } [
    "
    ++++++++++[>+++++++>++++++++++>+++>+<<<<-]
    >++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.
    ------.--------.>+.>.
    " get-brainfuck
] unit-test

! Addition (single-digit)

{ "8" } [
    "35" [
        ",>++++++[<-------->-],[<+>-]<." get-brainfuck
    ] with-string-reader
] unit-test

! Multiplication (single-digit)

{ "8\0" } [
    "24" [
        "
        ,>,>++++++++[<------<------>>-]
        <<[>[>+>+<<-]>>[<<+>>-]<<<-]
        >>>++++++[<++++++++>-],<.>.
        " get-brainfuck
    ] with-string-reader
] unit-test

! Division (single-digit, integer)

{ "3" } [
    "62" [
        "
        ,>,>++++++[-<--------<-------->>]
        <<[
        >[->+>+<<]
        >[-<<-
        [>]>>>[<[>>>-<<<[-]]>>]<<]
        >>>+
        <<[-<<+>>]
        <<<]
        >[-]>>>>[-<<<<<+>>>>>]
        <<<<++++++[-<++++++++>]<.
        " get-brainfuck
    ] with-string-reader
] unit-test

! Uppercase

{ "A" } [ "a\n" [ ",----------[----------------------.,----------]"
          get-brainfuck ] with-string-reader ] unit-test

! cat

{ "ABC" } [ "ABC\0" [ ",[.,]" get-brainfuck ] with-string-reader ] unit-test

! Squares of numbers from 0 to 100

${ 100 [0..b] [ dup * number>string ] map join-lines "\n" append }
[
    "
    ++++[>+++++<-]>[<+++++>-]+<+[
    >[>+>+<<-]++>>[<<+>>-]>>>[-]++>[-]+
    >>>+[[-]++++++>>>]<<<[[<++++++++<++>>-]+<.<[>----<-]<]
    <<[>>>>>[>>>[-]+++++++++<[>-<-]+++++++++>
    [-[<->-]+[<<<]]<[>+<-]>]<<-]<<-]
    " get-brainfuck
] unit-test

! fun with numbers: 2 + 2 = 5

{ "5" } [
    "
    +++++           +++++
        +               +
        +     +         +     +++++
    +++++    +++    +++++
    +         +     +         +++++
    +               +
    +++++           +++++.
    " get-brainfuck
] unit-test
