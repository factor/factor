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

IN: init
USE: combinators
USE: compiler
USE: continuations
USE: errors
USE: interpreter
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: prettyprint
USE: random
USE: stack
USE: stdio
USE: streams
USE: strings
USE: words

! This file is run as the last stage of boot.factor; it relies
! on all other words already being defined.

: ?run-file ( file -- )
    dup exists? [ (run-file) ] [ drop ] ifte ;

: run-user-init ( -- )
    #! Run user init file if it exists
    "user-init" get [
        <% "~" get % "/" get % ".factor-" % "rc" % %>
        ?run-file
    ] when ;

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
    [ cli-arg ] map ;

: run-files ( args -- )
    [ [ run-file ] when* ] each ;

: parse-command-line ( args -- )
    #! Parse command line arguments.
    parse-switches run-files ;

: init-toplevel ( -- )
    [ "top-level-continuation" set ] callcc0 ;

: (word-of-the-day) ( -- word )
    vocabs random-element words dup [
        random-element
    ] [
        drop (word-of-the-day) ( empty vocab )
    ] ifte ;

: word-of-the-day ( -- )
    #! Something to entertain the poor hacker.
    (word-of-the-day) dup defined? [
        "WORD OF THE DAY: " print see
    ] [
        drop word-of-the-day
    ] ifte ;

: init-interpreter ( -- )
    init-history

    print-banner
    word-of-the-day
    room.

    init-toplevel

    [
        interpreter-loop
    ] [
        [ default-error-handler suspend ] when*
    ] catch ;
