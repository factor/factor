USING: accessors arrays continuations io.directories io.files.info
io.files.temp io.launcher io.backend kernel layouts math sequences system
tools.deploy.backend tools.deploy.config.editor ;
IN: tools.deploy.test

: shake-and-bake ( vocab -- )
    [ "test.image" temp-file delete-file ] ignore-errors
    "resource:" [
        [ vm "test.image" temp-file ] dip
        dup deploy-config make-deploy-image
    ] with-directory ;

: small-enough? ( n -- ? )
    [ "test.image" temp-file file-info size>> ] [ cell 4 / * ] bi* <= ;

: run-temp-image ( -- )
    os macosx?
    "resource:Factor.app/Contents/MacOS/factor" normalize-path vm ?
    "-i=" "test.image" temp-file append 2array try-output-process ;