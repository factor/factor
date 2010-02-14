! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators furnace.actions html.forms
kernel mason.platform mason.report mason.server present
sequences webapps.mason webapps.mason.report
webapps.mason.utils xml.syntax ;
IN: webapps.mason.package

: building ( builder string -- xml )
    swap current-git-id>> git-link
    [XML <-> for <-> XML] ;

: status-string ( builder -- string )
    dup status>> {
        { +dirty+ [ drop "Dirty" ] }
        { +clean+ [ drop "Clean" ] }
        { +error+ [ drop "Error" ] }
        { +starting+ [ "Starting build" building ] }
        { +make-vm+ [ "Compiling VM" building ] }
        { +boot+ [ "Bootstrapping" building ] }
        { +test+ [ "Testing" building ] }
        [ 2drop "Unknown" ]
    } case ;

: current-status ( builder -- xml )
    [ status-string ]
    [ current-timestamp>> present " (as of " ")" surround ] bi
    2array ;

: build-status ( git-id timestamp -- xml )
    over [ [ git-link ] [ present ] bi* " (built on " ")" surround 2array ] [ 2drop f ] if ;

: packages-url ( builder -- url )
    [ os>> ] [ cpu>> ] bi (platform) "http://downloads.factorcode.org/" prepend ;

: package-link ( builder -- xml )
    [ packages-url ] [ last-release>> ] bi [ "/" glue ] keep link ;

: packages-link ( builder -- link )
    packages-url dup link ;

: clean-image-url ( builder -- url )
    [ os>> ] [ cpu>> ] bi (platform) "http://factorcode.org/images/clean/" prepend ;

: clean-image-link ( builder -- link )
    clean-image-url dup link ;

: last-build-status ( builder -- xml )
    [ last-git-id>> ] [ last-timestamp>> ] bi build-status ;

: clean-build-status ( builder -- xml )
    [ clean-git-id>> ] [ clean-timestamp>> ] bi build-status ;

: <download-package-action> ( -- action )
    <page-action>
    [
        [
            validate-os/cpu
            "os" value "cpu" value (platform) "platform" set-value
            current-builder {
                [ package-link "package" set-value ]
                [ release-git-id>> git-link "git-id" set-value ]
                [ requirements "requirements" set-value ]
                [ host-name>> "host-name" set-value ]
                [ current-status "status" set-value ]
                [ last-build-status "last-build" set-value ]
                [ clean-build-status "last-clean-build" set-value ]
                [ packages-link "binaries" set-value ]
                [ clean-image-link "clean-images" set-value ]
                [ report-link "last-report" set-value ]
            } cleave
        ] with-mason-db
    ] >>init ;
