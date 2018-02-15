USING: arrays continuations debugger io.streams.string peg tools.test ;

{ "Peg parsing error at character position 0.\nExpected 'A' or 'B'\nGot 'xxxx'\n" } [
    [ "xxxx" "A" token "B" token 2array choice parse ] [ ] recover
    [ error. ] with-string-writer
] unit-test
