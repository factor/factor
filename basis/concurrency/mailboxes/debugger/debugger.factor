! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.mailboxes debugger debugger.threads
kernel ;
IN: concurrency.mailboxes.debugger

M: linked-error error.
    [ thread>> error-in-thread. ] [ error>> error. ] bi ;
