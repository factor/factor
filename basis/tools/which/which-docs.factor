! Copyright (C) 2013 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: help.markup help.syntax strings ;

IN: tools.which

HELP: which
{ $values { "command" string } { "file/f" "the first matching path or " { $link f } } }
{ $description "Returns the full path of the executable that would have been executed if " { $snippet "command" } " had been entered at the shell prompt." } ;
