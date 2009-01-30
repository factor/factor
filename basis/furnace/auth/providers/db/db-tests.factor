IN: furnace.auth.providers.db.tests
USING: furnace.actions
furnace.auth
furnace.auth.login
furnace.auth.providers
furnace.auth.providers.db tools.test
namespaces db db.sqlite db.tuples continuations
io.files io.files.temp io.directories accessors kernel ;

<action> "test" <login-realm> realm set

[ "auth-test.db" temp-file delete-file ] ignore-errors

"auth-test.db" temp-file <sqlite-db> [

    user ensure-table

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
