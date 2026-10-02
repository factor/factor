USING: accessors arrays assocs compiler.test definitions.icons help.vocabs
io kernel linked-assocs math math.private models namespaces parser prettyprint
sequences sequences.extras system tools.test ui.gadgets.tables
ui.gestures ui.operations vocabs.loader ;
IN: github-issue-triage-verification

! The nested IP helper declarations must load successfully (#2554).
"windows.iphlpapi" reload

! These probes distinguish existing generic icons from dedicated artwork (#117),
! and verify the requested virtual element/index pairing (#745).
{ "vocab:definitions/icons/help-article.png" } [ "ui" <vocab-tag> definition-icon ] unit-test
{ "vocab:definitions/icons/help-article.png" } [ "Doug Coleman" <vocab-author> definition-icon ] unit-test
{ { { "a" 0 } { "b" 1 } } } [ { "a" "b" } <zip-index> >array ] unit-test

{
    "classes.struct"
    "bit-arrays"
    "arrays.shaped"
    "prettyprint"
    "math.floats.env"
    "images.loader.gdiplus"
    "game.input.dinput"
    "cache"
    "ui.gadgets.glass"
    "ui.gadgets.panes"
    "ui.tools.listener"
    "ui.tools.operations"
    "tools.annotations"
    "alien.varargs"
} [ test ] each

{
    "resource:basis/compiler/tests/slotless-tuples.factor"
    "resource:basis/compiler/tests/alien-varargs.factor"
    "resource:basis/compiler/tests/alien-varargs-promotions.factor"
    "resource:basis/compiler/tests/alien-varargs-outgoing.factor"
} [ run-file ] each

test-failures get empty? [ "CLOSURE-CHECKS-PASS" print 0 ] [ 1 ] if exit
