USING: io.files.links io.launcher io.pathnames kernel locals make
sequences system tools.test ;
IN: cocoa.application.tests

! #1745: Cocoa must find the app bundle even when the executable is
! reached through symlinks outside it, from another working directory.
:: test-symlink-launch ( -- )
    vm-path resolve-symlinks :> executable
    image-path absolute-path :> image
    "" resource-path :> resources
    [
        executable "factor-link" make-link
        "factor-link" "second-link" make-link
        [
            "second-link" absolute-path ,
            image "-i=" prepend ,
            resources "-resource-path=" prepend ,
            "-no-user-init" ,
            "-e=USING: cocoa.application system ; running.app? [ 0 ] [ 1 ] if exit" ,
        ] { } make try-output-process
    ] with-test-directory ;

{ } [ test-symlink-launch ] unit-test
