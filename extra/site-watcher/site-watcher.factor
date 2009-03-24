! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays calendar combinators
combinators.smart continuations debugger http.client fry
init io.streams.string kernel locals math math.parser db
namespaces sequences site-watcher.db site-watcher.db.private
smtp ;
IN: site-watcher

SYMBOL: site-watcher-from
"factor-site-watcher@gmail.com" site-watcher-from set-global

SYMBOL: site-watcher-frequency
5 minutes site-watcher-frequency set-global
 
SYMBOL: running-site-watcher
[ f running-site-watcher set-global ] "site-watcher" add-init-hook

<PRIVATE

: check-sites ( seq -- )
    [
        [ dup url>> http-get 2drop site-good ] [ site-bad ] recover
    ] each ;

: site-up-email ( email site -- email )
    last-up>> now swap time- duration>minutes 60 /mod
    [ >integer number>string ] bi@
    [ " hours, " append ] [ " minutes" append ] bi* append
    "Site was down for (at least): " prepend >>body ;

: site-down-email ( email site -- email ) error>> >>body ;

: send-report ( site -- )
    [ <email> ] dip
    {
        [ email>> 1array >>to ]
        [ drop site-watcher-from get "factor.site.watcher@gmail.com" or >>from ]
        [ dup up?>> [ site-up-email ] [ site-down-email ] if ]
        [ [ url>> ] [ up?>> "up" "down" ? ] bi " is " glue >>subject ]
    } cleave send-email ;

: send-reports ( seq -- )
    [ ] [ [ send-report ] each ] if-empty ;

PRIVATE>

: watch-sites ( db -- )
    [ find-sites check-sites sites-to-report send-reports ] with-db ;

: run-site-watcher ( db -- )
    [ running-site-watcher get ] dip '[ 
        [ _ watch-sites ] site-watcher-frequency get every
        running-site-watcher set
    ] unless ;

: stop-site-watcher ( -- )
    running-site-watcher get [ cancel-alarm ] when* ;
