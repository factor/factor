! Copyright (C) 2008 Slava Pestov.
! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays bootstrap.image checksums checksums.openssl
hex-strings io io.directories io.encodings.ascii
io.encodings.utf8 io.files io.files.temp io.files.unique
io.launcher io.pathnames kernel make namespaces sequences
splitting system unicode ;
IN: bootstrap.image.upload

SYMBOL: upload-images-destination
SYMBOL: build-images-destination

: latest-destination ( -- dest )
    upload-images-destination get
    "sheeple@downloads.factorcode.org:downloads.factorcode.org/images/master/"
    or ;

: build-destination ( -- dest )
    build-images-destination get
    "sheeple@downloads.factorcode.org:downloads.factorcode.org/images/build/"
    or ;

: factor-git-branch ( -- name )
    image-path parent-directory [
        { "git" "rev-parse" "--abbrev-ref" "HEAD" }
        utf8 <process-reader> stream-contents
        [ unicode:blank? ] trim-tail
    ] with-directory ;

: git-branch-destinations ( -- dests )
    build-images-destination get
    "sheeple@downloads.factorcode.org:downloads.factorcode.org/images/"
    or
    factor-git-branch dup { "master" "main" } member?
    [ drop { "master" "main" } ] [ 1array ] if
    [ "/" 3append ] with map ;

: checksums-path ( -- temp ) "checksums.txt" temp-file ;

: boot-image-names ( -- seq )
    image-names [ boot-image-name ] map ;

: compute-checksums ( -- )
    checksums-path ascii [
        boot-image-names [
            [ write bl ]
            [ openssl-md5 checksum-file bytes>hex-string write bl ]
            [ openssl-sha256 checksum-file bytes>hex-string print ]
            tri
        ] each
    ] with-file-writer ;

: scp-name ( -- path ) "scp" ;

: upload-images ( -- )
    git-branch-destinations [
        [
            [
                \ scp-name get-global scp-name or ,
                "-4" , ! force ipv4
                boot-image-names %
                checksums-path ,
            ] { } make
        ] dip suffix try-process
    ] each ;

: append-build ( path -- path' )
    vm-git-id "." glue ;

: checksum-lines-append-build ( -- )
    "checksums.txt" utf8 [
        [ " " split1 [ append-build ] dip " " glue ] map
    ] change-file-lines ;

: with-build-images ( quot -- )
    [ boot-image-names [ absolute-path ] map ] dip
    '[
        [
            ! Copy boot images
            _ "." copy-files-into
            ! Copy checksums
            checksums-path "." copy-file-into
            ! Rewrite checksum lines with build number
            checksum-lines-append-build
            ! Rename file to file.build-number
            "." directory-files [ dup append-build move-file ] each
            ! Run the quot in the unique directory
            @
        ] cleanup-unique-directory
    ] with-temp-directory ; inline

: upload-build-images ( -- )
    [
        [
            \ scp-name get-global scp-name or ,
            "-4" , ! force ipv4
            "." directory-files %
            build-destination ,
        ] { } make try-process
    ] with-build-images ;

: create-remote-upload-directory ( -- )
    '[
        "ssh" ,
        "-4" , ! force ipv4
        "sheeple@downloads.factorcode.org" ,
        "mkdir -p downloads.factorcode.org/images/" factor-git-branch append ,
    ] { } make try-process ;

: upload-new-images ( -- )
    [
        make-images
        "Computing checksums..." print flush
        compute-checksums
        "Creating remote directory..." print flush
        create-remote-upload-directory
        "Uploading images..." print flush
        upload-images
        "Uploading build images..." print flush
        upload-build-images
    ] with-resource-directory ;

MAIN: upload-new-images
