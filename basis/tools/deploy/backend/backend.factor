! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make continuations.private kernel.private init
assocs kernel vocabs words sequences memory io system arrays
continuations math definitions mirrors splitting parser classes
summary layouts vocabs.loader prettyprint.config prettyprint debugger
io.streams.c io.files io.files.temp io.pathnames io.directories
io.directories.hierarchy io.backend quotations io.launcher
tools.deploy.config tools.deploy.config.editor bootstrap.image
io.encodings.utf8 destructors accessors hashtables
tools.deploy.libraries vocabs.metadata.resources
tools.deploy.embed locals ;
IN: tools.deploy.backend

: copy-vm ( executable bundle-name -- vm )
    prepend-path vm over copy-file ;

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
    #! If stage1 image doesn't exist, create one.
    my-boot-image-name resource-path exists?
    [ my-arch make-image ] unless ;

: bootstrap-profile ( -- profile )
    [
        deploy-math? get [ "math" , ] when
        deploy-threads? get [ "threads" , ] when
        "compiler" ,
        deploy-help? get [ "help" , ] when
        deploy-ui? get [ "ui" , ] when
        deploy-unicode? get [ "unicode" , ] when
        native-io? [ "io" , ] when
    ] { } make ;

: staging-image-name ( profile -- name )
    "-" join "." my-arch 3append
    "staging." ".image" surround cache-file ;

DEFER: ?make-staging-image

: staging-command-line ( profile -- flags )
    [
        "-staging" ,
        dup empty? [
            "-i=" my-boot-image-name append ,
        ] [
            dup but-last ?make-staging-image
            "-resource-path=" "" resource-path append ,
            "-i=" over but-last staging-image-name append ,
            "-run=tools.deploy.restage" ,
        ] if
        "-output-image=" over staging-image-name append ,
        "-include=" swap " " join append ,
        "-no-user-init" ,
        "-pic=0" ,
    ] { } make ;

: run-factor ( vm flags -- )
    swap prefix dup . run-with-output ; inline

: make-staging-image ( profile -- )
    vm swap staging-command-line run-factor ;

: ?make-staging-image ( profile -- )
    dup staging-image-name exists?
    [ drop ] [ make-staging-image ] if ;

: make-deploy-config ( vocab -- file )
    [ deploy-config vocab-roots get vocab-roots associate assoc-union unparse-use ]
    [ "deploy-config-" prepend temp-file ] bi
    [ utf8 set-file-contents ] keep ;

: deploy-command-line ( image vocab manifest-file config -- flags )
    [
        bootstrap-profile ?make-staging-image

        [
            "-i=" bootstrap-profile staging-image-name append ,
            "-resource-path=" "" resource-path append ,
            "-run=tools.deploy.shaker" ,
            "-vocab-manifest-out=" prepend ,
            [ "-deploy-vocab=" prepend , ]
            [ make-deploy-config "-deploy-config=" prepend , ] bi
            "-output-image=" prepend ,
            "-pic=0" ,
        ] { } make
    ] with-variables ;

: parse-vocab-manifest-file ( path -- vocab-manifest )
    utf8 file-lines [ "empty vocab manifest!" throw ] [
        unclip-slice "VOCABS:" =
        [ { "LIBRARIES:" } split1 vocab-manifest boa ]
        [ "invalid vocab manifest!" throw ] if
    ] if-empty ;

:: make-deploy-image ( vm image vocab config -- manifest )
    make-boot-image
    vocab "vocab-manifest-" prepend temp-file :> manifest-file
    image vocab manifest-file config deploy-command-line :> flags
    vm flags run-factor
    manifest-file parse-vocab-manifest-file ;

:: make-deploy-image-executable ( vm image vocab config -- manifest )
    vm image vocab config make-deploy-image
    image vm embed-image ;

HOOK: deploy* os ( vocab -- )
