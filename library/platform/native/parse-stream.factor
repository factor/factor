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

IN: parser
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: stack
USE: stdio
USE: streams
USE: strings

! Stream parsing uses a number of variables:
! file
! line-number
! parse-stream

: next-line ( -- str )
    "parse-stream" get freadln
    "line-number" succ@ ;

: (read-lines) ( quot -- )
    next-line dup [
        swap dup >r call r> (read-lines)
    ] [
        2drop
    ] ifte ;

: read-lines ( stream quot -- )
    #! Apply a quotation to each line as its read. Close the
    #! stream.
    swap [
        "parse-stream" set 0 "line-number" set (read-lines)
    ] [
        "parse-stream" get fclose rethrow
    ] catch ;

: file-vocabs ( -- )
    "file-in" get "in" set
    "file-use" get "use" set ;

: (parse-stream) ( name stream -- quot )
    #! Uses the current namespace for temporary variables.
    >r "file" set f r>
    [ (parse) ] read-lines reverse
    "file" off
    "line-number" off ;

: parse-stream ( name stream -- quot )
    [
        10 "base" set
        file-vocabs
        (parse-stream)
    ] with-scope ;

: parse-file ( file -- quot )
    dup <filecr> parse-stream ;

: run-file ( file -- )
    #! Run a file. The file is read with the default IN:/USE:
    #! for files.
    parse-file call ;

: (parse-file) ( file -- quot )
    dup <filecr> (parse-stream) ;

: (run-file) ( file -- )
    #! Run a file. The file is read with the same IN:/USE: as
    #! the current interactive interpreter.
    (parse-file) call ;

: parse-resource ( path -- quot )
    #! Resources are loaded from the resource-path variable, or
    #! the current directory if it is not set. Words defined in
    #! resources have a definition source path starting with
    #! resource:. This allows words that operate on source
    #! files, like "jedit", to use a different resource path
    #! at run time than was used at parse time.
    "resource:" over cat2 swap <resource-stream> parse-stream ;

: run-resource ( file -- )
    parse-resource call ;
