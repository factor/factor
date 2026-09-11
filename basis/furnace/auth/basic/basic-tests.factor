! Copyright (C) 2013 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors tools.test furnace.auth furnace.auth.basic http.server
http.server.responses kernel http namespaces ;
IN: furnace.auth.basic.tests

CONSTANT: GET-AUTH "Basic Zm9vOmJhcg=="
{ "foo" "bar" } [ GET-AUTH parse-basic-auth ] unit-test

! Malformed credentials must be treated as a failed login, not a 500.
{ f f } [ "Basic %%%%" parse-basic-auth ] unit-test
{ f f } [ "Basic ~~~~" parse-basic-auth ] unit-test
{ f f } [ "Basic Zm9v" parse-basic-auth ] unit-test
{ "foo" "bar" } [ "basic Zm9vOmJhcg==" parse-basic-auth ] unit-test
{ "foo" "" } [ "Basic Zm9vOg==" parse-basic-auth ] unit-test
{ f f } [ f parse-basic-auth ] unit-test

{ 401 } [
    [
        logged-in-user off
        <request> "GET" >>method
            "Basic %%%%" "authorization" set-header init-request
        { } <304> <trivial-responder> <protected>
        "Test realm" <basic-auth-realm> f >>secure
        call-responder code>>
    ] with-scope
] unit-test

{ t } [ [ <request> "GET" >>method init-request
  "path" <304> <trivial-responder> "name" <basic-auth-realm>
   call-responder* >boolean
] with-scope ] unit-test
