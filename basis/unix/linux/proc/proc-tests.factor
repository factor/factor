! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel system tools.test unix.linux.proc ;
IN: unix.linux.proc.tests

[ parse-proc-cmdline ] must-not-fail
[ parse-proc-cpuinfo ] must-not-fail
[ parse-proc-loadavg ] must-not-fail
[ parse-proc-meminfo ] must-not-fail
[ parse-proc-partitions ] must-not-fail
[ parse-proc-stat ] must-not-fail
[ parse-proc-swaps ] must-not-fail
[ parse-proc-uptime ] must-not-fail

{ 1 7 "rv64imafdc_zicsr_zifencei" "rv64imafdc_zicsr_zifencei" "sv39" "sifive,u74-mc" 1161 42 0 } [
    {
        "processor\t: 1"
        "hart\t\t: 7"
        "isa\t\t: rv64imafdc_zicsr_zifencei"
        "hart isa\t: rv64imafdc_zicsr_zifencei"
        "mmu\t\t: sv39"
        "uarch\t\t: sifive,u74-mc"
        "mvendorid\t: 0x489"
        "marchid\t\t: 0x2a"
        "mimpid\t\t: 0x0"
    } lines>processor-info
    { [ processor>> ] [ hart>> ] [ isa>> ] [ hart-isa>> ] [ mmu>> ]
      [ uarch>> ] [ mvendorid>> ] [ marchid>> ] [ mimpid>> ] } cleave
] unit-test

{ 0 0 "rv32imafdc" "sv32" } [
    { "processor : 0" "hart : 0" "isa : rv32imafdc" "mmu : sv32" }
    lines>processor-info
    { [ processor>> ] [ hart>> ] [ isa>> ] [ mmu>> ] } cleave
] unit-test

{ 42 "(worker name))" "S" 7 0 } [
    "42 (worker name)) S 7 8 9" string>pid-stat
    { [ pid>> ] [ filename>> ] [ state>> ] [ parent-pid>> ] [ exit-code>> ] } cleave
] unit-test

{ "(a\nb (c))" "R" 123 } [
    "42 (a\nb (c)) R 123" string>pid-stat
    [ filename>> ] [ state>> ] [ parent-pid>> ] tri
] unit-test
