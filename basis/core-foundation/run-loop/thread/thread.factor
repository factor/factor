! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: init core-foundation.run-loop ;
IN: core-foundation.run-loop.thread

! Load this vocabulary if you need a run loop running.

[ start-run-loop-thread ] "core-foundation.run-loop.thread" add-init-hook
