USING: gml.runtime kernel tools.test ;
IN: gml.runtime.tests

! EXEC: parsers leave the method word beneath the parsed definition.
{ 42 } [
    { } <gml> 42 (exec) nip pop-operand
] unit-test

! EXEC:: passes the method word through the locals parser explicitly.
{ { 42 } } [
    { f } clone <gml>
    42 over push-operand
    "value" <write-register> (exec) drop
] unit-test
