USING: fonts pdf.wrap tools.test ;

{ "hello,      " "extra spaces" } [
    "hello,      extra spaces" word-split1
] unit-test

{ { "hello, " "world " "how " "are " "you?" } } [
    "hello, world how are you?" word-split
] unit-test

{ { "hello, world " "how are you?" } } [
    "hello, world how are you?" monospace-font 100 visual-wrap
] unit-test
