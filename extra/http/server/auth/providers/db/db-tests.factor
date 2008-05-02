IN: http.server.auth.providers.db.tests
USING: http.server.actions
http.server.auth.login
http.server.auth.providers
http.server.auth.providers.db tools.test
namespaces db db.sqlite db.tuples continuations
io.files accessors kernel ;

<action> <login>
    users-in-db >>users
login set

[ "auth-test.db" temp-file delete-file ] ignore-errors

"auth-test.db" temp-file sqlite-db [

    init-users-table

    [ t ] [
        "slava" <user>
            "foobar" >>encoded-password
            "slava@factorcode.org" >>email
            H{ } clone >>profile
            users new-user
            username>> "slava" =
    ] unit-test

    [ f ] [
        "slava" <user>
            H{ } clone >>profile
        users new-user
    ] unit-test

    [ f ] [ "fdasf" "slava" check-login >boolean ] unit-test

    [ ] [ "foobar" "slava" check-login "user" set ] unit-test

    [ t ] [ "user" get >boolean ] unit-test

    [ ] [ "user" get "fdasf" >>encoded-password drop ] unit-test

    [ ] [ "user" get users update-user ] unit-test

    [ t ] [ "fdasf" "slava" check-login >boolean ] unit-test

    [ f ] [ "foobar" "slava" check-login >boolean ] unit-test
] with-db
