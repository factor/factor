USING: help.vocabs tools.test help.markup help vocabs io ;
IN: help.vocabs.tests

{ } [ { $vocab "scratchpad" } print-content ] unit-test
{ } [ "classes" lookup-vocab print-topic ] unit-test
{ } [ nl ] unit-test
