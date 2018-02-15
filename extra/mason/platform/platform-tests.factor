USING: mason.config mason.platform namespaces tools.test
strings system ;

{ t } [ platform string? ] unit-test

{ "linux-x86-32" } [
    H{
        { target-os linux }
        { target-cpu x86.32 }
        { target-variant f }
    } [ platform ] with-variables
] unit-test

{ "windows-x86-32-xp" } [
    H{
        { target-os windows }
        { target-cpu x86.32 }
        { target-variant "xp" }
    } [ platform ] with-variables
] unit-test
