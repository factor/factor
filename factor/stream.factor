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
    ! Create a stream object. A stream is a namespace with the
    ! following entries:
    ! - fflush
    ! - freadln -- you must provide an implementation!
    ! - fwriteln
    ! - fwrite -- you must provide an implementation!
    ! - fclose
    ! Note that you must extend this object and provide your own
    ! implementations of all entries except for fwriteln, which
    ! is defined to fwrite the string followed by the newline by
    ! default.
    <namespace> [
        ( -- string )
        [ "freadln not implemented." break ] @freadln
        ( string -- )
        [ "fwrite not implemented."  break ] @fwrite
        ( -- )
        [ ] @fflush
        ( -- )
        [ ] @fclose
        ( string -- )
        [ $namespace fwrite "\n" $namespace fwrite ] @fwriteln
    ] extend ;

! These are in separate words so that they can be compiled.
! Do not call them directly.

: <bytestream>/freadln ( -- string )
    $in [ "java.io.InputStream" ] "factor.FactorLib" "readLine"
    jinvoke-static ;

: <bytestream>/fwrite ( string -- )
    >bytes
    $out [ [ "byte" ] ]
    "java.io.OutputStream" "write" jinvoke ;

: <bytestream>/fflush ( -- )
    $out [ ] "java.io.OutputStream" "flush" jinvoke ;

: <bytestream>/fclose ( -- )
    $in  [ ] "java.io.InputStream"  "close" jinvoke
    $out [ ] "java.io.OutputStream" "close" jinvoke ;

: <bytestream> ( in out -- stream )
    ! Creates a new stream for reading from the
    ! java.io.InputStream in, and writing to the
    ! java.io.OutputStream out.
    <stream> [
        @out
        @in
        ( -- string )
        [ <bytestream>/freadln ] @freadln
        ( string -- )
        [ <bytestream>/fwrite  ] @fwrite
        ( -- )
        [ <bytestream>/fflush  ] @fflush
        ( -- )
        [ <bytestream>/fclose  ] @fclose
    ] extend ;

: <charstream>/freadln ( -- string )
    $in [ ] "java.io.BufferedReader" "readLine"
    jinvoke ;

: <charstream>/fwrite ( string -- )
    $out [ "java.lang.String" ] "java.io.Writer" "write"
    jinvoke ;

: <charstream>/fflush ( -- )
    $out [ ] "java.io.Writer" "flush" jinvoke ;

: <charstream>/fclose ( -- )
    $in  [ ] "java.io.Reader" "close" jinvoke
    $out [ ] "java.io.Writer" "close" jinvoke ;

: <charstream> ( in out -- stream )
    ! Creates a new stream for reading from the
    ! java.io.BufferedReader in, and writing to the
    ! java.io.Reader out.
    <stream> [
        @out
        @in
        ( -- string )
        [ <charstream>/freadln ] @freadln
        ( string -- )
        [ <charstream>/fwrite  ] @fwrite
        ( -- )
        [ <charstream>/fflush  ] @fflush
        ( -- )
        [ <charstream>/fclose  ] @fclose
    ] extend ;

: <filecr> ( path -- stream )
    [ |java.lang.String ] |java.io.FileReader jnew <breader>
    f
    <charstream> ;

: <filecw> ( path -- stream )
    f
    [ |java.lang.String ] |java.io.FileWriter jnew <bwriter>
    <charstream> ;

: <filebr> ( path -- stream )
    [ |java.lang.String ] |java.io.FileInputStream jnew
    f
    <bytestream> ;

: <filebw> ( path -- stream )
    f
    [ |java.lang.String ] |java.io.FileOutputStream jnew
    <bytestream> ;

: <bwriter> (writer -- bwriter)
    [ |java.io.Writer ] |java.io.BufferedWriter jnew ;

: <owriter> (outputstream -- owriter)
    [ |java.io.OutputStream ] |java.io.OutputStreamWriter jnew ;

: read ( -- string )
    $stdio freadln ;

: write ( string -- )
    $stdio [ fwrite ] [ fflush ] cleave ;

: print ( string -- )
    $stdio [ fwriteln ] [ fflush ] cleave ;

: fflush ( stream -- )
    [ $fflush call ] bind ;

: freadln ( stream -- string )
    [ $freadln call ] bind ;

: fwriteln ( string stream -- )
    [ $fwriteln call ] bind ;

: fwrite ( string stream -- )
    [ $fwrite call ] bind ;

: fclose ( stream -- )
    [ $fclose call ] bind ;

: fcopy ( from to -- )
    ! Copy the contents of the bytestream 'from' to the bytestream 'to'.
    [ [ $in ] bind ] dip
    [ $out ] bind
    [ "java.io.InputStream" "java.io.OutputStream" ]
    "factor.FactorLib" "copy" jinvoke-static ;

"java.lang.System" "in"  jvar-static$ <ireader> <breader> @stdin
"java.lang.System" "out" jvar-static$ <owriter> @stdout
$stdin $stdout <charstream> @stdio

!(file -- freader)
|<freader> [
    [ |java.lang.String ] |java.io.FileReader jnew <breader>
] define

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

: rename ( from to -- )
    ! Rename file 'from' to 'to'. These can be paths or
    ! java.io.File instances.
    <file> swap <file>
    [ "java.io.File" ] "java.io.File" "renameTo"
    jinvoke ;

!(string -- reader)
|<sreader> [
    [ |java.lang.String ] |java.io.StringReader jnew
] define

: close (stream --)
    dup "java.io.Reader" is [
        [ ] "java.io.Reader" "close" jinvoke
    ] [
        [ ] "java.io.Writer" "close" jinvoke
    ] ifte ;

: exec ( args -- exitCode )
    [ [ "java.lang.String" ] ] "factor.FactorLib" "exec"
    jinvoke-static ;

!(stream -- string)
|read* [
    [ ] |java.io.BufferedReader |readLine jinvoke
] define

: print* (string stream --)
    tuck write*
    "\n" swap write* ;

!(string stream --)
|write* [
    tuck
    [ |java.lang.String ] |java.io.Writer |write jinvoke
    [ ] |java.io.Writer |flush jinvoke
] define
