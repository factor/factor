! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar db2.types kernel locals orm.persistent
orm.tuples sequences webapps.mason.version.files ;
IN: webapps.mason.version.data

TUPLE: release
host-name os cpu
last-release release-git-id ;

PERSISTENT: { release "RELEASES" }
    { "host-name" TEXT +user-assigned-key+ }
    { "os" TEXT +user-assigned-key+ }
    { "cpu" TEXT +user-assigned-key+ }
    { "last-release" TEXT }
    { "release-git-id" TEXT } ;

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

PERSISTENT: { version "VERSIONS" }
    { "id" INTEGER +db-assigned-key+ }
    { "version" TEXT }
    { "git-id" TEXT }
    { "timestamp" TIMESTAMP }
    { "source-path" TEXT }
    { "announcement-url" TEXT } ;

: update-version ( version git-id announcement-url -- )
    version new
        swap >>announcement-url
        swap >>git-id
        swap [ >>version ] [ source-release-name >>source-path ] bi
        now >>timestamp
    insert-tuple ;

: latest-version ( -- version )
    version new select-tuples last ;
