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
USE: arithmetic
USE: combinators
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: parser
USE: stack
USE: stdio
USE: strings
USE: words
USE: vocabularies

: fixnum% ( num -- )
    "base" get /mod swap dup 0 > [
        fixnum%
    ] [
        drop
    ] ifte >digit % ;

: fixnum- ( num -- num )
    dup 0 < [ "-" % neg ] when ;

: fixnum>str ( num -- str )
    <% fixnum- fixnum% %> ;

: unparse-str ( str -- str )
    #! Not done
    <% CHAR: " % % CHAR: " % %> ;

: unparse-word ( word -- str )
    word-name dup "#<unnamed>" ? ;

: unparse ( obj -- str )
    [
        [ t eq?   ] [ drop "t" ]
        [ f eq?   ] [ drop "f" ]
        [ word?   ] [ unparse-word ]
        [ fixnum? ] [ fixnum>str ]
        [ string? ] [ unparse-str ]
        [ drop t  ] [ <% "#<" % class-of % ">" % %> ]
    ] cond ;
