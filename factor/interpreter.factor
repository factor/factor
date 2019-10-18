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

0 @history-count

: exit (--)
    $global [ t @quit-flag ] bind ;

: print-banner ( -- )
    "Factor " $version cat2 print
    "Copyright (C) 2003, 2004 Slava Pestov" print
    "Enter ``help'' for help." print
    "Enter ``exit'' to exit." print ;

: history+ ( cmd -- )
    $history 2dup contains [ 2drop ] [ cons @history ] ifte
    "history-count" succ@ ;

: history ( -- )
    "X redo    -- evaluate the expression with number X." print
    "X re-edit -- edit the expression with number X." print
    $history print-numbered-list ;

: get-history ( index -- )
    $history reverse swap get ;

: redo ( index -- )
    get-history [ . ] [ eval ] cleave ;

: re-edit ( index -- )
    get-history edit ;

: print-prompt ( prompt -- )
    write $history-count write "] " write ;

: interpreter-loop ( prompt -- )
    dup >r print-prompt read [
        [ history+ ] [ eval ] cleave
        $global [ $quit-flag ] bind [
            rdrop
            $global [ f @quit-flag ] bind
        ] [
            r> interpreter-loop
        ] ifte
    ] when* ;

: initial-interpreter-loop (--)
    ! Run the stand-alone interpreter
    print-banner
    ! Used by :r
    [ @initial-interpreter-continuation ] callcc0
    ! Used by :s
    ! We use the slightly redundant 'call' to push the current callframe.
    [ callstack$ @initial-interpreter-callstack ] call
    "    " interpreter-loop ;

: stats ( -- )
    "Cons:     " write
    "factor.Cons" "COUNT" jvar-static$ .
    "Words:    " write
    words length .
    "Compiled: " write
    words [ worddef compiled? ] subset length . ;

: gc ( -- )
    [ ] "java.lang.System" "gc" jinvoke-static ;

: help
    "clear              -- clear datastack."
    ".s                 -- print datastack."
    ".                  -- print top of datastack."
    "" print
    "values.            -- list all variables." print
    "inspect            -- list all variables bound on object at top of stack." print
    "$variable .        -- show value of variable." print
    "" print
    "words.             -- list all words." print
    "\"str\" apropos      -- list all words whose name contains str." print
    "\"word\" see         -- show definition of word." print
    "" print
    "[ expr ] balance . -- show stack effect of expression." print
    "" print
    "history            -- list previously entered expresions." print
    "X redo             -- redo expression number X from history list." print
    "" print
    "stats              -- interpreter statistics." print
    "exit               -- exit the interpreter." print
    "" print ;
