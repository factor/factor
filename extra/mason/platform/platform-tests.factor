USING: mason.config mason.platform namespaces tools.test
strings system ;
IN: mason.platform.tests

{ t } [ platform string? ] unit-test

[
    linux target-os set
    x86.32 target-cpu set
    f target-variant set

    [ "linux-x86-32" ] [ platform ] unit-test
] with-scope

[
    windows target-os set
    x86.32 target-cpu set
    "xp" target-variant set

    [ "windows-x86-32-xp" ] [ platform ] unit-test
] with-scope
