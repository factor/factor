
USING: kernel threads arrays sequences combinators.cleave raptor raptor.cron ;

IN: raptor

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fork-exec-args-wait ( args -- ) [ first ] [ ] bi fork-exec-wait ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cron-hourly ( -- ) ;

: cron-daily ( -- )
  { "/etc/cron.daily/apt"
    "/etc/cron.daily/aptitude"
    "/etc/cron.daily/bsdmainutils"
    "/etc/cron.daily/find.notslocate"
    "/etc/cron.daily/logrotate"
    "/etc/cron.daily/man-db"
    "/etc/cron.daily/ntp-server"
    "/etc/cron.daily/slocate"
    "/etc/cron.daily/standard"
    "/etc/cron.daily/sysklogd"
    "/etc/cron.daily/tetex-bin" }
  [ 1array [ fork-exec-args-wait ] in-thread drop ] each ;
    
: cron-weekly ( -- )
  { "/etc/cron.weekly/cvs"
    "/etc/cron.weekly/man-db"
    "/etc/cron.weekly/ntp-server"
    "/etc/cron.weekly/popularity-contest"
    "/etc/cron.weekly/sysklogd" }
  [ 1array [ fork-exec-args-wait ] in-thread drop ] each ;

: cron-monthly ( -- )
  { "/etc/cron.monthly/scrollkeeper"
    "/etc/cron.monthly/standard" }
  [ 1array [ fork-exec-args-wait ] in-thread drop ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: schedule-cron-jobs ( -- )
  { 17 } f f f f         <when> [ cron-hourly  ] schedule
  { 25 } { 6 } f f f     <when> [ cron-daily   ] schedule
  { 47 } { 6 } f f { 7 } <when> [ cron-weekly  ] schedule
  { 52 } { 6 } { 1 } f f <when> [ cron-monthly ] schedule ;