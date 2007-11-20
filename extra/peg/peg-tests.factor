! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test strings namespaces arrays peg ;
IN: temporary

{ 0 1 2 } [
  0 next-id set-global get-next-id get-next-id get-next-id 
] unit-test

{ "0123456789" } [
  "0123456789" 0 <parse-state> 0 state-tail parse-state-input >string
] unit-test

{ "56789" } [
  "0123456789" 5 <parse-state> 0 state-tail parse-state-input >string
] unit-test

{ "789" } [
  "0123456789" 5 <parse-state> 2 state-tail parse-state-input >string
] unit-test

{ f } [
  "endbegin" 0 <parse-state> "begin" token parse
] unit-test

{ "begin" "begin" "end" } [
  "beginend" 0 <parse-state> "begin" token parse 
  { parse-result-matched parse-result-ast parse-result-remaining } get-slots
  parse-state-input >string
] unit-test

{ f } [
  "" 0 <parse-state> CHAR: a CHAR: z range parse
] unit-test

{ f } [
  "1bcd" 0 <parse-state> CHAR: a CHAR: z range parse
] unit-test

{ CHAR: a } [
  "abcd" 0 <parse-state> CHAR: a CHAR: z range parse parse-result-ast
] unit-test

{ CHAR: z } [
  "zbcd" 0 <parse-state> CHAR: a CHAR: z range parse parse-result-ast
] unit-test

{ f } [
  "bad" 0 <parse-state> "a" token "b" token 2array seq parse
] unit-test

{ "go" } [
  "good" 0 <parse-state> "g" token "o" token 2array seq parse parse-result-matched
] unit-test

{ "a" } [
  "abcd" 0 <parse-state> "a" token "b" token 2array choice parse parse-result-matched
] unit-test

{ "b" } [
  "bbcd" 0 <parse-state> "a" token "b" token 2array choice parse parse-result-matched
] unit-test

{ f } [
  "cbcd" 0 <parse-state> "a" token "b" token 2array choice parse 
] unit-test

{ f } [
  "" 0 <parse-state> "a" token "b" token 2array choice parse 
] unit-test