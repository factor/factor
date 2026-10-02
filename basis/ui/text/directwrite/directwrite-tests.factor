USING: accessors arrays assocs continuations fonts fonts.shaping kernel locals math math.functions
models namespaces opengl sequences tools.test ui.gadgets ui.gadgets.debug ui.gadgets.editors
ui.gadgets.editors.private ui.text ui.text.directwrite ui.text.private windows.directwrite ;
IN: ui.text.directwrite.tests

! Bulk measurements preserve shaping without filling the rendering cache.
{ t } [
    directwrite-renderer font-renderer [
        { "" "ASCII 123" "a\u000301" "\u01f600" "\u000633\u000644\u000627\u000645" } [| text |
            monospace-font text text-dim
            monospace-font text measure-string-dim =
        ] all?
    ] with-variable
] unit-test

{ t t } [
    directwrite-renderer font-renderer [
        [let
            cached-directwrite-layouts get-global assoc-size :> layouts
            directwrite-layout-aliases get-global assoc-size :> aliases
            monospace-font "transient DirectWrite measurement 695" measure-string-dim drop
            cached-directwrite-layouts get-global assoc-size layouts =
            directwrite-layout-aliases get-global assoc-size aliases =
        ]
    ] with-variable
] unit-test

! UI coordinates stay logical as native layouts change backing scale.
:: scaled-tab-caret ( -- x index )
    gl-scale-factor get-global :> original
    [
        1.5 gl-scale-factor set-global
        2 sans-serif-font 32 font-with-tab-width "a\tb" offset>x
        32 sans-serif-font 32 font-with-tab-width "a\tb" x>offset
    ] [ original gl-scale-factor set-global ] finally ;

{ t 2 } [
    directwrite-renderer font-renderer [ scaled-tab-caret [ 32.0 0.01 ~ ] dip ] with-variable
] unit-test

! Vertical navigation keeps a visual column when the next row changes
! writing direction and glyph widths; Shift preserves the logical anchor.
{ t t t } [
    directwrite-renderer font-renderer [
        [let
            <multiline-editor> "Segoe UI" <font> 32 >>size >>font :> editor
            "\u000633\u000644\u000627\u000645\niiiiiiiiiiii" editor set-editor-string
            editor [
                { 0 1 } editor set-caret editor mark>caret
                editor next-line
                editor editor-caret second 2 >
                editor previous-line
                editor editor-caret { 0 1 } =
                editor select-next-line
                editor editor-mark { 0 1 } =
            ] with-grafted-gadget
        ]
    ] with-variable
] unit-test

! Crossing mixed runs keeps movement visual; moving between rows enters
! the appropriate visual edge, even when its logical column is reversed.
{ t t t } [
    directwrite-renderer font-renderer [
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

! Native hit testing must not place a caret inside an emoji ZWJ sequence.
{ 0 5 } [
    "\u01f469\u00200d\u01f469\u00200d\u01f466"
    [ 2 f rot directwrite-snap-caret ] [ 2 t rot directwrite-snap-caret ] bi
] unit-test

! #2160/#2521: Left and Right traverse visual Arabic order, including Shift.
{ t t t t } [
    directwrite-renderer font-renderer [
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

! Native mouse hits preserve which side of an RTL/LTR boundary was hit.
{ t t } [
    directwrite-renderer font-renderer [
        [let
            sans-serif-font :> font
            "abc \u0005d0\u0005d1\u0005d2 xyz" :> text
            4 t font text caret>x :> trailing
            4 f font text caret>x :> leading
            trailing leading = not
            trailing 0.01 - font text x>caret :> ( n affinity )
            n affinity font text caret>x trailing 0.01 ~
        ]
    ] with-variable
] unit-test

! Typing Arabic before a quote leaves the caret beside the inserted text,
! rather than jumping to the next LTR run's side of the same logical offset.
{ t t } [
    directwrite-renderer font-renderer [
        [let
            <editor> "Segoe UI" <font> 32 >>size >>font :> editor
            "\u000633\u000644\u000627\u000645\" xyz" editor set-editor-string
            editor [
                { 0 4 } editor set-caret editor mark>caret
                "\u000645" editor user-input* drop
                editor editor-caret second editor font>> editor editor-string
                offset>x :> leading
                editor editor-caret second t editor font>> editor editor-string
                caret>x :> trailing
                editor caret-loc first trailing gl-round =
                leading trailing = not
            ] with-grafted-gadget
        ]
    ] with-variable
] unit-test

! Home/End and selection collapse use visual edges of RTL lines.
{ t t t t } [
    directwrite-renderer font-renderer [
        [let
            <editor> "Segoe UI" <font> 24 >>size >>font :> editor
            "\u0005d0\u0005d1\u0005d2" editor set-editor-string
            editor [
                editor start-of-line
                editor editor-caret { 0 3 } =
                editor end-of-line
                editor editor-caret { 0 0 } =
                { 0 0 } editor set-mark { 0 3 } editor set-caret
                editor previous-character
                editor editor-caret { 0 3 } =
                { 0 0 } editor set-mark { 0 3 } editor set-caret
                editor next-character
                editor editor-caret { 0 0 } =
            ] with-grafted-gadget
        ]
    ] with-variable
] unit-test

{ t } [
    directwrite-renderer font-renderer [
        sans-serif-font right-to-left font-with-direction "abc אבג"
        [ 0 -rot offset>x ] [ 0 -rot x>offset ] 2bi
        [ 0 > ] [ 0 > ] bi* and
    ] with-variable
] unit-test
