IN: tools.deploy.windows.tests
USING: tools.deploy.windows tools.test sequences ;

[ t ] [
    "foo" "resource:temp/test-copy-files" create-exe-dir
    ".exe" tail?
] unit-test
