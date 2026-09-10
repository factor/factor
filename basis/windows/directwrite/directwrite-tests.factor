USING: accessors arrays assocs combinators continuations destructors fonts fonts.shaping hashtables kernel locals math math.functions
math.order namespaces opengl sequences strings tools.test windows.directwrite windows.fonts ;
IN: windows.directwrite.tests

: test-font ( -- font ) "Segoe UI" <font> ;

:: directwrite-alias-snapshot? ( -- pinned? new-entry? new-width? restored-entry? )
    "monospace" windows-fonts at :> original
    [
        "Arial" "monospace" windows-fonts set-at
        "monospace" <font> 28 >>size :> font
        font "DirectWrite alias WWWWiiii" cached-directwrite-layout :> before
        "Courier New" "monospace" windows-fonts set-at
        font "DirectWrite alias WWWWiiii" cached-directwrite-layout :> after
        before font>> name>> "Arial" =
        before after eq? not
        before metrics>> width>> after metrics>> width>> = not
        ! Layout-owned strings must not also be the memo table's hash key.
        [
            CHAR: X 0 before font>> name>> set-nth
            "Arial" "monospace" windows-fonts set-at
            font "DirectWrite alias WWWWiiii" cached-directwrite-layout before eq?
        ] [ CHAR: A 0 before font>> name>> set-nth ] finally
    ] [ original "monospace" windows-fonts set-at ] finally ;

{ t t t t } [ directwrite-alias-snapshot? ] unit-test

{ t t } [
    [let
        test-font :> font
        10000 CHAR: a <string> :> text
        font text cached-directwrite-layout :> plain
        font text 9000 9010 f <selection> cached-directwrite-layout :> selected
        plain pointer>> selected pointer>> =
        selected directwrite-selection-rects selected directwrite-selection-rects eq?
    ]
] unit-test

{ t } [
    [let
        test-font "selection ownership" cached-directwrite-layout :> plain
        test-font "selection ownership" 0 4 f <selection> <directwrite-layout>
        dispose
        4 plain directwrite-offset>x 0 >
    ]
] unit-test

{ 0 0 1 2 } [
    "\u01f600x" { [ 0 directwrite-codepoint-index ]
    [ 1 directwrite-codepoint-index ]
    [ 2 directwrite-codepoint-index ]
    [ 3 directwrite-codepoint-index ] } cleave
] unit-test

:: end-hit ( text -- index )
    test-font text cached-directwrite-layout :> layout
    text length layout directwrite-offset>x 0.1 - layout directwrite-x>offset ;

{ 1 } [ "\u01f600" end-hit ] unit-test
{ 2 } [ "a\u000301" end-hit ] unit-test
{ 2 } [ "\u000915\u00093f" end-hit ] unit-test
{ 0 } [ -100 test-font "abc" cached-directwrite-layout directwrite-x>offset ] unit-test
{ 3 } [ 10000 test-font "abc" cached-directwrite-layout directwrite-x>offset ] unit-test
{ 0.0 } [ test-font "" cached-directwrite-layout metrics>> width>> ] unit-test
{ t } [ test-font "" cached-directwrite-layout metrics>> height>> 0 > ] unit-test

:: rtl-reorders? ( -- ? )
    "abc \u0005d0\u0005d1\u0005d2" :> text
    test-font left-to-right font-with-direction text cached-directwrite-layout :> ltr
    test-font right-to-left font-with-direction text cached-directwrite-layout :> rtl
    0 ltr directwrite-offset>x 0 rtl directwrite-offset>x < ;
{ t } [ rtl-reorders? ] unit-test

:: tab-placement ( -- x )
    2 test-font 32 font-with-tab-width "a\tb" cached-directwrite-layout directwrite-offset>x ;
{ t } [ tab-placement 32.0 0.01 ~ ] unit-test

:: kerning-width ( value -- width )
    "Cambria" <font> "kern" value 2array 1array >hashtable font-with-features
    "AVATAR" cached-directwrite-layout metrics>> width>> ;
{ t } [ 0 kerning-width 1 kerning-width = not ] unit-test

{ t } [
    test-font "abc \u0005d0\u0005d1\u0005d2" 1 6 f <selection>
    cached-directwrite-layout directwrite-selection-rects length 1 >
] unit-test

{ t } [
    test-font 12 font-with-size "Hx" cached-directwrite-layout metrics>> cap-height>>
    test-font 36 font-with-size "Hx" cached-directwrite-layout metrics>> cap-height>> <
] unit-test

{ t } [
    test-font "a\nb" cached-directwrite-layout metrics>> height>>
    test-font "ab" cached-directwrite-layout metrics>> height>> >
] unit-test

:: directwrite-dpi-test ( -- distinct? doubled? reused? )
    gl-scale-factor get-global :> original
    [
        1.0 gl-scale-factor set-global
        test-font "DPI" cached-directwrite-layout :> normal
        2.0 gl-scale-factor set-global
        test-font "DPI" cached-directwrite-layout :> scaled
        1.0 gl-scale-factor set-global
        normal scaled eq? not
        normal metrics>> width>> 2 * scaled metrics>> width>> 0.01 ~
        normal test-font "DPI" cached-directwrite-layout eq?
    ] [ original gl-scale-factor set-global ] finally ;
{ t t t } [ directwrite-dpi-test ] unit-test



! Unknown families use the same deterministic fallback for shaping and metrics.
{ t } [
    "Factor Missing Font 847292" <font> "Hx AVATAR" cached-directwrite-layout metrics>>
    test-font "Hx AVATAR" cached-directwrite-layout metrics>> =
] unit-test

! A positive interval that underflows to zero in FLOAT fails after format
! creation, exercising the format's exception-only COM release scope.
[
    test-font 1.0e-300 font-with-tab-width "tab\there" cached-directwrite-layout drop
] must-fail

{ t } [
    test-font "abc \u0005d0\u0005d1\u0005d2" 1 6 f <selection>
    cached-directwrite-layout directwrite-selection-rects
    test-font "abc \u0005d0\u0005d1\u0005d2" 6 1 f <selection>
    cached-directwrite-layout directwrite-selection-rects =
] unit-test

{ t } [
    test-font "" 0 0 f <selection> cached-directwrite-layout
    directwrite-selection-rects [ width>> zero? ] all?
] unit-test


: disposed-layout ( -- layout )
    test-font "abc" <directwrite-layout> dup dispose ;

{ f } [ disposed-layout pointer>> ] unit-test
[ 0 disposed-layout directwrite-offset>x ] [ already-disposed? ] must-fail-with
[ 0 disposed-layout directwrite-x>offset ] [ already-disposed? ] must-fail-with
[ disposed-layout directwrite-selection-rects ] [ already-disposed? ] must-fail-with
