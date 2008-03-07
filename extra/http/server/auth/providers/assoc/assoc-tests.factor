IN: http.server.auth.providers.assoc.tests
USING: http.server.auth.providers 
http.server.auth.providers.assoc tools.test
namespaces ;

<assoc-auth-provider> "provider" set

"slava" "provider" get new-user

[ "slava" "provider" get new-user ] [ user-exists? ] must-fail-with

[ f ] [ "fdasf" "slava" "provider" get check-login ] unit-test

[ "xx" "blah" "provider" get set-password ] [ no-such-user? ] must-fail-with

"fdasf" "slava" "provider" get set-password

[ t ] [ "fdasf" "slava" "provider" get check-login ] unit-test
