IN: ui.operations.tests
USING: ui.operations ui.commands prettyprint kernel namespaces
tools.test ui.gadgets ui.gadgets.editors parser io
io.streams.string io.directories io.encodings.utf8 io.files
linked-assocs locals math help help.markup accessors assocs
definitions see sequences strings ui.operations.syntax ;

: my-pprint ( obj -- ) pprint ;

[ drop t ] \ my-pprint [ ] f operation boa "op" set

{ [ 3 my-pprint ] } [
    3 "op" get command>> command-quot
] unit-test

{ "3" } [ [ 3 "op" get invoke-command ] with-string-writer ] unit-test

[ drop t ] \ my-pprint [ editor-string ] f operation boa
"op" set

{ "\"4\"" } [
    [
        "4" <editor> [ set-editor-string ] keep
        "op" get invoke-command
    ] with-string-writer
] unit-test

{ } [
    [ { $operations \ + } print-element ] with-string-writer drop
] unit-test

: reload-command ( obj -- ) drop ;

! A changed predicate replaces the named definition; removing it unregisters it.
{ 1 1 t t 0 1 0 } [
    <linked-hash> operations [
        [
            "USING: kernel strings ui.operations.syntax ui.operations.tests ; OPERATION: reload-command [ string? ] H{ }"
            "operation.factor" utf8 set-file-contents
            "operation.factor" run-file
            operations get assoc-size
            "hello" object-operations length
            operations get keys first definition length 2 =
            [ operations get keys first see ] with-string-writer "OPERATION:" subseq-of?
            "USING: kernel math ui.operations.syntax ui.operations.tests ; OPERATION: reload-command [ integer? ] H{ }"
            "operation.factor" utf8 set-file-contents
            "operation.factor" run-file
            "hello" object-operations length
            123 object-operations length
            "USING: kernel ;" "operation.factor" utf8 set-file-contents
            "operation.factor" run-file
            operations get assoc-size
        ] with-test-directory
    ] with-variable
] unit-test

! The dynamic API still supports intentionally different predicates per command.
{ 2 } [
    <linked-hash> operations [
        [ string? ] \ reload-command H{ } define-operation
        [ integer? ] \ reload-command H{ } define-operation
        operations get assoc-size
    ] with-variable
] unit-test
