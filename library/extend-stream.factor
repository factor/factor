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

IN: streams
USE: errors
USE: kernel
USE: namespaces
USE: stack
USE: stdio
USE: strings

: <extend-stream> ( stream -- stream )
    #! Create a stream that wraps another stream. Override some
    #! or all of the stream words.
    <stream> [
        "stdio" set
        ( -- string )
        [ read ] "freadln" set
        ( -- string )
        [ read1 ] "fread1" set
        ( count -- string )
        [ read# ] "fread#" set
        ( string -- )
        [ write ] "fwrite" set
        ( string style -- )
        [ write-attr ] "fwrite-attr" set
        ( string -- )
        [ edit ] "fedit" set
        ( -- )
        [ flush ] "fflush" set
        ( -- )
        [ "stdio" get fclose ] "fclose" set
        ( string -- )
        [ print ] "fprint" set
    ] extend ;
