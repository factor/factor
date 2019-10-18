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

: <stream> ( -- stream )
    #! Create a stream object. A stream is a namespace with the
    #! following entries:
    #! - fflush
    #! - freadln -- you must provide an implementation!
    #! - fwriteln
    #! - fwrite -- you must provide an implementation!
    #! - fclose
    #! Note that you must extend this object and provide your own
    #! implementations of all entries except for fwriteln, which
    #! is defined to fwrite the string followed by the newline by
    #! default.
    <namespace> [
        ( -- string )
        [ "freadln not implemented." break ] @freadln
        ( string -- )
        [ "fwrite not implemented."  break ] @fwrite
        ( string -- )
        [ "fedit not implemented."   break ] @fedit
        ( -- )
        [ ] @fflush
        ( -- )
        [ ] @fclose
        ( string -- )
        [ this fwrite "\n" this fwrite ] @fwriteln
    ] extend ;

: <extend-stream> ( stream -- stream )
    <stream> [
        @stream
        ( -- string )
        [ $stream freadln ] @freadln
        ( string -- )
        [ $stream fwrite ] @fwrite
        ( string -- )
        [ $stream fedit ] @fedit
        ( -- )
        [ $stream fflush ] @fflush
        ( -- )
        [ $stream fclose ] @fclose
        ( string -- )
        [ $stream fwriteln ] @fwriteln
    ] extend ;

! These are in separate words so that they can be compiled.
! Do not call them directly.

: <byte-stream>/freadln ( -- string )
    $in [ "java.io.InputStream" ] "factor.FactorLib" "readLine"
    jinvoke-static ;

: <byte-stream>/fwrite ( string -- )
    >bytes
    $out [ [ "byte" ] ]
    "java.io.OutputStream" "write" jinvoke ;

: <byte-stream>/fflush ( -- )
    $out [ ] "java.io.OutputStream" "flush" jinvoke ;

: <byte-stream>/fclose ( -- )
    $in  [ [ ] "java.io.InputStream"  "close" jinvoke ] when* 
    $out [ [ ] "java.io.OutputStream" "close" jinvoke ] when* ;

: <byte-stream> ( in out -- stream )
    #! Creates a new stream for reading from the
    #! java.io.InputStream in, and writing to the
    #! java.io.OutputStream out.
    <stream> [
        @out
        @in
        ( -- string )
        [ <byte-stream>/freadln ] @freadln
        ( string -- )
        [ <byte-stream>/fwrite  ] @fwrite
        ( -- )
        [ <byte-stream>/fflush  ] @fflush
        ( -- )
        [ <byte-stream>/fclose  ] @fclose
    ] extend ;

: <char-stream>/freadln ( -- string )
    $in [ ] "java.io.BufferedReader" "readLine"
    jinvoke ;

: <char-stream>/fwrite ( string -- )
    $out [ "java.lang.String" ] "java.io.Writer" "write"
    jinvoke ;

: <char-stream>/fflush ( -- )
    $out [ ] "java.io.Writer" "flush" jinvoke ;

: <char-stream>/fclose ( -- )
    $in  [ [ ] "java.io.Reader" "close" jinvoke ] when* 
    $out [ [ ] "java.io.Writer" "close" jinvoke ] when* ;

: <char-stream> ( in out -- stream )
    #! Creates a new stream for reading from the
    #! java.io.BufferedReader in, and writing to the
    #! java.io.Reader out.
    <stream> [
        @out
        @in
        ( -- string )
        [ <char-stream>/freadln ] @freadln
        ( string -- )
        [ <char-stream>/fwrite  ] @fwrite
        ( -- )
        [ <char-stream>/fflush  ] @fflush
        ( -- )
        [ <char-stream>/fclose  ] @fclose
    ] extend ;

: <string-output-stream> ( -- stream )
    #! Creates a new stream for writing to a string buffer.
    <stream> [
        <sbuf> @buf
        ( string -- )
        [ $buf sbuf-append drop ] @fwrite
    ] extend ;

: stream>str ( stream -- string )
    #! Returns the string written to the given string output
    #! stream.
    [ $buf ] bind >str ;

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

: <bwriter> (writer -- bwriter)
    [ "java.io.Writer" ] "java.io.BufferedWriter" jnew ;

: <owriter> (outputstream -- owriter)
    [ "java.io.OutputStream" ] "java.io.OutputStreamWriter" jnew ;

: read ( -- string )
    $stdio freadln ;

: write ( string -- )
    $stdio fwrite ;

: print ( string -- )
    $stdio [ fwriteln ] [ fflush ] cleave ;

: fflush ( stream -- )
    [ $fflush call ] bind ;

: flush ( -- )
    $stdio fflush ;

: freadln ( stream -- string )
    [ $freadln call ] bind ;

: fwriteln ( string stream -- )
    [ $fwriteln call ] bind ;

: fwrite ( string stream -- )
    [ $fwrite call ] bind ;

: fedit ( string stream -- )
    [ $fedit call ] bind ;

: edit ( string -- )
    $stdio fedit ;

: fclose ( stream -- )
    [ $fclose call ] bind ;

: fcopy ( from to -- )
    ! Copy the contents of the byte-stream 'from' to the byte-stream 'to'.
    [ [ $in ] bind ] dip
    [ $out ] bind
    [ "java.io.InputStream" "java.io.OutputStream" ]
    "factor.FactorLib" "copy" jinvoke-static ;

: <freader> ( file -- freader )
    [ "java.lang.String" ] "java.io.FileReader" jnew <breader> ;

: <file> (path -- file)
    dup "java.io.File" is not [
        [ "java.lang.String" ] "java.io.File" jnew
    ] when ;

: exists? (file -- boolean)
    <file> [ ] "java.io.File" "exists" jinvoke ;

: directory? (file -- boolean)
    <file> [ ] "java.io.File" "isDirectory" jinvoke ;

: directory ( file -- listing )
    <file> [ ] "java.io.File" "list" jinvoke
    array>list ;

: frename ( from to -- )
    ! Rename file 'from' to 'to'. These can be paths or
    ! java.io.File instances.
    <file> swap <file>
    [ "java.io.File" ] "java.io.File" "renameTo"
    jinvoke ;

: <sreader> (string -- reader)
    [ "java.lang.String" ] "java.io.StringReader" jnew ;

: close (stream --)
    dup "java.io.Reader" is [
        [ ] "java.io.Reader" "close" jinvoke
    ] [
        [ ] "java.io.Writer" "close" jinvoke
    ] ifte ;

: exec ( args -- exitCode )
    [ [ "java.lang.String" ] ] "factor.FactorLib" "exec"
    jinvoke-static ;

: print-numbered-list* ( number list -- )
    ! Print each element of the list with a number.
    dup [
        uncons [ over pred ] dip print-numbered-list*
        ": " swap cat3 print
    ] [
        2drop
    ] ifte ;

: print-numbered-list ( list -- )
    dup length pred swap print-numbered-list* ;

: terpri ( -- )
    #! Print a newline to standard output.
    "\n" write ;
