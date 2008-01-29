! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: calendar namespaces models threads init ;
IN: calendar.model

SYMBOL: time

: (time-thread) ( -- )
    now time get set-model
    1000 sleep (time-thread) ;

: time-thread ( -- ) [ (time-thread) ] in-thread ;

f <model> time set-global
[ time-thread ] "calendar.model" add-init-hook
