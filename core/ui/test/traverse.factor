USING: gadgets-labels namespaces sequences kernel
gadgets math arrays test io gadgets-panes gadgets-traverse
definitions generic ;
IN: temporary

M: array gadget-children ;

GENERIC: (flatten-tree) ( node -- )

M: node (flatten-tree)
    node-children [ (flatten-tree) ] each ;

M: object (flatten-tree) , ;

: flatten-tree ( seq -- newseq )
    [ [ (flatten-tree) ] each ] { } make ;

: gadgets-in-range ( frompath topath gadget -- seq )
    gadget-subtree flatten-tree ;

[ { "a" "b" "c" "d" } ] [
    { 0 } { } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

[ { "a" } ] [
    { } { 1 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

[ { } ] [
    { 0 } { 0 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

[ { "a" "b" } ] [
    { 0 } { 2 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

[ { "a" "b" "c" } ] [
    { 0 } { 3 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

[ { "a" "b" "c" "d" } ] [
    { 0 } { 4 } { "a" "b" "c" "d" } gadgets-in-range
] unit-test

[ { "a" "b" "c" } ] [
    { 0 0 } { 0 3 } { { "a" "b" "c" "d" } } gadgets-in-range
] unit-test

[ { "b" "c" "d" "e" } ] [
    { 0 1 } { 2 } { { "a" "b" "c" "d" } "e" } gadgets-in-range
] unit-test

[ { "b" "c" "d" "e" "f" } ] [
    { 0 1 } { 1 2 } { { "a" "b" "c" "d" } { "e" "f" "g" } } gadgets-in-range
] unit-test

[ { "b" "c" "d" { "e" "f" "g" } "h" } ] [
    { 0 1 } { 2 1 } { { "a" "b" "c" "d" } { "e" "f" "g" } { "h" "i" } } gadgets-in-range
] unit-test

[ { "b" "c" "d" { "e" "f" "g" } } ] [
    { 0 1 } { 2 0 0 } { { "a" "b" "c" "d" } { "e" "f" "g" } { { "h" "i" } "j" } } gadgets-in-range
] unit-test

[ { "b" "c" "d" { "e" "f" "g" } "h" } ] [
    { 0 1 } { 2 0 1 } { { "a" "b" "c" "d" } { "e" "f" "g" } { { "h" "i" } "j" } } gadgets-in-range
] unit-test

{ array gadget-children } forget
