! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: streams
USE: errors
USE: kernel
USE: namespaces
USE: strings
USE: generic
USE: lists

GENERIC: fflush      ( stream -- )
GENERIC: fauto-flush ( stream -- )
GENERIC: freadln     ( stream -- string )
GENERIC: fread#      ( count stream -- string )
GENERIC: fwrite-attr ( string style stream -- )
GENERIC: fclose      ( stream -- )

: fread1 ( stream -- char/f )
    1 swap fread#
    dup f-or-"" [ drop f ] [ 0 swap str-nth ] ifte ;

: fwrite ( string stream -- )
    f swap fwrite-attr ;

: fprint ( string stream -- )
    tuck fwrite "\n" over fwrite fauto-flush ;

TRAITS: string-output-stream

M: string-output-stream fwrite-attr ( string style stream -- )
    [ drop "buf" get sbuf-append ] bind ;

M: string-output-stream fclose ( stream -- )
    drop ;

M: string-output-stream fflush ( stream -- )
    drop ;

M: string-output-stream fauto-flush ( stream -- )
    drop ;

: stream>str ( stream -- string )
    #! Returns the string written to the given string output
    #! stream.
    [ "buf" get ] bind sbuf>str ;

C: string-output-stream ( size -- stream )
    #! Creates a new stream for writing to a string buffer.
    [ <sbuf> "buf" set ] extend ;

! Prefix stream prefixes each line with a given string.
TRAITS: prefix-stream
SYMBOL: prefix
SYMBOL: last-newline

M: prefix-stream fwrite-attr ( string style stream -- )
    [
        last-newline get [
            prefix get delegate get fwrite last-newline off
        ] when

        dupd delegate get fwrite-attr

        "\n" str-tail? [
            last-newline on
        ] when
    ] bind ;

C: prefix-stream ( prefix stream -- stream )
    [ last-newline on delegate set prefix set ] extend ;
