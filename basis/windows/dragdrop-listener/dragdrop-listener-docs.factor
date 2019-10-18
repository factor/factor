! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel windows.ole32 ;
IN: windows.dragdrop-listener

ABOUT: "windows.dragdrop-listener"

ARTICLE: "windows.dragdrop-listener" "Dropping files onto listener window"
"The " { $vocab-link "windows.dragdrop-listener" } " vocab is a demo of the COM wrapping facilities. It allows you to drag-and-drop any file from the Explorer onto a listener window, and have the contents of that file parsed and executed immediately. If the file does not contain valid Factor source code, you will see compilation errors." $nl
"Register the current listener window to accept file drops:" $nl
{ $subsections dragdrop-listener-window }
"Only one file at a time can be dropped." ;

HELP: dragdrop-listener-window
{ $description "Run this word from a listener to activate drag-and-drop support for the listener window." $nl
"Note: if you get the \"" { $snippet "COM error 0x8007000e" } "\", you need to call " { $link ole-initialize } " first." } ;
