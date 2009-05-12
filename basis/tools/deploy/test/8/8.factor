USING: calendar game-input threads ui ui.gadgets.worlds kernel
method-chains system ;
IN: tools.deploy.test.8

TUPLE: my-world < world ;

BEFORE: my-world begin-world drop open-game-input ;

AFTER: my-world end-world drop close-game-input ;

: test-game-input ( -- )
    [
        f T{ world-attributes
             { world-class my-world }
             { title "Test" }
        } open-window
        1 seconds sleep
        0 exit
    ] with-ui ;

MAIN: test-game-input