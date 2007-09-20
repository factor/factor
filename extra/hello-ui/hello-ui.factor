USING: ui ui.gadgets.labels ;
IN: hello-ui

: hello ( -- )
    [ "Hello world" <label> "Hi" open-window ] with-ui ;

MAIN: hello
