! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel tools.test ui.gadgets.editors
ui.gadgets.line-support ui.gadgets.line-support.private ui.text ;

! line-gadget-height
{ t } [
    { 0 0 } <multiline-editor>
    [ 1 >>min-rows line-gadget-height ]
    [ line-height ] bi =
] unit-test

! line-gadget-width
{ t } [
    { 0 0 } <multiline-editor>
    [ 1 >>min-cols line-gadget-width ]
    [ font>> em ] bi =
] unit-test

! pref-viewport-dim*
{ t } [
    <multiline-editor>
    [ 1 >>min-rows 1 >>min-cols pref-viewport-dim* ] [
        [ font>> "m" text-width ] [ line-height ] bi 2array
    ] bi =
] unit-test
