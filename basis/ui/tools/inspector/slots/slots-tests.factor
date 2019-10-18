USING: assocs tools.test ui.tools.inspector.slots refs ;

{ t } [
    [ ] [ ] { { 1 1 } { 2 2 } { 3 3 } } 2 <value-ref>
    <slot-editor> slot-editor?
] unit-test
