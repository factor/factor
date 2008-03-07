IN: tools.deploy.tests
USING: tools.test system io.files kernel tools.deploy.config
tools.deploy.backend math ;

: shake-and-bake
    "." resource-path [
        vm
        "hello.image" temp-file
        rot dup deploy-config make-deploy-image
    ] with-directory ;

[ ] [ "hello-world" shake-and-bake ] unit-test

[ t ] [
    "hello.image" temp-file file-length 500000 <=
] unit-test

[ ] [ "hello-ui" shake-and-bake ] unit-test

[ t ] [
    "hello.image" temp-file file-length 2000000 <=
] unit-test
