USING: accessors assocs colors fonts fonts.shaping kernel locals math namespaces
opengl sequences tools.test ui.gadgets ui.gadgets.debug ui.gadgets.editors ui.gadgets.editors.private
ui.text ui.text.private ui.text.uniscribe windows.uniscribe ;
IN: ui.text.uniscribe.tests

{ t } [
    uniscribe-renderer font-renderer [
        { "" "ASCII 123" "a\u000301" "\u01f600" "\u000633\u000644\u000627\u000645" } [| text |
            monospace-font text text-dim
            monospace-font text measure-string-dim =
        ] all?
    ] with-variable
] unit-test

{ t } [
    uniscribe-renderer font-renderer [
        cached-script-strings get-global assoc-size
        monospace-font "transient Uniscribe measurement 695" measure-string-dim drop
        cached-script-strings get-global assoc-size =
    ] with-variable
] unit-test

! Line width must describe the shaped string, not a placeholder value.
{ t } [
    sans-serif-font "iii" [ line-metrics width>> ] [ text-width ] 2bi =
] unit-test

:: selected-ui-geometry? ( text -- ? )
    monospace-font :> font
    text 0 text length COLOR: red <selection> :> selection
    font text string-dim font selection string-dim =
    font text line-metrics font selection line-metrics = and
    0 font text offset>x 0 font selection offset>x = and
    100 font text x>offset 100 font selection x>offset = and ;

{ t } [ uniscribe-renderer font-renderer [ "" selected-ui-geometry? ] with-variable ] unit-test
{ t } [ uniscribe-renderer font-renderer [ "abc" selected-ui-geometry? ] with-variable ] unit-test
{ t } [ uniscribe-renderer font-renderer [ "a\u000301" selected-ui-geometry? ] with-variable ] unit-test

:: near-cluster-end ( str -- n )
    str length monospace-font str offset>x 1 -
    monospace-font str x>offset ;

{ 1 } [ "\u01f600" near-cluster-end ] unit-test
{ 2 } [ "a\u000301" near-cluster-end ] unit-test
{ 2 } [ "\u000915\u00093f" near-cluster-end ] unit-test
{ 0 } [ -100 monospace-font "abc" x>offset ] unit-test
{ 3 } [ 10000 monospace-font "abc" x>offset ] unit-test

{ t } [
    sans-serif-font "A much longer line"
    [ line-metrics width>> ] [ text-width ] 2bi =
] unit-test

{ t } [ sans-serif-font "" line-metrics width>> zero? ] unit-test

! Cap/x heights must come from the font and scale with its size.
{ t } [
    sans-serif-font 12 font-with-size "Hx" line-metrics cap-height>>
    sans-serif-font 36 font-with-size "Hx" line-metrics cap-height>> <
] unit-test

{ t } [
    sans-serif-font 12 font-with-size "Hx" line-metrics x-height>>
    sans-serif-font 36 font-with-size "Hx" line-metrics x-height>> <
] unit-test

{ t } [
    sans-serif-font [ font-metrics cap-height>> ]
    [ "Hx" line-metrics cap-height>> ] bi =
] unit-test

! Legacy Uniscribe must retain native affinity and navigate visual order.
{ t t t t } [
    uniscribe-renderer font-renderer [
        [let
            <editor> "Segoe UI" <font> 32 >>size >>font :> editor
            "\u000633\u000644\u000627\u000645" editor set-editor-string
            editor [
                { 0 1 } editor set-caret editor mark>caret
                editor caret-loc first :> before
                editor previous-character
                editor editor-caret { 0 2 } =
                editor caret-loc first before <
                editor next-character
                editor editor-caret { 0 1 } =
                editor select-previous-character
                editor editor-mark { 0 1 } =
            ] with-grafted-gadget
        ]
    ] with-variable
] unit-test

