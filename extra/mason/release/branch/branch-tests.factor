USING: mason.release.branch mason.config tools.test namespaces
system ;

{ { "git" "push" "-f" "joe@blah.com:/my/git" "master:clean-linux-x86-32" } } [
    [
        "joe" branch-username set
        "blah.com" branch-host set
        "/my/git" branch-directory set
        linux target-os set
        x86.32 target-cpu set
        push-to-clean-branch-cmd
    ] with-scope
] unit-test

{ { "scp" "boot.windows-x86.64.image" "joe@blah.com:/stuff/clean/windows-x86-64" } } [
    [
        "scp" scp-command set
        "joe" image-username set
        "blah.com" image-host set
        "/stuff/clean" image-directory set
        windows target-os set
        x86.64 target-cpu set
        upload-clean-image-cmd
    ] with-scope
] unit-test
