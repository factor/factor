IN: tools.deploy.windows.tests
USING: io.files.temp tools.deploy.windows tools.test sequences ;

[ t ] [
    "foo" "test-copy-files" temp-file create-exe-dir
    ".exe" tail?
] unit-test
