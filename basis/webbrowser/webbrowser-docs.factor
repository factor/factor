! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax strings webbrowser ;

IN: webbrowser

HELP: open-file
{ $values { "path" string } }
{ $description
    "Open a specified file or directory using the default "
    "application, similar to double-clicking the file's icon."
} ;

HELP: open-url
{ $values { "url" string } }
{ $description
    "Open a specified url in the default web browser."
} ;
