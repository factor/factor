! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.tools.operations ui.tools.listener ui.tools.browser
ui.tools.common ui.commands ui.gestures ui kernel tools.vocabs ;
IN: ui.tools

: main ( -- )
    restore-windows? [ restore-windows ] [ listener-window ] if ;

MAIN: main

\ refresh-all H{ { +nullary+ t } { +listener+ t } } define-command

tool "common" "Common commands available in all UI tools" {
    { T{ key-down f { A+ } "l" } show-listener }
    { T{ key-down f { A+ } "L" } listener-window }
    { T{ key-down f { A+ } "b" } show-browser }
    { T{ key-down f { A+ } "B" } browser-window }
    { T{ key-down f f "F2" } refresh-all }
} define-command-map