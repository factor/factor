IN: http.server.auth.providers.db.tests
USING: http.server.auth.providers
http.server.auth.providers.db tools.test
namespaces db db.sqlite db.tuples continuations
io.files accessors kernel ;

from-db "provider" set

"auth-test.db" temp-file sqlite-db [

    [ user drop-table ] ignore-errors
    [ user create-table ] ignore-errors

    [ t ] [
        <user>
        "slava" >>username
        "foobar" >>password
        "slava@factorcode.org" >>email
        "provider" get new-user
        username>> "slava" =
    ] unit-test

    [ f ] [
        <user>
        "slava" >>username
        "provider" get new-user
    ] unit-test

    [ f ] [ "fdasf" "slava" "provider" get check-login >boolean ] unit-test

    [ t ] [ "foobar" "slava" "provider" get check-login >boolean ] unit-test

    [ f ] [ "xx" "blah" "provider" get set-password ] unit-test

    [ t ] [ "fdasf" "slava" "provider" get set-password ] unit-test

    [ t ] [ "fdasf" "slava" "provider" get check-login >boolean ] unit-test

    [ f ] [ "foobar" "slava" "provider" get check-login >boolean ] unit-test
] with-db
