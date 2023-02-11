! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http.server.responses kernel
sequences urls xml.syntax webapps.mason.backend
webapps.mason.utils ;
IN: webapps.mason.report

: build-report ( -- response )
    [
        current-builder [
            last-report>>
            "<div style=\"padding: 10px;\">" "</div>" surround
            <html-content>
        ] [ <404> ] if*
    ] with-mason-db ;

: <build-report-action> ( -- action )
    <action>
        [ validate-os/cpu ] >>init
        [ build-report ] >>display ;

: report-link ( builder -- xml )
    [ URL" report" clone ] dip
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    [XML <a href=<->>Latest build report</a> XML] ;
