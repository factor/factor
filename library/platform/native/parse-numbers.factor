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

IN: parser
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: strings
USE: words
USE: unparser

! Number parsing

: not-a-number "Not a number" throw ;

: digit> ( ch -- n )
    [
        [ digit? ] [ CHAR: 0 - ]
        [ letter? ] [ CHAR: a - 10 + ]
        [ LETTER? ] [ CHAR: A - 10 + ]
        [ drop t ] [ not-a-number ]
    ] cond ;

: digit ( num digit base -- num )
    2dup <= [ rot * + ] [ not-a-number ] ifte ;

: (str>integer) ( str base -- num )
    over str-length 0 = [
        not-a-number
    ] [
        0 rot [ digit> pick digit ] str-each nip
    ] ifte ;

: str>integer ( str base -- num )
    swap "-" ?str-head [
        swap (str>integer) neg
    ] [
        swap (str>integer)
    ] ifte ;

: str>ratio ( str -- num )
    dup CHAR: / index-of str//
    swap 10 str>integer swap 10 str>integer / ;

: str>number ( str -- num )
    #! Affected by "base" variable.
    [
        [ "/" swap str-contains? ] [ str>ratio      ]
        [ "." swap str-contains? ] [ str>float      ]
        [ drop t                 ] [ 10 str>integer ]
    ] cond ;

: base> ( str base -- num/f )
    [ str>integer ] [ [ 2drop f ] when ] catch ;

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

! Something really sucks about these words here
: parse-number ( str -- num )
    [ str>number ] [ [ drop f ] when ] catch ;
