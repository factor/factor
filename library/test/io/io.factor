IN: scratchpad
USE: namespaces
USE: parser
USE: stack
USE: streams
USE: test

[ 4 ] [ "/library/test/io/no-trailing-eol.factor" run-resource ] unit-test

: lines-test ( stream -- line1 line2 )
    dup freadln swap dup freadln swap fclose ;

[
    "This is a line."
    "This is another line."
] [
    "/library/test/io/windows-eol.txt" <resource-stream> lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "/library/test/io/mac-os-eol.txt" <resource-stream> lines-test
] unit-test

[
    "This is a line.\rThis is another line.\r"
] [
    500 "/library/test/io/mac-os-eol.txt" <resource-stream> fread#
] unit-test
