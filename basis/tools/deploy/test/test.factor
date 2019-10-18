USING: accessors arrays bootstrap.image continuations
io.directories io.files.info io.files.temp io.launcher
io.backend kernel layouts math sequences system
tools.deploy.backend tools.deploy.config.editor ;
IN: tools.deploy.test

: test-image ( -- str )
    my-arch "test." ".image" surround ;

: shake-and-bake ( vocab -- )
    [ test-image temp-file delete-file ] ignore-errors
    "resource:" [
        [ vm test-image temp-file ] dip
        dup deploy-config make-deploy-image drop
    ] with-directory ;

ERROR: image-too-big actual-size max-size ;

: small-enough? ( n -- )
    [ test-image temp-file file-info size>> ]
    [
        cell 4 / *
        cpu ppc? [ 100000 + ] when
        os windows? [ 150000 + ] when
    ] bi*
    2dup <= [ 2drop ] [ image-too-big ] if ;

: deploy-test-command ( -- args )
    os macosx?
    "resource:Factor.app/Contents/MacOS/factor" normalize-path vm ?
    "-i=" test-image temp-file append 2array ;

: run-temp-image ( -- )
    deploy-test-command try-output-process ;
