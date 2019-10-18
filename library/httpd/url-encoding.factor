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

IN: url-encoding
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: format
USE: math
USE: parser
USE: stack
USE: strings
USE: unparser

: url-encode ( str -- str )
    [
        dup url-quotable? [ "%" swap >hex 2 digits cat2 ] unless
    ] str-map ;

: catch-hex> ( str -- n )
    #! Push f if string is not a valid hex literal.
    [ hex> ] [ [ drop f ] when ] catch ;

: url-decode-hex ( index str -- )
    2dup str-length 2 - >= [
        2drop
    ] [
        >r succ dup 2 + r> substring  catch-hex> [ , ] when*
    ] ifte ;

: url-decode-% ( index str -- index str )
    2dup url-decode-hex >r 3 + r> ;

: url-decode-+-or-other ( index str ch -- index str )
    CHAR: + CHAR: \s replace , >r succ r> ;

: url-decode-iter ( index str -- )
    2dup str-length >= [
        2drop
    ] [
        2dup str-nth dup CHAR: % = [
            drop url-decode-%
        ] [
            url-decode-+-or-other
        ] ifte url-decode-iter
    ] ifte ;

: url-decode ( str -- str )
    [ 0 swap url-decode-iter ] make-string ;