{ t t t } [
    uniscribe-renderer font-renderer [
        [let
            <editor> "Segoe UI" <font> 24 >>size >>font :> editor
            "abc \u0005d0\u0005d1\u0005d2 xyz" editor set-editor-string
            editor [
                editor start-of-line
                12 [ editor caret-loc first editor next-character ] replicate :> xs
                xs rest-slice xs but-last-slice [ >= ] 2all?
                "\u0005d0\u0005d1\ncd" editor set-editor-string
                { 0 0 } editor set-caret editor mark>caret
                editor next-character
                editor editor-caret { 1 0 } =
                editor previous-character
                editor editor-caret { 0 0 } =
            ] with-grafted-gadget
        ]
    ] with-variable
] unit-test

{ t t } [
    uniscribe-renderer font-renderer [
        [let
            sans-serif-font :> font
            "abc \u0005d0\u0005d1\u0005d2 xyz" :> text
            4 t font text caret>x :> trailing
            4 f font text caret>x :> leading
            trailing leading = not
            trailing 1 - font text x>caret :> ( n affinity )
            n affinity font text caret>x trailing =
        ]
    ] with-variable
] unit-test

! Insertion before an LTR quote keeps the caret beside the Arabic text.
{ t t } [
    uniscribe-renderer font-renderer [
        [let
            <editor> "Segoe UI" <font> 32 >>size >>font :> editor
            "\u000633\u000644\u000627\u000645\" xyz" editor set-editor-string
            editor [
                { 0 4 } editor set-caret editor mark>caret
                "\u000645" editor user-input* drop
                editor editor-caret second editor font>> editor editor-string offset>x :> leading
                editor editor-caret second t editor font>> editor editor-string caret>x :> trailing
                editor caret-loc first trailing gl-round =
                leading trailing = not
            ] with-grafted-gadget
        ]
    ] with-variable
] unit-test

{ t t t t } [
    uniscribe-renderer font-renderer [
        [let
            <editor> "Segoe UI" <font> 24 >>size >>font :> editor
            "\u0005d0\u0005d1\u0005d2" editor set-editor-string
            editor [
                editor start-of-line editor editor-caret { 0 3 } =
                editor end-of-line editor editor-caret { 0 0 } =
                { 0 0 } editor set-mark { 0 3 } editor set-caret
                editor previous-character editor editor-caret { 0 3 } =
                { 0 0 } editor set-mark { 0 3 } editor set-caret
                editor next-character editor editor-caret { 0 0 } =
            ] with-grafted-gadget
        ]
    ] with-variable
] unit-test

! Selection/IME spans must preserve the unselected gap between bidi runs.
{ t } [
    uniscribe-renderer font-renderer [
        1 6 sans-serif-font "abc \u0005d0\u0005d1\u0005d2" selection-spans
        dup length 2 = swap [ first2 < ] all? and
    ] with-variable
] unit-test

! Home must reach the actual left edge when Arabic precedes an LTR quote.
{ t t } [
    uniscribe-renderer font-renderer [
        [let
            <editor> "Segoe UI" <font> 32 >>size >>font :> editor
            "\u000633\u000644\u000627\u000645\" xyz" editor set-editor-string
            editor [
                editor start-of-line editor caret-loc first zero?
                -100 editor font>> editor editor-string x>caret
                editor font>> editor editor-string caret>x zero?
            ] with-grafted-gadget
        ]
    ] with-variable
] unit-test

! Every mouse hit is a Unicode grapheme boundary, even if GDI renders the
! components of a family emoji separately.
{ t } [
    uniscribe-renderer font-renderer [
        [let
            "\u01f469\u00200d\u01f469\u00200d\u01f466" :> text
            "Segoe UI" <font> 32 >>size :> font
            font text text-width >integer 1 + <iota> [
                font text x>offset dup 0 = swap 5 = or
            ] all?
        ]
    ] with-variable
] unit-test

{ t } [
    uniscribe-renderer font-renderer [
        sans-serif-font right-to-left font-with-direction "abc \u0005d0\u0005d1\u0005d2"
        [ 0 -rot offset>x ] [ 0 -rot x>offset ] 2bi
        [ 0 > ] [ 0 > ] bi* and
    ] with-variable
] unit-test
