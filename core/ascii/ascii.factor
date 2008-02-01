! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences math kernel ;
IN: ascii

: blank? ( ch -- ? ) " \t\n\r" member? ; inline

: letter? ( ch -- ? ) CHAR: a CHAR: z between? ; inline

: LETTER? ( ch -- ? ) CHAR: A CHAR: Z between? ; inline

: digit? ( ch -- ? ) CHAR: 0 CHAR: 9 between? ; inline

: printable? ( ch -- ? ) CHAR: \s CHAR: ~ between? ; inline

: control? ( ch -- ? )
    "\0\e\r\n\t\u000008\u00007f" member? ; inline

: quotable? ( ch -- ? )
    dup printable? [ "\"\\" member? not ] [ drop f ] if ; inline

: Letter? ( ch -- ? )
    dup letter? [ drop t ] [ LETTER? ] if ; inline

: alpha? ( ch -- ? )
    dup Letter? [ drop t ] [ digit? ] if ; inline


