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
    2dup < [ rot * + ] [ not-a-number ] ifte ;

: (base>) ( base str -- num )
    dup str-length 0 = [
        not-a-number
    ] [
        0 swap [ digit> pick digit ] str-each nip
    ] ifte ;

: base> ( str base -- num )
    #! Convert a string to an integer. Throw an error if
    #! conversion fails.
    swap "-" ?str-head [ (base>) neg ] [ (base>) ] ifte ;

: str>ratio ( str -- num )
    dup CHAR: / index-of str// swap 10 base> swap 10 base> / ;

: str>number ( str -- num )
    #! Convert a string to a number; throws errors.
    [
        [ "/" swap str-contains? ] [ str>ratio ]
        [ "." swap str-contains? ] [ str>float ]
        [ drop t                 ] [ 10 base>  ]
    ] cond ;

: parse-number ( str -- num )
    #! Convert a string to a number; return f on error.
    [ str>number ] [ [ drop f ] when ] catch ;

: bin> 2 base> ;
: oct> 8 base> ;
: dec> 10 base> ;
: hex> 16 base> ;
