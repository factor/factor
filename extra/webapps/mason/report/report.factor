! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http.server.responses kernel
urls xml.syntax webapps.mason.backend webapps.mason.utils ;
IN: webapps.mason.report

: <build-report-action> ( -- action )
    <action>
        [ validate-os/cpu ] >>init
        [
            [
                current-builder last-report>>
                <html-content>
            ] with-mason-db
        ] >>display ;

: report-link ( builder -- xml )
    [ URL" report" ] dip
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    [XML <a href=<->>Latest build report</a> XML] ;
