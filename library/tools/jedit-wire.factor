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

IN: jedit
USE: combinators
USE: lists
USE: namespaces
USE: parser
USE: presentation
USE: prettyprint
USE: stack
USE: stdio
USE: streams
USE: strings
USE: words

! Wire protocol for jEdit to evaluate Factor code.
! Packets are of the form:
!
! 4 bytes length
! <n> bytes data
!
! jEdit sends a packet with code to eval, it receives the output
! captured with with-string.
: write-packet ( string -- )
    dup str-length write-big-endian-32 write flush ;

: read-packet ( -- string )
    read-big-endian-32 read# ;

: wire-server ( -- )
    #! Repeatedly read jEdit requests and execute them. Return
    #! on EOF.
    read-packet [ eval>string write-packet wire-server ] when* ;

! Stream protocol for jEdit allows user to interact with a
! Factor listener.
!
! Packets have the following form:
!
! 1 byte -- type. CHAR: w: write, CHAR: r: read CHAR: f flush
! 4 bytes -- for write only -- length of write request
! remaining -- unparsed write request -- string then style

! After a read line request, the server reads a response from
! the client:
! 4 bytes -- length. -1 means EOF
! remaining -- input
: jedit-read ( -- str )
    CHAR: r write flush read-big-endian-32 read# ;

: jedit-write-attr ( str style -- )
    CHAR: w write
    [ swap . . ] with-string
    dup str-length write-big-endian-32
    write ;

: jedit-flush ( -- )
    CHAR: f write flush ;

: <jedit-stream> ( stream -- stream )
    <extend-stream> [
        ( -- str )
        [ jedit-read ] "freadln" set
        ( str -- )
        [
            default-style jedit-write-attr
        ] "fwrite" set
        ( str style -- )
        [ jedit-write-attr ] "fwrite-attr" set
        ( string -- )
        [
            "\n" cat2 default-style jedit-write-attr
        ] "fprint" set
        ( -- )
        [ jedit-flush ] "fflush" set
    ] extend ;

: stream-server ( -- )
    #! Execute this in the inferior Factor.
    "stdio" get <jedit-stream> "stdio" set ;

: jedit-lookup ( word vocabs -- )
    #! A utility word called by the Factor plugin to get some
    #! required word info.
    search dup [
        [
            "vocabulary"
            "name"
            "stack-effect"
        ] [
            dupd word-property
        ] map nip
    ] when ;
