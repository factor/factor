USING: accessors db db.sqlite destructors furnace.actions furnace.auth
furnace.db http http.server http.server.responses io.files.unique kernel
locals namespaces sequences tools.test ;
IN: furnace.db.tests

TUPLE: test-login-realm ;
M: test-login-realm login-required* 3drop <403> ;

:: request-code ( responder -- code )
    ! This scope encloses the action's continuation capture, as in httpd.
    [
        <request> "GET" >>method init-request
        { } responder call-responder code>>
    ] with-destructors ;

:: exercise-exiting-action ( action expected -- responses-ok? pooled? )
    action "exiting-action.db" <sqlite-db> <db-persistence> [| responder |
        20 [ responder request-code expected = ] replicate [ ] all?
        responder pool>> connections>> length 1 =
    ] with-disposal ;

! Validation and login exits must return the connection to the outer
! request's pool, so successive requests reuse one live connection.
{ t t } [
    [
        <action>
            [ "SELECT 1" sql-query drop validation-failed ] >>init
            [ "unreachable" <text-content> ] >>display
        "400" exercise-exiting-action
    ] with-test-directory
] unit-test

{ t t } [
    [
        test-login-realm new realm [
            <action>
                [ "SELECT 1" sql-query drop "test permission" f login-required ] >>init
                [ "unreachable" <text-content> ] >>display
            "403" exercise-exiting-action
        ] with-variable
    ] with-test-directory
] unit-test
