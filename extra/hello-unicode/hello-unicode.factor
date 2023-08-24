! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ui.gadgets.panes ui.gadgets.borders ui io io.styles ;
IN: hello-unicode

: <hello-gadget> ( -- gadget )
    [
        { { font-size 24 } } [
            "Hello" print
            "Grüß dich" print
            "Привет" print
            "こんにちは" print
            "안녕하세요" print
            "שָׁלוֹם " print
        ] with-style
    ] make-pane { 10 10 } <border> ;

MAIN-WINDOW: hello-unicode { { title "გამარჯობა" } }
    <hello-gadget> >>gadgets ;
