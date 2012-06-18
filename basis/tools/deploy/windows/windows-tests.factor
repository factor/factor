IN: tools.deploy.windows.tests
USING: tools.deploy.windows tools.test sequences ;

[ t ] [
    "foo" "test-copy-files" temp-file create-exe-dir
    ".exe" tail?
] unit-test
