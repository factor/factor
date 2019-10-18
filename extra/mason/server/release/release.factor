! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar db db.tuples db.types grouping io
io.encodings.ascii io.launcher kernel locals make
mason.release.archive mason.config mason.platform mason.server
namespaces sequences ;
IN: mason.server.release

: platform ( builder -- string )
    [ os>> ] [ cpu>> ] bi (platform) ;

: package-name ( builder -- string )
    [ platform ] [ last-release>> ] bi "/" glue ;

: release-name ( version builder -- string )
    [
        "releases/" %
        over % "/" %
        [ "factor-" % platform % "-" % % ]
        [ os>> extension % ]
        bi
    ] "" make ;

: release-command ( version builder -- command )
    [
        "cp " %
        [ nip package-name % " " % ] [ release-name % ] 2bi
    ] "" make ;

TUPLE: release
host-name os cpu
last-release release-git-id ;

release "RELEASES" {
    { "host-name" "HOST_NAME" TEXT +user-assigned-id+ }
    { "os" "OS" TEXT +user-assigned-id+ }
    { "cpu" "CPU" TEXT +user-assigned-id+ }
    { "last-release" "LAST_RELEASE" TEXT }
    { "release-git-id" "RELEASE_GIT_ID" TEXT }
} define-persistent

:: <release> ( version builder -- release )
    release new
        builder host-name>> >>host-name
        builder os>> >>os
        builder cpu>> >>cpu
        builder release-git-id>> >>release-git-id
        version builder release-name >>last-release ;

: execute-on-server ( string -- )
    [ "ssh" , upload-host get , "-l" , upload-username get , ] { } make
    <process>
        swap >>command
        5 minutes >>timeout
    ascii [ write ] with-process-writer ;

: release-script ( version builders -- string )
    [ upload-directory get "cd " "\n" surround ] 2dip
    [ release-command ] with map "\n" join
    append ;

: create-releases ( version builders -- )
    release-script execute-on-server ;

: update-releases ( version builders -- )
    [
        release new delete-tuples
        [ <release> insert-tuple ] with each
    ] with-transaction ;

: check-releases ( builders -- )
    [ release-git-id>> ] map all-equal?
    [ "Not all builders are up to date" throw ] unless ;

: do-release ( version -- )
    [
        builder new select-tuples
        [ nip check-releases ]
        [ create-releases ]
        [ update-releases ]
        2tri
    ] with-mason-db ;
