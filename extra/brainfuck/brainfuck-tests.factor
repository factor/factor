! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: brainfuck io.streams.string multiline tools.test ;


[ "+" run-brainfuck ] must-infer
[ "+" get-brainfuck ] must-infer

! Hello World!

[ "Hello World!\n" ] [ <" ++++++++++[>+++++++>++++++++++>+++>+<<<<-]
                          >++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.
                          ------.--------.>+.>. "> get-brainfuck ] unit-test

! Addition (single-digit)

[ "8" ] [ "35" [ ",>++++++[<-------->-],[<+>-]<." 
          get-brainfuck ] with-string-reader ] unit-test

! Multiplication (single-digit)

[ "8\0" ] [ "24" [ <" ,>,>++++++++[<------<------>>-]
                    <<[>[>+>+<<-]>>[<<+>>-]<<<-]
                    >>>++++++[<++++++++>-],<.>. "> 
          get-brainfuck ] with-string-reader ] unit-test

! Division (single-digit, integer)

[ "3" ] [ "62" [ <" ,>,>++++++[-<--------<-------->>]
                    <<[
                    >[->+>+<<]
                    >[-<<-
                    [>]>>>[<[>>>-<<<[-]]>>]<<]
                    >>>+
                    <<[-<<+>>]
                    <<<]
                    >[-]>>>>[-<<<<<+>>>>>]
                    <<<<++++++[-<++++++++>]<. ">
           get-brainfuck ] with-string-reader ] unit-test 

! Uppercase

[ "A" ] [ "a\n" [ ",----------[----------------------.,----------]"
          get-brainfuck ] with-string-reader ] unit-test 

! cat

[ "ABC" ] [ "ABC\0" [ ",[.,]" get-brainfuck ] with-string-reader ] unit-test


