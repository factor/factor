
USING: kernel namespaces threads arrays sequences combinators.cleave
       raptor raptor.cron ;

IN: raptor

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fork-exec-args-wait ( args -- ) [ first ] [ ] bi fork-exec-wait ;

: run-script ( path -- ) 1array [ fork-exec-args-wait ] curry in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[
    "/etc/cron.daily/apt"             run-script
    "/etc/cron.daily/aptitude"	      run-script
    "/etc/cron.daily/bsdmainutils"    run-script
    "/etc/cron.daily/find.notslocate" run-script
    "/etc/cron.daily/logrotate"	      run-script
    "/etc/cron.daily/man-db"	      run-script
    "/etc/cron.daily/ntp-server"      run-script
    "/etc/cron.daily/slocate"	      run-script
    "/etc/cron.daily/standard"	      run-script
    "/etc/cron.daily/sysklogd"	      run-script
    "/etc/cron.daily/tetex-bin"	      run-script
] cron-jobs-daily set-global
    
[
  "/etc/cron.weekly/cvs"                run-script
  "/etc/cron.weekly/man-db"		run-script
  "/etc/cron.weekly/ntp-server"		run-script
  "/etc/cron.weekly/popularity-contest" run-script
  "/etc/cron.weekly/sysklogd"		run-script
] cron-jobs-weekly set-global

[
  "/etc/cron.monthly/scrollkeeper" run-script
  "/etc/cron.monthly/standard"     run-script
] cron-jobs-monthly set-global