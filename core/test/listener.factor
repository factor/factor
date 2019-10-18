USING: listener io test ;
IN: temporary

: hello "Hi" print ; parsing

[ [ ] ] [
    "USE: temporary hello" <string-reader> parse-interactive
] unit-test
