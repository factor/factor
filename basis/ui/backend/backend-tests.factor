USING: continuations kernel locals namespaces tools.test ui.backend ;
IN: ui.backend.tests

:: with-test-backend ( backend quot: ( -- value ) -- value )
    ui-backend get-global :> previous
    [ backend ui-backend set-global quot call ]
    [ previous ui-backend set-global ] finally ; inline

{ "selected" } [
    f [
        "selected" register-ui-backend
        ui-backend get-global
    ] with-test-backend
] unit-test

! Loading an alternate backend must preserve an image's selected backend.
{ "selected" } [
    "selected" [
        "alternate" register-ui-backend
        ui-backend get-global
    ] with-test-backend
] unit-test
