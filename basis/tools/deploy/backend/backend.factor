! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bootstrap.image hashtables io io.directories
io.encodings.utf8 io.files io.files.temp io.launcher io.pathnames
kernel locals make namespaces prettyprint sequences splitting system
tools.deploy.config tools.deploy.config.editor tools.deploy.embed
tools.deploy.libraries vocabs.loader vocabs.metadata.resources ;
IN: tools.deploy.backend

: copy-vm ( executable bundle-name -- vm-path )
    prepend-path vm-path over copy-file ;

TUPLE: vocab-manifest vocabs libraries ;

: copy-resources ( manifest name dir -- )
    append-path swap vocabs>> [ copy-vocab-resources ] with each ;

ERROR: can't-deploy-library-file library ;

: copy-library ( dir library -- )
    dup find-library-file
    [ swap over file-name append-path copy-file ]
    [ can't-deploy-library-file ] ?if ;

: copy-libraries ( manifest name dir -- )
    append-path swap libraries>> [ copy-library ] with each ;

: deployed-image-name ( vocab -- str )
    ".image" append temp-file ;

: copy-lines ( -- )
    readln [ print flush copy-lines ] when* ;

: run-with-output ( arguments -- )
    <process>
        swap >>command
        +stdout+ >>stderr
        +closed+ >>stdin
        +low-priority+ >>priority
    utf8 [ copy-lines ] with-process-reader ;

: make-boot-image ( -- )
    ! If stage1 image doesn't exist, create one.
    my-boot-image-name resource-path exists?
    [ make-my-image ] unless ;

: staging-image-name ( profile -- name )
    "-" join "." my-arch-name 3append
    "staging." ".image" surround cache-file ;

: delete-staging-images ( -- )
    cache-directory [
        [ "staging." head? ] filter
        "." my-arch-name ".image" 3append [ tail? ] curry filter
        [ delete-file ] each
    ] with-directory-files ;

: staging-command-line ( profile -- flags )
    [
        [
            "-staging" , "-no-user-init" , "-pic=0" ,
            [ staging-image-name "-output-image=" prepend , ]
            [ " " join "-include=" prepend , ] bi
        ] [
            [ "-i=" my-boot-image-name append , ] [
                but-last staging-image-name "-i=" prepend ,
                "-resource-path=" "" resource-path append ,
                "-run=tools.deploy.restage" ,
            ] if-empty
        ] bi
    ] { } make ;

: run-factor ( vm-path flags -- )
    swap prefix dup . run-with-output ; inline

DEFER: ?make-staging-image

: make-staging-image ( profile -- )
    dup [ but-last ?make-staging-image ] unless-empty
    vm-path swap staging-command-line run-factor ;

: ?make-staging-image ( profile -- )
    dup staging-image-name exists?
    [ drop ] [ make-staging-image ] if ;

: make-deploy-config ( vocab -- file )
    [ deploy-config vocab-roots get vocab-roots associate assoc-union unparse-use ]
    [ "deploy-config-" prepend temp-file ] bi
    [ utf8 set-file-contents ] keep ;

: deploy-command-line ( image vocab manifest-file profile -- flags )
    [
        "-pic=0" ,
        staging-image-name "-i=" prepend ,
        "-vocab-manifest-out=" prepend ,
        [ "-deploy-vocab=" prepend , ]
        [ make-deploy-config "-deploy-config=" prepend , ] bi
        "-output-image=" prepend ,
        "-resource-path=" "" resource-path append ,
        "-run=tools.deploy.shaker" ,
    ] { } make ;

: parse-vocab-manifest-file ( path -- vocab-manifest )
    utf8 file-lines [ "empty vocab manifest!" throw ] [
        unclip-slice "VOCABS:" =
        [ { "LIBRARIES:" } split1 vocab-manifest boa ]
        [ "invalid vocab manifest!" throw ] if
    ] if-empty ;

:: make-deploy-image ( vm image vocab config -- manifest )
    make-boot-image

    config config>profile :> profile
    vocab "vocab-manifest-" prepend temp-file :> manifest-file
    image vocab manifest-file profile deploy-command-line :> flags

    profile ?make-staging-image
    vm flags run-factor
    manifest-file parse-vocab-manifest-file ;

:: make-deploy-image-executable ( vm image vocab config -- manifest )
    vm image vocab config make-deploy-image
    image vm embed-image ;

SYMBOL: open-directory-after-deploy?
t open-directory-after-deploy? set-global

HOOK: deploy* os ( vocab -- )

HOOK: deploy-path os ( vocab -- path )
