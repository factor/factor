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

IN: stdio
USE: errors
USE: kernel
USE: namespaces
USE: stack
USE: streams

: <stdio-stream> ( stream -- stream )
    #! We disable fclose on stdio so that various tricks like
    #! with-stream can work.
    clone [ [ ] "fclose" set ] extend ;

: flush ( -- )
    "stdio" get fflush ;

: read ( -- string )
    "stdio" get freadln ;

: read# ( count -- string )
    "stdio" get fread# ;

: write ( string -- )
    "stdio" get fwrite ;

: write-attr ( string -- )
    #! Write an attributed string to standard output.
    "stdio" get fwrite-attr ;

: print ( string -- )
    "stdio" get tuck fprint fflush ;

: edit ( string -- )
    "stdio" get fedit ;

: terpri ( -- )
    #! Print a newline to standard output.
    "\n" write ;

: with-stream ( stream quot -- )
    [
        swap "stdio" set [ "stdio" get fclose rethrow ] catch
    ] with-scope ;
