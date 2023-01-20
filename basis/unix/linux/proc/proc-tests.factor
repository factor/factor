! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel tools.test unix.linux.proc ;
IN: unix.linux.proc.tests

[ parse-proc-cmdline ] must-not-fail
[ parse-proc-cpuinfo ] must-not-fail
[ parse-proc-loadavg ] must-not-fail
[ parse-proc-meminfo ] must-not-fail
[ parse-proc-partitions ] must-not-fail
[ parse-proc-stat ] must-not-fail
[ parse-proc-swaps ] must-not-fail
[ parse-proc-uptime ] must-not-fail
