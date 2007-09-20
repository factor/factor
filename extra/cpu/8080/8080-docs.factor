! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax sequences strings ;
IN: cpu.8080

HELP: load-rom 
{ $values { "filename" string } { "cpu" cpu } }
{ $description 
"Read the ROM file into the cpu's memory starting at address 0000. " 
"The filename is relative to the path stored in the " { $link rom-root }
" variable. An exception is thrown if this variable is not set."
}
{ $see-also load-rom* } ;

HELP: load-rom*
{ $values { "seq" sequence } { "cpu" cpu } }
{ $description 
"Loads one or more ROM files into the cpu's memory. Each file is "
"loaded at a particular starting address. 'seq' is a sequence of "
"2 element arrays. The first element is the address and the second "
"element is the file to load at that address." $nl
"The filenames are relative to the path stored in the " { $link rom-root }
" variable. An exception is thrown if this variable is not set."
}
{ $examples
  { $code "{ { HEX: 0000 \"invaders.rom\" } } <cpu> load-rom*" }
}
{ $see-also load-rom } ;

HELP: rom-root
{ $description 
"Holds the path where the ROM files are stored. Used for expanding "
"the relative filenames passed to " { $link load-rom } " and "
{ $link load-rom* } "."
}
{ $see-also load-rom load-rom* } ;

ARTICLE: { "cpu-8080" "cpu-8080" } "Intel 8080 CPU Emulator"
"The cpu-8080 library provides an emulator for the Intel 8080 CPU"
" instruction set. It is complete enough to emulate some 8080"
" based arcade games." $nl 
"The emulated CPU can load 'ROM' files from disk using the "
{ $link load-rom } " and " { $link load-rom* } " words. These expect "
"the " { $link rom-root } " variable to be set to the path "
"containing the ROM file's." ;

ABOUT: { "cpu-8080" "cpu-8080" } 
