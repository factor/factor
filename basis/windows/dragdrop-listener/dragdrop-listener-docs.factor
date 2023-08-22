! Copyright (C) 2017, 2023 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel windows.ole32 ;
IN: windows.dragdrop-listener

ABOUT: "windows.dragdrop-listener"

ARTICLE: "windows.dragdrop-listener" "Dropping files onto listener window"
"The " { $vocab-link "windows.dragdrop-listener" } " vocab is a demo of the COM wrapping facilities. It allows you to drag-and-drop files from the Explorer onto a listener window, and have the array of file names added to the current data stack." $nl
"Register the current listener window to accept file drops:"
{ $subsections dragdrop-listener-window } ;

HELP: dragdrop-listener-window
{ $description "Run this word from a listener to activate drag-and-drop support for the listener window:" { $code "dragdrop-listener-window" }
"Note: if you get the \"" { $snippet "COM error 0x8007000e" } "\", you need to call " { $link ole-initialize } " first." } { $code "USE: windows.ole32 ole-initialize" } ;
