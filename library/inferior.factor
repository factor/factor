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

IN: inferior
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: prettyprint
USE: stack
USE: stdio
USE: streams
USE: strings
USE: styles

! Packets have the following form:
! 1 byte -- type. CHAR: w: write, CHAR: r: read
! 4 bytes -- for write only -- length of write request
! remaining -- unparsed write request -- string then style

! After a read line request, the server reads a response from
! the client:
! 4 bytes -- length. -1 means EOF
! remaining -- input

! All multi-byte integers are big endian signed.

: inferior-server-read ( -- str )
    CHAR: r write flush read-big-endian-32 read# ;

: inferior-server-write-attr ( str style -- )
    CHAR: w write
    [ swap . . ] with-string
    dup str-length write-big-endian-32
    write ;

: <inferior-server-stream> ( stream -- stream )
    <extend-stream> [
        ( -- str )
        [ inferior-server-read ] "freadln" set
        ( str -- )
        [
            default-style inferior-server-write-attr
        ] "fwrite" set
        ( str style -- )
        [ inferior-server-write-attr ] "fwrite-attr" set
        ( string -- )
        [
            "\n" cat2 default-style inferior-server-write-attr
        ] "fprint" set
    ] extend ;

: inferior-client-read ( stream -- ? )
    freadln dup [
        dup str-length write-big-endian-32 write flush t
    ] [
        drop 0 write-big-endian-32 flush f
    ] ifte ;

: inferior-client-write ( stream -- ? )
    read-big-endian-32 read# dup [
        parse dup [
            uncons car rot fwrite-attr t
        ] [
            2drop f
        ] ifte
    ] when ;

: inferior-client-packet ( stream -- ? )
    #! Read from an inferior client socket and print attributed
    #! strings that were read to standard output.
    read1 dup CHAR: r = [
        drop inferior-client-read
    ] [
        dup CHAR: w = [
            drop inferior-client-write
        ] [
            "Invalid packet type: " swap cat2 throw
        ] ifte
    ] ifte ;

: inferior-client-loop ( stream -- )
    #! The stream is the stream to write to.
    dup inferior-client-packet [
        inferior-client-loop
    ] [
        drop
    ] ifte ;

: inferior-client ( from -- )
    "stdio" get swap [ inferior-client-loop ] with-stream ;
