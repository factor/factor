USING: kernel namespaces stomp tools.test ;
IN: stomp.tests

{ t "1.1" } [
    "1.2" stomp-version [
        "CONNECTED" <frame> "1.1" "accept-version" set-header
        dup adjust-stomp-version eq? stomp-version get
    ] with-variable
] unit-test

{ t "1.1" } [
    "1.1" stomp-version [
        "CONNECTED" <frame> "1.2" "accept-version" set-header
        dup adjust-stomp-version eq? stomp-version get
    ] with-variable
] unit-test

{ t "1.2" } [
    "1.2" stomp-version [
        "CONNECTED" <frame>
        dup adjust-stomp-version eq? stomp-version get
    ] with-variable
] unit-test
