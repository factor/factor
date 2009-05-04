! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: memory system kernel vocabs.refresh ui.tools.operations
ui.tools.listener ui.tools.browser ui.tools.common ui.tools.error-list
ui.tools.walker ui.commands ui.gestures ui ui.private ;
IN: ui.tools

: main ( -- )
    restore-windows? [ restore-windows ] [ listener-window ] if ;

MAIN: main

\ refresh-all H{ { +nullary+ t } { +listener+ t } } define-command

\ save H{ { +nullary+ t } } define-command

: com-exit ( -- ) 0 exit ;

\ com-exit H{ { +nullary+ t } } define-command

tool "tool-switching" f {
    { T{ key-down f { A+ } "l" } show-listener }
    { T{ key-down f { A+ } "L" } listener-window }
    { T{ key-down f { A+ } "b" } show-browser }
    { T{ key-down f { A+ } "B" } browser-window }
} define-command-map

tool "common" f {
    { T{ key-down f { A+ } "s" } save }
    { T{ key-down f { A+ } "w" } close-window }
    { T{ key-down f { A+ } "q" } com-exit }
    { T{ key-down f f "F2" } refresh-all }
    { T{ key-down f f "F3" } show-error-list }
} define-command-map