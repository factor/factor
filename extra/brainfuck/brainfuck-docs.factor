! Copyright (C) 2009 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup brainfuck strings ;

IN: brainfuck

HELP: run-brainfuck
{ $values { "code" string } }
{ $description
    "A brainfuck program is a sequence of eight commands that are "
    "executed sequentially. An instruction pointer begins at the first "
    "command, and each command is executed until the program terminates "
    "when the instruction pointer moves beyond the last command.\n"
    "\n"
    "The eight language commands, each consisting of a single character, "
    "are the following:\n"
    { $table
        { { $strong "Character" } { $strong "Meaning" } }
        { ">" "increment the data pointer (to point to the next cell to the right)." }
        { "<" "decrement the data pointer (to point to the next cell to the left)." }
        { "+" "increment (increase by one) the byte at the data pointer." }
        { "-" "decrement (decrease by one) the byte at the data pointer." }
        { "." "output the value of the byte at the data pointer." }
        { "," "accept one byte of input, storing its value in the byte at the data pointer." }
        { "[" "if the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command*." }
        { "]" "if the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command*." }
    }
    "\n"
    "Brainfuck programs can be translated into C using the following "
    "substitutions, assuming ptr is of type unsigned char* and has been "
    "initialized to point to an array of zeroed bytes:\n"
    { $table
        { { $strong "Character" } { $strong "C equivalent" } }
        { ">" "++ptr;" }
        { "<" "--ptr;" }
        { "+" "++*ptr;" }
        { "-" "--*ptr;" }
        { "." "putchar(*ptr);" }
        { "," "*ptr=getchar();" }
        { "[" "while (*ptr) {" }
        { "]" "}" }
    }
} ;

HELP: get-brainfuck
{ $values { "code" string } { "result" string } }
{ $description "Returns the output from a brainfuck program as a result string." }
{ $see-also run-brainfuck } ;
