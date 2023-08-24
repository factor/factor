! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax kernel present strings ;

IN: webbrowser

HELP: open-item
{ $values { "item" object } }
{ $description
  "Opens an item, which is either a file, directory or url in a detached process using the default application, similar to double-clicking the file's icon. item is any object that has the " { $link present } " method." } ;

HELP: open-url
{ $values { "url" string } }
{ $description
    "Open a specified url in the default web browser."
} ;
