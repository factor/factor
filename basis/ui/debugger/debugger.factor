! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors debugger io kernel namespaces prettyprint
ui.gadgets.panes ui.gadgets.worlds ui ;
IN: ui.debugger

: <error-pane> ( error -- pane )
    <pane> [ [ print-error ] with-pane ] keep ; inline

: error-window ( error -- )
    <error-pane> "Error" open-window ;

[ error-window ] ui-error-hook set-global

M: world-error error.
    "An error occurred while drawing the world " write
    dup world>> pprint-short "." print
    "This world has been deactivated to prevent cascading errors." print
    error>> error. ;
