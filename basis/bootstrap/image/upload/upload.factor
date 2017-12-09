! Copyright (C) 2008 Slava Pestov.
! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image checksums checksums.openssl cli.git fry
io io.directories io.encodings.ascii io.encodings.utf8 io.files
io.files.temp io.files.unique io.launcher io.pathnames kernel
make math.parser namespaces sequences splitting system ;
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
    image-path parent-directory git-current-branch ;

: git-branch-destination ( -- dest )
    build-images-destination get
    "sheeple@downloads.factorcode.org:downloads.factorcode.org/images/"
    or
    factor-git-branch "/" 3append ;

: checksums-path ( -- temp ) "checksums.txt" temp-file ;

: boot-image-names ( -- seq )
    image-names [ boot-image-name ] map ;

: compute-checksums ( -- )
    checksums-path ascii [
        boot-image-names [
            [ write bl ]
            [ openssl-md5 checksum-file bytes>hex-string print ]
            bi
        ] each
    ] with-file-writer ;

! Windows scp doesn't like pathnames with colons, it treats them as hostnames.
! Workaround for uploading checksums.txt created with temp-file.
! e.g. C:\Users\\Doug\\AppData\\Local\\Temp/factorcode.org\\Factor/checksums.txt
! ssh: Could not resolve hostname c: no address associated with name

HOOK: scp-name os ( -- path )
M: object scp-name "scp" ;
M: windows scp-name "pscp" ;

: upload-images ( -- )
    [
        \ scp-name get-global scp-name or ,
        boot-image-names %
        checksums-path ,
        git-branch-destination [ print flush ] [ , ] bi
    ] { } make try-process ;

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
            "." directory-files %
            build-destination ,
        ] { } make try-process
    ] with-build-images ;

: create-remote-upload-directory ( -- )
    '[
        "ssh" ,
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
