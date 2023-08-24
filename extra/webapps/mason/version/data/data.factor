! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar db db.tuples db.types kernel
webapps.mason.version.files sequences ;
IN: webapps.mason.version.data

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
        version builder binary-release-name >>last-release ;

: update-binary-releases ( version builders -- )
    release new delete-tuples
    [ <release> insert-tuple ] with each ;

TUPLE: version
id version git-id timestamp source-path announcement-url ;

version "VERSIONS" {
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "version" "VERSION" TEXT }
    { "git-id" "GIT_ID" TEXT }
    { "timestamp" "TIMESTAMP" TIMESTAMP }
    { "source-path" "SOURCE_PATH" TEXT }
    { "announcement-url" "ANNOUNCEMENT_URL" TEXT }
} define-persistent

: update-version ( version git-id announcement-url -- )
    version new
        swap >>announcement-url
        swap >>git-id
        swap [ >>version ] [ source-release-name >>source-path ] bi
        now >>timestamp
    insert-tuple ;

: latest-version ( -- version )
    version new select-tuples last ;
