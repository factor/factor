! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: io.pathnames kernel literals memory namespaces sequences
system tools.test ui ui.backend ui.commands ui.gadgets.private
ui.gestures ui.tools.browser ui.tools.button-list
ui.tools.common ui.tools.error-list ui.tools.listener
vocabs.refresh ;
IN: ui.tools

\ refresh-all H{ { +nullary+ t } { +listener+ t } } define-command
\ refresh-and-test-all H{ { +nullary+ t } { +listener+ t } } define-command

\ save H{ { +nullary+ t } } define-command

\ quit H{ { +nullary+ t } } define-command

tool "tool-switching" f {
    { T{ key-down f ${ os macosx? M+ A+ ? } "l" } show-listener }
    { T{ key-down f ${ os macosx? M+ A+ ? } "L" } listener-window }
    { T{ key-down f ${ os macosx? M+ A+ ? } "b" } show-browser }
    { T{ key-down f ${ os macosx? M+ A+ ? } "B" } browser-window }
} define-command-map

tool "common" f {
    { T{ key-down f ${ os macosx? M+ A+ ? } "t" } show-active-buttons-popup }
    { T{ key-down f ${ os macosx? M+ C+ ? } "w" } close-window }
    { T{ key-down f ${ os macosx? M+ C+ ? } "q" } quit }
    { T{ key-down f f "F2" } refresh-all }
    { T{ key-down f { S+ } "F2" } refresh-and-test-all }
    { T{ key-down f f "F3" } show-error-list }
} os macosx? {
    { T{ key-down f { C+ M+ } "f" } toggle-fullscreen }
} {
    { T{ key-down f { C+ } "F4" } close-window }
    { T{ key-down f { A+ } "F4" } close-window }
    { T{ key-down f f "F11" } toggle-fullscreen }
} ? prepend define-command-map

: ui-tools-main ( -- )
    f ui-stop-after-last-window? set-global
    "resource:" absolute-path current-directory set-global
    listener-window ;

MAIN: ui-tools-main
