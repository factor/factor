IN: tools.deploy.tests
USING: tools.test system io.files kernel tools.deploy.config
tools.deploy.backend math sequences io.launcher arrays
namespaces continuations layouts accessors ;

: shake-and-bake ( vocab -- )
    [ "test.image" temp-file delete-file ] ignore-errors
    "resource:" [
        >r vm
        "test.image" temp-file
        r> dup deploy-config make-deploy-image
    ] with-directory ;

: small-enough? ( n -- ? )
    >r "test.image" temp-file file-info size>> r> <= ;

[ ] [ "hello-world" shake-and-bake ] unit-test

[ t ] [
    cell 8 = 8 5 ? 100000 * small-enough?
] unit-test

[ ] [ "sudoku" shake-and-bake ] unit-test

[ t ] [
    cell 8 = 20 10 ? 100000 * small-enough?
] unit-test

[ ] [ "hello-ui" shake-and-bake ] unit-test

[ "staging.math-compiler-ui-strip.image" ] [
    "hello-ui" deploy-config
    [ bootstrap-profile staging-image-name file-name ] bind
] unit-test

[ t ] [
    cell 8 = 40 20 ? 100000 * small-enough?
] unit-test

[ ] [ "maze" shake-and-bake ] unit-test

[ t ] [
    cell 8 = 30 15 ? 100000 * small-enough?
] unit-test

[ ] [ "bunny" shake-and-bake ] unit-test

[ t ] [
    cell 8 = 50 30 ? 100000 * small-enough?
] unit-test

[ ] [
    "tools.deploy.test.1" shake-and-bake
    vm "-i=" "test.image" temp-file append 2array try-process
] unit-test

[ ] [
    "tools.deploy.test.2" shake-and-bake
    vm "-i=" "test.image" temp-file append 2array try-process
] unit-test
