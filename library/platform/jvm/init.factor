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

: cli-param ( param -- )
    #! Handle a command-line argument starting with '-' by
    #! setting that variable to t, or if the argument is
    #! prefixed with 'no-', setting the variable to f.
    dup "no-" str-head? dup [
        f put drop
    ] [
        drop t put
    ] ifte ;

: cli-arg ( argument -- argument )
    #! Handle a command-line argument. If the argument was
    #! consumed, returns f. Otherwise returns the argument.
    dup [
        dup "-" str-head? dup [
            cli-param drop f
        ] [
            drop
        ] ifte
    ] when ;

: parse-switches ( args -- args )
    [ cli-arg ] inject ;

: run-files ( args -- )
    [ [ run-file ] when* ] each ;

: parse-command-line ( args -- )
    #! Parse command line arguments.
    "args" get parse-switches run-files ;

: stdin ( -- stdin )
    "java.lang.System" "in"  jvar-static-get
    <ireader> <breader> ;

: stdout ( -- stdout )
    "java.lang.System" "out" jvar-static-get <owriter> ;

: init-stdio ( -- )
    #! Initialize standard input/output.
    stdin stdout <char-stream> "stdio" set ;

: init-environment ( -- )
    #! Initialize OS-specific constants.
    "user.home" system-property "~" set
    "file.separator" system-property "/" set ;

: run-user-init ( -- )
    #! Run user init file if it exists
    "~" get "/" get ".factor-rc" cat3 "init-path" set

    "user-init" get [
        "init-path" get dup exists? [
            interactive-run-file
        ] [
            drop
        ] ifte
    ] when ;

: boot ( -- )
    #! The boot word is run by the intepreter when starting from
    #! an object database.

    ! Some flags are *on* by default, unless user specifies
    ! -no-<flag> CLI switch
    t "user-init" set
    t "compile"   set

    init-stdio
    init-environment
    init-search-path
    init-scratchpad
    parse-command-line
    run-user-init

    "compile" get [
        compile-all
    ] when

    t "startup-done" set
    
    print-banner
    init-interpreter ;
