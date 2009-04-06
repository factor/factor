IN: mason.child.tests
USING: mason.child mason.config tools.test namespaces ;

[ { "make" "winnt-x86-32" } ] [
    [
        "winnt" target-os set
        "x86.32" target-cpu set
        make-cmd
    ] with-scope
] unit-test

[ { "make" "macosx-x86-32" } ] [
    [
        "macosx" target-os set
        "x86.32" target-cpu set
        make-cmd
    ] with-scope
] unit-test

[ { "gmake" "netbsd-ppc" } ] [
    [
        "netbsd" target-os set
        "ppc" target-cpu set
        make-cmd
    ] with-scope
] unit-test

[ { "./factor" "-i=boot.macosx-ppc.image" "-no-user-init" } ] [
    [
        "macosx" target-os set
        "ppc" target-cpu set
        boot-cmd
    ] with-scope
] unit-test

[ { "./factor.com" "-i=boot.x86.32.image" "-no-user-init" } ] [
    [
        "winnt" target-os set
        "x86.32" target-cpu set
        boot-cmd
    ] with-scope
] unit-test
