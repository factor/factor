USING: accessors arrays continuations editors io.pathnames kernel math namespaces
parser sequences tools.annotations tools.test tools.walker ui.operations
ui.tools.operations vocabs vocabs.loader vocabs.parser words ;
IN: ui.tools.operations.tests

GENERIC: breakpoint-generic ( x -- y )
M: integer breakpoint-generic 1 + ;

: reset-available? ( obj -- ? )
    object-operations [ command>> \ reset = ] any? ;

{ f } [ \ breakpoint-generic reset-available? ] unit-test
{ f } [ 123 reset-available? ] unit-test

{ } [ \ breakpoint-generic breakpoint ] unit-test
{ t } [ \ breakpoint-generic reset-available? ] unit-test
{ t } [ M\ integer breakpoint-generic reset-available? ] unit-test
{ } [ \ breakpoint-generic reset ] unit-test
{ f } [ \ breakpoint-generic reset-available? ] unit-test
{ f } [ M\ integer breakpoint-generic annotated? ] unit-test
{ 4 } [ 3 breakpoint-generic ] unit-test

! #2309: exercise the parser's real restart label and context operations.
: resource-restart ( -- restart )
    "resource:basis/ui/ui.factor" parse-file-restarts first first2 f <restart> ;

: edit-restart-available? ( obj -- ? )
    object-operations [ command>> \ com-edit-restart = ] any? ;

{ t } [ resource-restart edit-restart-available? ] unit-test
{ "resource:basis/ui/ui.factor" } [ resource-restart restart-edit-target string>> ] unit-test
{ f } [ "Continue" t f <restart> edit-restart-available? ] unit-test
{ f } [ "Select an editor" "vscode" f <restart> edit-restart-available? ] unit-test
{ f } [ 123 edit-restart-available? ] unit-test
{ t } [
    \ dup 1array word-restarts first first2 f <restart>
    restart-edit-target \ dup eq?
] unit-test
{ t } [
    "Open vocabulary" "math" lookup-vocab f <restart> edit-restart-available?
] unit-test
{ t } [
    "Open file" "resource:basis/ui/ui.factor" <pathname> f <restart> edit-restart-available?
] unit-test

SINGLETON: restart-test-editor
SYMBOL: restart-edit-location
M: restart-test-editor editor-command 2array restart-edit-location set f ;

! Editing a restart delegates to the configured editor without continuing it.
{ t t t } [
    restart-test-editor editor-class [
        resource-restart dup com-edit-restart
        [ obj>> t = ] [ continuation>> not ] bi
        restart-edit-location get
        "resource:basis/ui/ui.factor" absolute-path 0 2array =
    ] with-variable
] unit-test

! A primitive has no word source location; edit its vocabulary source.
{ t } [
    restart-test-editor editor-class [
        \ dup 1array word-restarts first first2 f <restart> com-edit-restart
        restart-edit-location get
        "kernel" vocab-source-path absolute-path 1 2array =
    ] with-variable
] unit-test

{ "resource:basis/example with spaces.factor" } [
    "resource:basis/example with spaces.factor" parse-file-restarts first first2 f <restart>
    restart-edit-target string>>
] unit-test

! A method annotated individually can also be reset through its generic.
{ } [ M\ integer breakpoint-generic breakpoint ] unit-test
{ t } [ \ breakpoint-generic reset-available? ] unit-test
{ } [ \ breakpoint-generic reset ] unit-test
{ f } [ \ breakpoint-generic reset-available? ] unit-test
{ 4 } [ 3 breakpoint-generic ] unit-test
