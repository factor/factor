IN: temporary
USING: gadgets-text kernel models namespaces test ;

[ ] [ f <model> dup "model" set <field> "field" set ] unit-test
[ ] [ "Hello world" "field" get set-editor-text ] unit-test
[ "Hello world" ] [ "field" get field-commit ] unit-test
[ "Hello world" ] [ "model" get model-value ] unit-test
