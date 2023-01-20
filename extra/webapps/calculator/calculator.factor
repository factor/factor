! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions furnace.alloy
furnace.redirection html.forms http.server
http.server.dispatchers kernel math namespaces urls validators
webapps.utils ;
IN: webapps.calculator

TUPLE: calculator < dispatcher ;

: <calculator-action> ( -- action )
    <page-action>

    [
        { { "z" [ [ v-number ] v-optional ] } } validate-params
    ] >>init

    { calculator "calculator" } >>template

    [
        {
            { "x" [ v-number ] }
            { "y" [ v-number ] }
        } validate-params

        URL" $calculator" clone "x" value "y" value + "z" set-query-param
        <redirect>
    ] >>submit ;

: <calculator> ( -- responder )
    calculator new-dispatcher
        <calculator-action> >>default ;

! Deployment example
: calculator-db ( -- db ) "calculator.db" <temp-sqlite-db> ;

: <calculator-app> ( -- dispatcher )
    <calculator> calculator-db <alloy> ;

! Calculator runs at port 8081 and 8431
: run-calculator ( -- )
    <calculator-app> main-responder set-global
    run-test-httpd ;

MAIN: run-calculator
