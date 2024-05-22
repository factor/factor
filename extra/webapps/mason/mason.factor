! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions furnace.auth furnace.db
furnace.redirection http.server.dispatchers urls
webapps.mason.backend webapps.mason.grids webapps.mason.package
webapps.mason.release webapps.mason.report webapps.mason.benchmarks
webapps.mason.downloads webapps.mason.counter
webapps.mason.status-update webapps.mason.docs-update
webapps.mason.dashboard webapps.mason.make-release
webapps.mason.increment-counter ;
IN: webapps.mason

TUPLE: mason-app < dispatcher ;

SYMBOL: build-engineer?

build-engineer? define-capability

: <mason-protected> ( responder -- responder' )
    <protected>
        "access the build farm dashboard" >>description
        { build-engineer? } >>capabilities ;

: <mason-app> ( -- dispatcher )
    mason-app new-dispatcher
    <build-report-action>
        "report" add-responder

    <benchmark-results-action>
        "benchmark-results" add-responder

    <download-package-action>
        { mason-app "download-package" } >>template
        "package" add-responder

    <download-release-action>
        { mason-app "download-release" } >>template
        "release" add-responder

    <downloads-action>
        { mason-app "downloads" } >>template
        "downloads" add-responder

    <status-update-action>
        "status-update" add-responder

    <docs-update-action>
        "docs-update" add-responder

    <counter-action>
        "counter" add-responder

    <dispatcher>
        <dashboard-action>
            { mason-app "dashboard" } >>template
            "" add-responder

        <make-release-action> <mason-protected>
            "make-release" add-responder

        <increment-counter-action> <mason-protected>
            "increment-counter" add-responder

        "dashboard" add-responder

    <action>
        [ URL" $mason-app/dashboard" <redirect> ] >>display
        "" add-responder
    ;
