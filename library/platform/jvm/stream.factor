!:folding=indent:collapseFolds=1:

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
USE: combinators
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: regexp
USE: stack
USE: strings

: fcopy ( from to -- )
    ! Copy the contents of the byte-stream 'from' to the byte-stream 'to'.
    [ [ "in" get ] bind ] dip
    [ "out" get ] bind
    [ "java.io.InputStream" "java.io.OutputStream" ]
    "factor.FactorLib" "copy" jinvoke-static ;

! These are in separate words so that they can be compiled.
! Do not call them directly.

: <byte-stream>/freadln ( -- string )
    "in" get
    [ "java.io.InputStream" ] "factor.FactorLib" "readLine"
    jinvoke-static ;

: <byte-stream>/fread# ( count -- string )
    "in" get
    [ "int" "java.io.InputStream" ]
    "factor.FactorLib" "readCount"
    jinvoke-static ;

: <byte-stream>/fwrite ( string -- )
    dup char? [
        "out" get
        [ "int" ] "java.io.OutputStream" "write" jinvoke
    ] [
        >bytes
        "out" get
        [ [ "byte" ] ] "java.io.OutputStream" "write" jinvoke
    ] ifte ;

: <byte-stream>/fflush ( -- )
    "out" get [ ] "java.io.OutputStream" "flush" jinvoke ;

: <byte-stream>/fclose ( -- )
    "in" get  [ [ ] "java.io.InputStream"  "close" jinvoke ] when* 
    "out" get [ [ ] "java.io.OutputStream" "close" jinvoke ] when* ;

: <bin> ( in -- in )
    [ "java.io.InputStream" ] "java.io.BufferedInputStream" jnew ;

: <bout> ( out -- out )
    [ "java.io.OutputStream" ] "java.io.BufferedOutputStream" jnew ;

