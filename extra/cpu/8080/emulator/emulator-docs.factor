! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax sequences strings ;
IN: cpu.8080.emulator

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
  { $code "{ { 0x0000 \"invaders.rom\" } } <cpu> load-rom*" }
}
{ $see-also load-rom } ;

HELP: rom-root
{ $description
"Holds the path where the ROM files are stored. Used for expanding "
"the relative filenames passed to " { $link load-rom } " and "
{ $link load-rom* } "."
}
{ $see-also load-rom load-rom* } ;
