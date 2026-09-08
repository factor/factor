! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel system tools.test unix.linux.proc ;
IN: unix.linux.proc.tests

os linux? [
    [ parse-proc-cmdline ] must-not-fail
    [ parse-proc-cpuinfo ] must-not-fail
    [ parse-proc-loadavg ] must-not-fail
    [ parse-proc-meminfo ] must-not-fail
    [ parse-proc-partitions ] must-not-fail
    [ parse-proc-stat ] must-not-fail
    [ parse-proc-swaps ] must-not-fail
    [ parse-proc-uptime ] must-not-fail
] when

{ 42 "(worker name))" "S" 7 0 } [
    "42 (worker name)) S 7 8 9" string>pid-stat
    { [ pid>> ] [ filename>> ] [ state>> ] [ parent-pid>> ] [ exit-code>> ] } cleave
] unit-test

{ "(a\nb (c))" "R" 123 } [
    "42 (a\nb (c)) R 123" string>pid-stat
    [ filename>> ] [ state>> ] [ parent-pid>> ] tri
] unit-test
