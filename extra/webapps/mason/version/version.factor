! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bitly combinators db.tuples debugger fry
grouping io io.streams.string kernel locals make sequences
threads mason.email mason.twitter webapps.mason.backend
webapps.mason.version.common webapps.mason.version.data
webapps.mason.version.files webapps.mason.version.source
webapps.mason.version.binary ;
IN: webapps.mason.version

: check-releases ( builders -- )
    [ release-git-id>> ] map all-equal?
    [ "Some builders are out of date" throw ] unless ;

: make-release-directory ( version -- )
    "Creating release directory..." print flush
    [ "mkdir -p " % "" release-directory remote-directory % "\n" % ] "" make
    execute-on-server ;

: tweet-release ( version announcement-url -- )
    [
        "Factor " %
        [ % " released -- " % ] [ shorten-url % ] bi*
    ] "" make mason-tweet ;

:: (do-release) ( version announcement-url -- )
    [
        builder new select-tuples :> builders
        builders first release-git-id>> :> git-id

        builders check-releases
        version make-release-directory
        version builders do-binary-release
        version builders update-binary-releases
        version git-id do-source-release
        version git-id announcement-url update-version
        version announcement-url tweet-release

        "Done." print flush
    ] with-mason-db ;

: send-release-email ( string version -- )
    [ "text/plain" ] dip "Release output: " prepend mason-email ;

:: do-release ( version announcement-url -- )
    [
        [
            [
                version announcement-url (do-release)
            ] try
        ] with-string-writer
        version send-release-email
    ] "Mason release" spawn drop ;
