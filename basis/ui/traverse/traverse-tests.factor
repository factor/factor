USING: accessors arrays compiler.units definitions kernel make
sequences strings tools.test ui.traverse ;
IN: ui.traverse.tests

M: array children>> ;
M: string children>> drop f ;

GENERIC: flatten-tree% ( node -- )

M: node flatten-tree% children>> [ flatten-tree% ] each ;

M: object flatten-tree% , ;

: flatten-tree ( seq -- newseq )
    [ [ flatten-tree% ] each ] { } make ;

: gadgets-in-range ( frompath topath gadget -- seq )
    gadget-subtree flatten-tree ;

{ { "a" "b" "c" "d" } } [
    { 0 } { } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

{ { "a" "b" } } [
    { } { 1 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

{ { "a" } } [
    { 0 } { 0 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

{ { "a" "b" "c" } } [
    { 0 } { 2 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

{ { "a" "b" "c" "d" } } [
    { 0 } { 3 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

{ { "a" "b" "c" "d" } } [
    { 0 0 } { 0 3 } { { "a" "b" "c" "d" } } gadgets-in-range
] unit-test

{ { "b" "c" "d" "e" } } [
    { 0 1 } { 1 } { { "a" "b" "c" "d" } "e" } gadgets-in-range
] unit-test

{ { "b" "c" "d" "e" "f" } } [
    { 0 1 } { 1 1 } { { "a" "b" "c" "d" } { "e" "f" "g" } } gadgets-in-range
] unit-test

{ { "b" "c" "d" { "e" "f" "g" } "h" "i" } } [
    { 0 1 } { 2 1 } { { "a" "b" "c" "d" } { "e" "f" "g" } { "h" "i" } } gadgets-in-range
] unit-test

{ { "b" "c" "d" { "e" "f" "g" } "h" } } [
    { 0 1 } { 2 0 0 } { { "a" "b" "c" "d" } { "e" "f" "g" } { { "h" "i" } "j" } } gadgets-in-range
] unit-test

{ { "b" "c" "d" { "e" "f" "g" } "h" "i" } } [
    { 0 1 } { 2 0 1 } { { "a" "b" "c" "d" } { "e" "f" "g" } { { "h" "i" } "j" } } gadgets-in-range
] unit-test

! A selected prompt can lose its children when the listener starts a line.
{ { "b" "c" } } [
    { 0 1 1 } { 1 } { { "a" "b" } "c" } gadgets-in-range
] unit-test

{ { "b" } } [
    { 0 1 } { 0 3 } { { "a" "b" } } gadgets-in-range
] unit-test

{ { { } } } [
    { 0 1 } { 1 2 } { } gadgets-in-range
] unit-test

{ { "a" "b" } } [
    { 0 } { 1 3 } { "a" "b" } gadgets-in-range
] unit-test

{ { "b" "c" } } [
    { 0 1 } { 1 0 } { { "a" "b" "c" } } gadgets-in-range
] unit-test

{ { } } [ { 0 } { 1 } f gadgets-in-range ] unit-test

[
    M\ array children>> forget
    M\ string children>> forget
] with-compilation-unit
