USING: tools.test io.pipes io.unix.pipes io.encodings.utf8
io.encodings io namespaces sequences ;
IN: io.unix.pipes.tests

[ { 0 0 } ] [ { "ls" "grep x" } run-pipeline ] unit-test

[ { 0 f 0 } ] [
    {
        "ls"
        [
            input-stream [ utf8 <decoder> ] change
            input-stream get lines reverse [ print ] each f
        ]
        "grep x"
    } run-pipeline
] unit-test
