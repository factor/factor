! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: debugger accessors debugger.threads kernel
concurrency.mailboxes ;
IN: concurrency.mailboxes.debugger

M: linked-error error.
    [ thread>> error-in-thread. ] [ error>> error. ] bi ;
