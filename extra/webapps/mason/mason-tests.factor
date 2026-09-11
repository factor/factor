USING: accessors continuations db db.sqlite destructors http http.server
http.server.requests io.files.unique io.streams.string kernel locals
namespaces sequences sets tools.annotations tools.test
webapps.mason webapps.mason.backend ;
IN: webapps.mason.tests

: database-connections ( -- connections )
    disposables get members [ db-connection? ] filter ;

:: with-test-mason-db ( quot -- )
    ! Keep the test independent of the user's ~/mason.db.
    \ mason-db [ drop [ "mason-validation.db" <sqlite-db> ] ] annotate
    database-connections :> before
    [ quot call ] [
        database-connections before diff dispose-each
        \ mason-db reset
    ] finally ; inline

: invalid-mason-response ( path -- code )
    "GET http://localhost" " HTTP/1.1\r\nHost: localhost\r\n\r\n" surround
    [ read-request ] with-string-reader init-request
    request get dispatch-request code>> ;

! These requests used to return 400 while silently leaking one SQLite
! connection each: validation-failed jumped past with-mason-db cleanup.
{ t t } [
    [
        [
            database-connections length
            <mason-app> main-responder [
                {
                    "/package"
                    "/release"
                    "/package?os=linux"
                    "/release?cpu=x86.64"
                    "/release?os=macosx&amp%3Bcpu=x86.32"
                    "/release/.env"
                    "/package?os=linux%0A&cpu=x86.64"
                    "/release?os=linux&cpu=x86.64%0A"
                } [ invalid-mason-response ] map
            ] with-variable
            [ "400" = ] all?
            swap database-connections length =
        ] with-test-mason-db
    ] with-test-directory
] unit-test
