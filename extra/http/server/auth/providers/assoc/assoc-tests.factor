IN: http.server.auth.providers.assoc.tests
USING: http.server.actions http.server.auth.providers 
http.server.auth.providers.assoc tools.test
namespaces accessors kernel ;

<action> <login>
    <users-in-memory> >>users
login set

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

[ t ] [ "fdasf" "slava" check-login >boolean ] unit-test

[ f ] [ "foobar" "slava" check-login >boolean ] unit-test
