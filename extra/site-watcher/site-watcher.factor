! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors timers arrays calendar combinators
combinators.smart continuations debugger http.client fry
init io.streams.string kernel locals math math.parser db
namespaces sequences site-watcher.db site-watcher.email ;
IN: site-watcher

SYMBOL: site-watcher-frequency
5 minutes site-watcher-frequency set-global

SYMBOL: running-site-watcher
[ f running-site-watcher set-global ] "site-watcher" add-startup-hook

<PRIVATE

: check-sites ( seq -- )
    [
        [ dup url>> http-get 2drop site-good ] [ site-bad ] recover
    ] each ;

: site-up-email ( site -- body )
    last-up>> now swap time- duration>minutes 60 /mod
    [ >integer number>string ] bi@
    [ " hours, " append ] [ " minutes" append ] bi* append
    "Site was down for (at least): " prepend ;

: site-down-email ( site -- body ) error>> ;

: send-report ( site -- )
    [ ]
    [ dup up?>> [ site-up-email ] [ site-down-email ] if ]
    [ [ url>> ] [ up?>> "up" "down" ? ] bi " is " glue ] tri
    send-site-email ;

: send-reports ( seq -- )
    [ [ send-report ] each ] unless-empty ;

PRIVATE>

: watch-sites ( -- )
    find-sites check-sites sites-to-report send-reports ;

: run-site-watcher ( db -- )
    [ running-site-watcher get ] dip '[
        [ _ [ watch-sites ] with-db ] site-watcher-frequency get every
        running-site-watcher set
    ] unless ;

: stop-site-watcher ( -- )
    running-site-watcher get [ stop-timer ] when* ;
