! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test unix.linux.proc ;
IN: unix.linux.proc.tests

{ } [ parse-proc-cmdline drop ] unit-test
{ } [ parse-proc-cpuinfo drop ] unit-test
{ } [ parse-proc-loadavg drop ] unit-test
{ } [ parse-proc-meminfo drop ] unit-test
{ } [ parse-proc-partitions drop ] unit-test
{ } [ parse-proc-stat drop ] unit-test
{ } [ parse-proc-swaps drop ] unit-test
{ } [ parse-proc-uptime drop ] unit-test
