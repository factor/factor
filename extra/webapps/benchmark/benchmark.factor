! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors furnace.actions http.server
http.server.dispatchers http.server.responses http.server.static
io.servers kernel namespaces ;

IN: webapps.benchmark

: <hello-action> ( -- action )
    <page-action>
        [ "Hello, world!" <text-content> ] >>display ;

TUPLE: benchmark-dispatcher < dispatcher ;

: <benchmark-dispatcher> ( -- dispatcher )
    benchmark-dispatcher new-dispatcher
        <hello-action> "hello" add-responder
        "resource:" <static> "static" add-responder ;

: run-benchmark-webapp ( -- )
    <benchmark-dispatcher>
        main-responder set-global
    8080 httpd wait-for-server ;

! Use this with apachebench:
!
!   * dynamic content
!     https://localhost:8080/hello
!
!   * static content
!     https://localhost:8080/static/readme.html

MAIN: run-benchmark-webapp