: <byte-stream> ( in out -- stream )
    #! Creates a new stream for reading from the
    #! java.io.InputStream in, and writing to the
    #! java.io.OutputStream out. The streams are wrapped in
    #! buffered streams.
    <stream> [
        <bout> "out" set
        <bin> "in" set
        ( -- string )
        [ <byte-stream>/freadln ] "freadln" set
        ( count -- string )
        [ <byte-stream>/fread#  ] "fread#" set
        ( string -- )
        [ <byte-stream>/fwrite  ] "fwrite" set
        ( -- )
        [ <byte-stream>/fflush  ] "fflush" set
        ( -- )
        [ <byte-stream>/fclose  ] "fclose" set
    ] extend ;

: <char-stream>/freadln ( -- string )
    "in" get [ ] "java.io.BufferedReader" "readLine"
    jinvoke ;

: <char-stream>/fread# ( -- string )
    "in" get
    [ "int" "java.io.Reader" ]
    "factor.FactorLib" "readCount"
    jinvoke-static ;

: <char-stream>/fwrite ( string -- )
    "out" get [ "java.lang.String" ] "java.io.Writer" "write"
    jinvoke ;

: <char-stream>/fflush ( -- )
    "out" get [ ] "java.io.Writer" "flush" jinvoke ;

: <char-stream>/fclose ( -- )
    "in" get  [ [ ] "java.io.Reader" "close" jinvoke ] when* 
    "out" get [ [ ] "java.io.Writer" "close" jinvoke ] when* ;

: <char-stream> ( in out -- stream )
    #! Creates a new stream for reading from the
    #! java.io.BufferedReader in, and writing to the
    #! java.io.Reader out.
    <stream> [
        "out" set
        "in" set
        ( -- string )
        [ <char-stream>/freadln ] "freadln" set
        ( count -- string )
        [ <char-stream>/fread#  ] "fread#" set
        ( string -- )
        [ <char-stream>/fwrite  ] "fwrite" set
        ( -- )
        [ <char-stream>/fflush  ] "fflush" set
        ( -- )
        [ <char-stream>/fclose  ] "fclose" set
    ] extend ;

: <string-output-stream> ( size -- stream )
    #! Creates a new stream for writing to a string buffer.
    <stream> [
        <sbuf> "buf" set
        ( string -- )
        [ "buf" get sbuf-append ] "fwrite" set
    ] extend ;

: stream>str ( stream -- string )
    #! Returns the string written to the given string output
    #! stream.
    [ "buf" get ] bind >str ;

: <bwriter> ( writer -- bwriter )
    [ "java.io.Writer" ] "java.io.BufferedWriter" jnew ;

: <owriter> ( outputstream -- owriter )
    [ "java.io.OutputStream" ] "java.io.OutputStreamWriter" jnew ;

: <filecr> ( path -- stream )
    [ "java.lang.String" ] "java.io.FileReader" jnew <breader>
    f
    <char-stream> ;

: <filecw> ( path -- stream )
    [ "java.lang.String" ] "java.io.FileWriter" jnew <bwriter>
    f swap
    <char-stream> ;

: <filebr> ( path -- stream )
    [ "java.lang.String" ] "java.io.FileInputStream" jnew
    f
    <byte-stream> ;

: <filebw> ( path -- stream )
    [ "java.lang.String" ] "java.io.FileOutputStream" jnew
    f swap
    <byte-stream> ;

: <file> ( path -- file )
    dup "java.io.File" is not [
        [ "java.lang.String" ] "java.io.File" jnew
    ] when ;

: fdelete ( file -- ? )
    #! Delete a file.
    <file> [ ] "java.io.File" "delete" jinvoke ;

: <freader> ( file -- freader )
    [ "java.lang.String" ] "java.io.FileReader" jnew <breader> ;

: exists? ( file -- boolean )
    <file> [ ] "java.io.File" "exists" jinvoke ;

: directory? ( file -- boolean )
    <file> [ ] "java.io.File" "isDirectory" jinvoke ;

: directory ( file -- listing )
    <file> [ ] "java.io.File" "list" jinvoke array>list str-sort ;

: frename ( from to -- ? )
    ! Rename file 'from' to 'to'. These can be paths or
    ! java.io.File instances.
    <file> swap <file>
    [ "java.io.File" ] "java.io.File" "renameTo"
    jinvoke ;

: file-extension ( filename -- extension )
    ".*\\.(.*)" group1 ;

: <sreader> ( string -- reader )
    [ "java.lang.String" ] "java.io.StringReader" jnew ;

: close ( stream -- )
    dup "java.io.Reader" is [
        [ ] "java.io.Reader" "close" jinvoke
    ] [
        [ ] "java.io.Writer" "close" jinvoke
    ] ifte ;

: <server> ( port -- stream )
    #! Starts listening on localhost:port. Returns a stream that
    #! you can close with fclose. No other stream operations are
    #! supported.
    [ "int" ] "java.net.ServerSocket" jnew
    <stream> [
        "socket" set

        ( -- )
        [
            "socket" get [ ] "java.net.ServerSocket" "close" jinvoke
        ] "fclose" set
    ] extend ;

: <socket-stream> ( socket -- stream )
    #! Wraps a socket inside a byte-stream.
    dup
    [ [ ] "java.net.Socket" "getInputStream"  jinvoke ]
    [ [ ] "java.net.Socket" "getOutputStream" jinvoke ]
    cleave
    <byte-stream> [
        "socket" set

        ! We "extend" byte-stream's fclose.
        ( -- )
        "fclose" get [
            "socket" get [ ] "java.net.Socket" "close" jinvoke
        ] append "fclose" set
    ] extend ;

: <client> ( server port -- stream )
    #! Open a TCP/IP socket to a port on the given server.
    [ "java.lang.String" "int" ] "java.net.Socket" jnew
    <socket-stream> ;

: accept ( server -- client )
    #! Accept a connection from a server socket.
    [ "socket" get ] bind
    [ ] "java.net.ServerSocket" "accept" jinvoke <socket-stream> ;
