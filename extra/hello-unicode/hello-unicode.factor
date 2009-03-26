! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.gadgets.panes ui.gadgets.borders ui io io.styles ;
IN: hello-unicode

: <hello-gadget> ( -- gadget )
    [
        { { font-size 24 } } [
            "Hello" print
            "Grüß dich" print
            "здравствуйте" print
            "こんにちは" print
            "안녕하세요" print
            "שָׁלוֹם " print
        ] with-style
    ] make-pane { 10 10 } <border> ;

: hello-unicode ( -- ) [ <hello-gadget> "გამარჯობა" open-window ] with-ui ;

MAIN: hello-unicode