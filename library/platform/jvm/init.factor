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

IN: init
USE: combinators
USE: compiler
USE: continuations
USE: kernel
USE: lists
USE: interpreter
USE: namespaces
USE: parser
USE: stack
USE: stdio
USE: streams
USE: strings
USE: styles
USE: words

: stdin ( -- stdin )
    "java.lang.System" "in"  jvar-static-get
    <ireader> <breader> ;

: stdout ( -- stdout )
    "java.lang.System" "out" jvar-static-get <owriter> ;

: init-stdio ( -- )
    #! Initialize standard input/output.
    stdin stdout <char-stream> <stdio-stream> "stdio" set ;

: init-environment ( -- )
    #! Initialize OS-specific constants.
    "user.home" system-property "~" set
    "file.separator" system-property "/" set ;

: boot ( -- )
    #! The boot word is run by the intepreter when starting from
    #! an object database.

    10 "base" set

    ! Some flags are *on* by default, unless user specifies
    ! -no-<flag> CLI switch
    t "user-init" set
    t "compile"   set

    init-stdio
    init-environment
    init-search-path
    init-scratchpad
    init-styles
    init-vocab-styles
    "args" get parse-command-line
    run-user-init

    "compile" get [
        compile-all
    ] when

    t "startup-done" set
    
    "interactive" get [ init-interpreter 1 exit* ] when ;
