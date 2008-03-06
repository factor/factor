IN: http.server.auth.providers.db.tests
USING: http.server.auth.providers
http.server.auth.providers.db tools.test
namespaces db db.sqlite db.tuples continuations
io.files ;

db-auth-provider "provider" set

"auth-test.db" temp-file sqlite-db [
    
    [ user drop-table ] ignore-errors
    [ user create-table ] ignore-errors

    "slava" "provider" get new-user

    [ "slava" "provider" get new-user ] [ user-exists? ] must-fail-with

    [ f ] [ "fdasf" "slava" "provider" get check-login ] unit-test

    [ "xx" "blah" "provider" get set-password ] [ no-such-user? ] must-fail-with

    "fdasf" "slava" "provider" get set-password

    [ t ] [ "fdasf" "slava" "provider" get check-login ] unit-test
] with-db
