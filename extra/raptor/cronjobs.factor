
USING: kernel namespaces threads arrays sequences combinators.cleave
       raptor raptor.cron ;

IN: raptor

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[
    "/etc/cron.daily/apt"             fork-exec-arg
    "/etc/cron.daily/aptitude"	      fork-exec-arg
    "/etc/cron.daily/bsdmainutils"    fork-exec-arg
    "/etc/cron.daily/find.notslocate" fork-exec-arg
    "/etc/cron.daily/logrotate"	      fork-exec-arg
    "/etc/cron.daily/man-db"	      fork-exec-arg
    "/etc/cron.daily/ntp-server"      fork-exec-arg
    "/etc/cron.daily/slocate"	      fork-exec-arg
    "/etc/cron.daily/standard"	      fork-exec-arg
    "/etc/cron.daily/sysklogd"	      fork-exec-arg
    "/etc/cron.daily/tetex-bin"	      fork-exec-arg
] cron-jobs-daily set-global
    
[
  "/etc/cron.weekly/cvs"                fork-exec-arg
  "/etc/cron.weekly/man-db"		fork-exec-arg
  "/etc/cron.weekly/ntp-server"		fork-exec-arg
  "/etc/cron.weekly/popularity-contest" fork-exec-arg
  "/etc/cron.weekly/sysklogd"		fork-exec-arg
] cron-jobs-weekly set-global

[
  "/etc/cron.monthly/scrollkeeper" fork-exec-arg
  "/etc/cron.monthly/standard"     fork-exec-arg
] cron-jobs-monthly set-global