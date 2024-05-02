! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs db.tuples furnace.actions
furnace.utilities html.forms kernel mason.config math.parser
namespaces sequences urls validators webapps.mason.backend
webapps.mason.version.data xml.syntax ;
IN: webapps.mason.utils

: link ( url label -- xml )
    [XML <a href=<->><-></a> XML] ;

: validate-os/cpu ( -- )
    {
        { "os" [ v-one-line ] }
        { "cpu" [ v-one-line ] }
    } validate-params ;

: validate-benchmark-selection ( -- )
    {
        { "host" [ [ v-one-line ] v-optional ] }
        { "os" [ [ v-one-line ] v-optional ] }
        { "cpu" [ [ v-one-line ] v-optional ] }
        { "git" [ [ v-one-line ] v-optional ] }
        { "run" [ [ v-one-line ] v-optional ] }
        { "timestamp" [ [ v-one-line ] v-optional ] }
        { "name" [ [ v-one-line ] v-optional ] }
    } validate-params ;

: selected-runs ( -- runs )
    run new
    "run" value dec> >>run-id
    "timestamp" value >>timestamp
    "host" value >>host-name
    "os" value >>os
    "cpu" value >>cpu
    "git" value >>git-id
    select-tuples ;

: selected-benchmarks ( -- benchmarks runs )
    selected-runs [ [ run-id>> ] keep ] map>alist
    [
        keys [ V{ } clone benchmark new "name" value >>name ] dip
        [ >>run-id select-tuples append! ] with each
    ] keep ;

: current-builder ( -- builder/f )
    builder new "os" value >>os "cpu" value >>cpu select-tuple ;

: current-release ( -- builder/f )
    release new "os" value >>os "cpu" value >>cpu select-tuple ;

: requirements ( builder -- xml )
    os>> {
        { "windows" "Windows 10, Windows 11, or newer" }
        { "macosx" "macOS 11 (Big Sur) or newer" }
        { "linux" "Ubuntu Linux 20.04 or newer (other distributions may also work)" }
    } at [XML <ul><li><-></li></ul> XML] ;

: download-url ( string -- string' )
    "https://downloads.factorcode.org/" prepend ;

: platform-url ( url builder -- url )
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    adjust-url ;

: package-url ( builder -- url )
    [ URL" https://builds.factorcode.org/package" clone ] dip
    platform-url ;

: report-url ( builder -- url )
    [ URL" https://builds.factorcode.org/report" clone ] dip
    platform-url ;

: release-url ( builder -- url )
    [ URL" https://builds.factorcode.org/release" clone ] dip
    platform-url ;

: validate-secret ( -- )
    { { "secret" [ v-one-line ] } } validate-params
    "secret" value status-secret get =
    [ validation-failed ] unless ;
