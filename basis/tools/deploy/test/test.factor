USING: accessors arrays bootstrap.image io.backend
io.directories io.files.info io.files.temp io.launcher kernel
layouts math namespaces sequences system tools.deploy.backend
tools.deploy.config.editor tools.test ;
IN: tools.deploy.test

: test-image ( -- str )
    my-arch-name "test." ".image" surround ;

: test-image-path ( -- str )
    test-image temp-file ;

: shake-and-bake ( vocab -- )
    long-unit-tests-enabled? get [
        test-image-path ?delete-file
        [
            [ vm-path test-image temp-file ] dip
            dup deploy-config make-deploy-image drop
        ] with-resource-directory
    ] [
        drop
    ] if ;

ERROR: image-too-big actual-size max-size ;

: small-enough? ( n -- )
    [ test-image-path file-info size>> ]
    [
        cell 4 / *
        cpu ppc? [ 100000 + ] when
        os windows? [ 160000 + ] when
    ] bi*
    2dup <= [ 2drop ] [ image-too-big ] if ;

: deploy-test-command ( -- args )
    os macosx?
    "resource:Factor.app/Contents/MacOS/factor" normalize-path vm-path ?
    "-i=" test-image-path append 2array ;

: run-temp-image ( -- )
    deploy-test-command try-output-process ;
