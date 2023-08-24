! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax sequences strings cpu.8080.emulator ;
IN: cpu.8080


ARTICLE: "cpu.8080" "Intel 8080 CPU Emulator"
"The cpu-8080 library provides an emulator for the Intel 8080 CPU"
" instruction set. It is complete enough to emulate some 8080"
" based arcade games." $nl
"The emulated CPU can load 'ROM' files from disk using the "
{ $link load-rom } " and " { $link load-rom* } " words. These expect "
"the " { $link rom-root } " variable to be set to the path "
"containing the ROM file's." ;

ABOUT: "cpu.8080"
