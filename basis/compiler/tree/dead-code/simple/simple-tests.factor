USING: accessors compiler.tree compiler.tree.dead-code.liveness
compiler.tree.dead-code.simple kernel math namespaces tools.test ;
IN: compiler.tree.dead-code.simple.tests

! dead-flushable-call?
{ t } [
    { } { } \ + <#call> dead-flushable-call?
] unit-test

{ f t } [
    H{ { 3 t } } live-values set
    { 1 2 } { 3 } \ + <#call> dead-flushable-call?
    { 1 2 } { 77 } \ + <#call> dead-flushable-call?
] unit-test

{
    f
    "foo" { 3 }
} [
    H{ { 3 t } } live-values set
    "foo" 9 <#push> remove-dead-code*
    "foo" 3 <#push> remove-dead-code* [ literal>> ] [ out-d>> ] bi
] unit-test
