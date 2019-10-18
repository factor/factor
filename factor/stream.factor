!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
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
    ! Create a stream object. A stream is a namespace with the following
    ! entries:
    ! - fflush
    ! - freadln -- you must provide an implementation!
    ! - fwriteln
    ! - fwrite -- you must provide an implementation!
    ! - fclose
    ! Note that you must extend this object and provide your own implementations
    ! of all entries except for fwriteln, which is defined to fwrite the string
    ! followed by the newline by default.
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

: <bytestream> ( in out -- stream )
    ! Creates a new stream for reading from the java.io.InputStream in, and
    ! writing to the java.io.OutputStream out.
    <stream> [
        @out
        @in

        ( -- string )
        [
            $in [ "java.io.InputStream" ] "factor.FactorLib" "readLine"
            jmethod jinvokeStatic
        ] @freadln

        ( string -- )
        [
            >bytes
            $out [ "[B" ] "java.io.OutputStream" "write" jmethod jinvoke
        ] @fwrite

        ( -- )
        [
            $out [ ] "java.io.OutputStream" "flush" jmethod jinvoke
        ] @fflush

        ( -- )
        [
            $in  [ ] "java.io.InputStream"  "close" jmethod jinvoke
            $out [ ] "java.io.OutputStream" "close" jmethod jinvoke
        ] @fclose
    ] extend ;

: <charstream> ( in out -- stream )
    ! Creates a new stream for reading from the java.io.BufferedReader in, and
    ! writing to the java.io.Reader out.
    <stream> [
        @out
        @in

        ( -- string )
        [
            $in [ ] "java.io.BufferedReader" "readLine" jmethod jinvoke
        ] @freadln

        ( string -- )
        [
            $out [ "java.lang.String" ] "java.io.Writer" "write" jmethod jinvoke
        ] @fwrite

        ( -- )
        [
            $out [ ] "java.io.Writer" "flush" jmethod jinvoke
        ] @fflush

        ( -- )
        [
            $in  [ ] "java.io.Reader" "close" jmethod jinvoke
            $out [ ] "java.io.Writer" "close" jmethod jinvoke
        ] @fclose
    ] extend ;

: <filecr> ( path -- stream )
    [ |java.lang.String ] |java.io.FileReader jconstructor jnew <breader>
    f
    <charstream> ;

: <filecw> ( path -- stream )
    f
    [ |java.lang.String ] |java.io.FileWriter jconstructor jnew <bwriter>
    <charstream> ;

: <filebr> ( path -- stream )
    [ |java.lang.String ] |java.io.FileInputStream jconstructor jnew
    f
    <bytestream> ;

: <filebw> ( path -- stream )
    f
    [ |java.lang.String ] |java.io.FileOutputStream jconstructor jnew
    <bytestream> ;

: <bwriter> (writer -- bwriter)
    [ |java.io.Writer ] |java.io.BufferedWriter jconstructor jnew ;

: <owriter> (outputstream -- owriter)
    [ |java.io.OutputStream ] |java.io.OutputStreamWriter jconstructor jnew ;

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
    "factor.FactorLib" "copy" jmethod jinvokeStatic ;

"java.lang.System" "in"  jfield jvarStatic$ <ireader> <breader> @stdin
"java.lang.System" "out" jfield jvarStatic$ <owriter> @stdout
$stdin $stdout <charstream> @stdio

!(file -- freader)
|<freader> [
    [ |java.lang.String ] |java.io.FileReader jconstructor jnew <breader>
] define

: <file> (path -- file)
    dup "java.io.File" is not [
        [ "java.lang.String" ] "java.io.File" jconstructor jnew
    ] when ;

: exists? (file -- boolean)
    <file> [ ] "java.io.File" "exists" jmethod jinvoke ;

: directory? (file -- boolean)
    <file> [ ] "java.io.File" "isDirectory" jmethod jinvoke ;

: directory ( file -- listing )
    <file> [ ] "java.io.File" "list" jmethod jinvoke
    array>list ;

: rename ( from to -- )
    ! Rename file 'from' to 'to'. These can be paths or
    ! java.io.File instances.
    <file> swap <file>
    [ "java.io.File" ] "java.io.File" "renameTo"
    jmethod jinvoke ;

!(string -- reader)
|<sreader> [
    [ |java.lang.String ] |java.io.StringReader jconstructor jnew
] define

: close (stream --)
    dup "java.io.Reader" is
    [ ] "java.io.Reader" "close" jmethod
    [ ] "java.io.Writer" "close" jmethod
    ?
    jinvoke ;

: exec (args -- exitCode)
    [ "[Ljava.lang.String;" ] "factor.FactorLib" "exec" jmethod jinvokeStatic ;

!(stream -- string)
|read* [
    [ ] |java.io.BufferedReader |readLine jmethod jinvoke
] define

: print* (string stream --)
    tuck write*
    "\n" swap write* ;

!(string stream --)
|write* [
    tuck
    [ |java.lang.String ] |java.io.Writer |write jmethod jinvoke
    [ ] |java.io.Writer |flush jmethod jinvoke
] define
