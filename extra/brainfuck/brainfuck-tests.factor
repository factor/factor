! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: brainfuck multiline tools.test ;


[ "Hello World!\n" ] [ <" ++++++++++[>+++++++>++++++++++>+++>+<<<<-]
                          >++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.
                          ------.--------.>+.>. "> get-brainfuck ] unit-test

