USING: accessors arrays classes.struct io kernel math math.floats.env
math.floats.env.m68k math.floats.env.private prettyprint sequences sets ;
IN: math.floats.env.m68k.native-probe

: expect-m68k-env ( actual expected -- )
    2dup = [ 2drop ] [ 2array throw ] if ;

! Register round trips exercise the real alien-assembly leaf routines.
<m68k-env> dup fpcr>> . dup fpsr>> .
[ { } { } +round-nearest+ +denormal-keep+ set-fp-env
  rounding-mode +round-nearest+ expect-m68k-env
  +round-up+ [
      1.0 5.0 /f double>bits 0x3fc999999999999a expect-m68k-env
  ] with-rounding-mode
  +round-down+ [
      1.0 5.0 /f double>bits 0x3fc9999999999999 expect-m68k-env
  ] with-rounding-mode
  rounding-mode +round-nearest+ expect-m68k-env
  [ 1.0 0.0 /f drop ] collect-fp-exceptions
  +fp-zero-divide+ swap member? t expect-m68k-env
  clear-fp-exception-flags fp-exception-flags { } expect-m68k-env
  { +fp-zero-divide+ } set-fp-traps
  fp-traps { +fp-zero-divide+ } set= t expect-m68k-env
  { } set-fp-traps
  denormal-flush-supported? f expect-m68k-env
  denormal-mode +denormal-keep+ expect-m68k-env
] dip (set-fp-env-register)
"M68k Factor floating environment register, flag and rounding checks: PASS" print
