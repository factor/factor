! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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

IN: unparser
USE: combinators
USE: kernel
USE: format
USE: lists
USE: logic
USE: math
USE: namespaces
USE: parser
USE: stack
USE: stdio
USE: strings
USE: words

: integer% ( num radix -- )
    tuck /mod >digit % dup 0 > [
        swap integer%
    ] [
        2drop
    ] ifte ;

: integer- ( num -- num )
    dup 0 < [ "-" % neg ] when ;

: >base ( num radix -- string )
    #! Convert a number to a string in a certain base.
    <% over 0 < [
        swap neg swap integer% CHAR: - %
    ] [
        integer%
    ] ifte reverse%> ;

: >dec ( num -- string )
    #! Convert an integer to its decimal representation.
    10 >base ;

: >bin ( num -- string )
    #! Convert an integer to its binary representation.
    2 >base ;

: >oct ( num -- string )
    #! Convert an integer to its octal representation.
    8 >base ;

: >hex ( num -- string )
    #! Convert an integer to its hexadecimal representation.
    16 >base ;

DEFER: unparse

: unparse-ratio ( num -- str )
    <% dup
    numerator unparse %
    CHAR: / %
    denominator unparse % %> ;

: unparse-complex ( num -- str )
    >rect <% "#{ " % swap unparse % " " % unparse % " }" % %> ;

: ch>ascii-escape ( ch -- esc )
    [
        [ CHAR: \e | "\\e" ]
        [ CHAR: \n | "\\n" ]
        [ CHAR: \r | "\\r" ]
        [ CHAR: \t | "\\t" ]
        [ CHAR: \0 | "\\0" ]
        [ CHAR: \\ | "\\\\" ]
        [ CHAR: \" | "\\\"" ]
    ] assoc ;

: ch>unicode-escape ( ch -- esc )
    >hex 4 digits "\\u" swap cat2 ;

: unparse-ch ( ch -- ch/str )
    dup quotable? [
        dup ch>ascii-escape dup [
            nip
        ] [
            drop ch>unicode-escape
        ] ifte
    ] unless ;

: unparse-str ( str -- str )
    <% CHAR: " % [ unparse-ch % ] str-each CHAR: " % %> ;

: unparse-word ( word -- str )
    word-name dup "#<unnamed>" ? ;

: fix-float ( str -- str )
    #! This is terrible. Will go away when we do our own float
    #! output.
    "." over str-contains? [ ".0" cat2 ] unless ;

: unparse ( obj -- str )
    [
        [ t eq?    ] [ drop "t" ]
        [ f eq?    ] [ drop "f" ]
        [ word?    ] [ unparse-word ]
        [ integer? ] [ >dec ]
        [ ratio?   ] [ unparse-ratio ]
        [ float?   ] [ unparse-float fix-float ]
        [ complex? ] [ unparse-complex ]
        [ string?  ] [ unparse-str ]
        [ drop t   ] [ <% "#<" % type-of type-name % ">" % %> ]
    ] cond ;
