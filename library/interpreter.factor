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

IN: interpreter
USE: combinators
USE: continuations
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: parser
USE: stack
USE: stdio
USE: strings
USE: presentation
USE: words
USE: unparser
USE: vectors

: print-banner ( -- )
    <% "This is " % java? [ "JVM " % ] when
    native? [ "native " % ] when "Factor " % version % %> print
    "Copyright (C) 2003, 2004 Slava Pestov" print
    "Copyright (C) 2004 Chris Double" print
    "Type ``exit'' to exit, ``help'' for help." print ;

: print-prompt ( -- )
    "ok" "prompt" style write-attr
    ! Print the space without a style, to workaround a bug in
    ! the GUI listener where the style from the prompt carries
    ! over to the input
    " " write flush ;

: exit ( -- )
    "quit-flag" on ;

: eval-catch ( str -- )
    [ eval ] [ [ default-error-handler drop ] when* ] catch ;

: interpret ( -- )
    print-prompt read [ eval-catch ] [ exit ] ifte* ;

: interpreter-loop ( -- )
    "quit-flag" get [
        "quit-flag" off
    ] [
        interpret interpreter-loop
    ] ifte ;

: room. ( -- )
    room
    1024 /i unparse write " KB total, " write
    1024 /i unparse write " KB free" print ;

: help ( -- )
    "SESSION:" print
    native? [
        "\"foo.image\" save-image   -- save heap to a file" print
    ] when
    "room.                    -- show memory usage" print
    "garbage-collection       -- force a GC" print
    "exit                     -- exit interpreter" print
    terpri
    "WORDS:" print
    "vocabs.                  -- list vocabularies" print 
    "\"math\" words.            -- list the math vocabulary" print
    "\"str\" apropos.           -- list all words containing str" print
    "\\ neg see                -- show word definition" print
    "\\ car usages.            -- list all words invoking car" print
    terpri
    "STACKS:" print
    ".s .r .n .c              -- show contents of the 4 stacks" print
    "clear                    -- clear datastack" print
    terpri
    "OBJECTS:" print
    "global describe          -- list global variables." print
    "\"foo\" get .              -- print a variable value." print
    ".                        -- print top of stack." print
    terpri
    "HTTP SERVER:             USE: httpd 8888 httpd" print
    "TELNET SERVER:           USE: telnetd 9999 telnetd" print ;
