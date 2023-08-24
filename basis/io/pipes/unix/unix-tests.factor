USING: tools.test io.pipes io.pipes.unix io.encodings.utf8
io.encodings io namespaces sequences splitting ;

{ { 0 0 } } [ { "ls" "grep ." } run-pipeline ] unit-test

{ { 0 f 0 } } [
    {
        "ls"
        [
            input-stream [ utf8 <decoder> ] change
            output-stream [ utf8 <encoder> ] change
            input-stream get stream-lines reverse [ print ] each f
        ]
        "grep ."
    } run-pipeline
] unit-test
