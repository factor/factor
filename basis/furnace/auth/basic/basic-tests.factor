! Copyright (C) 2013 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors tools.test furnace.auth.basic http.server
http.server.responses kernel http namespaces ;
IN: furnace.auth.basic.tests

CONSTANT: GET-AUTH "Basic Zm9vOmJhcg=="
{ "foo" "bar" } [ GET-AUTH parse-basic-auth ] unit-test

{ t } [ [ <request> "GET" >>method init-request
  "path" <304> <trivial-responder> "name" <basic-auth-realm>
   call-responder* >boolean
] with-scope ] unit-test
