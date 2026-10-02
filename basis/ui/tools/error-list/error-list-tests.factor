USING: accessors arrays assocs continuations editors io.pathnames kernel
models namespaces sequences source-files.errors tools.test ui.commands
ui.tools.error-list ;
IN: ui.tools.error-list.tests

: edit-test-display ( -- display )
    T{ source-file-error
        { path "resource:basis/ui/ui.factor" }
        { line# 42 }
    } <model> error-display new swap >>model ;

! #30: the toolbar must dispatch through the Listener, which displays restarts.
{ t } [ \ com-edit listener-command? ] unit-test

SINGLETON: error-list-test-editor
SYMBOL: edit-test-location
M: error-list-test-editor editor-command 2array edit-test-location set f ;

! Preserve the selected error's source path and line for a configured editor.
{ t } [
    error-list-test-editor editor-class [
        edit-test-display \ com-edit command-quot call
        edit-test-location get
        "resource:basis/ui/ui.factor" absolute-path 42 2array =
    ] with-variable
] unit-test

! With no editor configured, retain every offered editor-selection restart.
{ t t } [
    f editor-class [
        [ edit-test-display \ com-edit command-quot call f f ] [
            [ error>> "Select an editor" = ]
            [ compute-restarts [ name>> ] map editor-restarts keys = ] bi
        ] recover
    ] with-variable
] unit-test

! No selected error means no editor invocation.
{ f } [
    error-list-test-editor editor-class [
        f edit-test-location set
        f <model> error-display new swap >>model com-edit
        edit-test-location get
    ] with-variable
] unit-test
