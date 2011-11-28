! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.smart hashtables kernel parser quotations
sequences vectors ;
IN: code-arrays

: parse-code-array ( delimiter quot stack -- seq )
    [ parse-until >quotation ] dip curry append! ;

DEFER: }}
DEFER: ]]

SYNTAX: {{ \ }} [ output>array ] parse-code-array ;

SYNTAX: [[ \ ]] [ [ ] output>sequence ] parse-code-array ;

SYNTAX: H{{ \ }} [ output>array >hashtable ] parse-code-array ;

SYNTAX: V{{ \ }} [ V{ } output>sequence ] parse-code-array ;

: vector ( seq -- vector ) >vector ;

: hashtable ( seq -- hashtable ) >hashtable ;

: quotation ( seq -- vector ) >quotation ;
