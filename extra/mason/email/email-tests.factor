IN: mason.email.tests
USING: mason.email mason.common mason.config namespaces tools.test ;

[ "mason on linux-x86-64: 12345 -- error" ] [
    [
        "linux" target-os set
        "x86.64" target-cpu set
        "12345" current-git-id set
        status-error subject prefix-subject
    ] with-scope
] unit-test
