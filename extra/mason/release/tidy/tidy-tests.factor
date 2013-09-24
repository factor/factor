USING: io.directories mason.config mason.release.tidy namespaces
sequences system tools.test ;
IN: mason.release.tidy.tests

! Normally, these words are run in the factor subdirectory
! of the build directory, and they look for a file named
! build-support/cleanup there. Use with-directory here to
! ensure we use the file from the current source tree instead.
[
    [ f ] [
        macosx target-os [
            "Factor.app" useless-files member?
        ] with-variable
    ] unit-test
    
    [ t ] [
        linux target-os [
            "Factor.app" useless-files member?
        ] with-variable
    ] unit-test
] with-resource-directory
