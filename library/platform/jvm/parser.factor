! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: parser
USE: errors
USE: namespaces
USE: stack
USE: streams
USE: strings

: parse-file ( file -- list )
    dup <freader> parse-stream ;

: run-file ( path -- )
    parse-file call ;

: parse-resource* ( resource -- list )
    dup <rreader> swap "resource:" swap cat2 swap parse-stream ;

: parse-resource ( file -- )
     #! Override this to be slightly more useful for development.
    global [ "resource-path" get ] bind dup [
        swap cat2 parse-file
    ] [
        drop parse-resource*
    ] ifte ;

: <custom-parser> ( filename reader interactive docs -- parser )
    interpreter
    [
        "java.lang.String"
        "java.io.BufferedReader"
        "boolean"
        "boolean"
        "factor.FactorInterpreter"
    ]
    "factor.FactorReader" jnew ;

: interactive-parse-stream ( filename reader -- list )
    #! Reads until end-of-file from the reader, building a parse
    #! tree. The filename is used for error reporting.
    #!
    #! This form should be used by the outer interpreter only.
    #! Its default vocabularies are:
    #! global [ "use" get ] bind
    #! global [ "in" get  ] bind
    f t <custom-parser> parse* ;

: (run-file) ( path -- )
    dup <freader> interactive-parse-stream call ;

: parse ( str -- list )
    #! Parse a string using an interactive parser.
    "<interactive>" swap <sreader> <breader> interactive-parse-stream ;

: eval ( "X" -- X )
    parse call ;

: base> ( str base -- num )
    #! Parse a number in a specified base.
    [ "java.lang.String" "int" ]
    "factor.math.NumberParser"
    "parseNumber"
    jinvoke-static ;

: bin> ( str -- num )
    #! Convert a binary string to a number.
    2 base> ;

: oct> ( str -- num )
    #! Convert an octal string to a number.
    8 base> ;

: dec> ( str -- num )
    #! Convert a decimal string to a number.
    10 base> ;

: hex> ( str -- num )
    #! Convert a hexadecimal string to a number.
    16 base> ;

: str>number ( str -- num )
    dup "base" get base> dup [
        nip
    ] [
        drop "Not a number: " swap cat2 throw
    ] ifte ;
