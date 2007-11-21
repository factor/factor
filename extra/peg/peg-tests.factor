! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test strings namespaces arrays sequences peg ;
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

{ "begin" "end" } [
  "beginend" 0 <parse-state> "begin" token parse 
  { parse-result-ast parse-result-remaining } get-slots
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

{ V{ "g" "o" } } [
  "good" 0 <parse-state> "g" token "o" token 2array seq parse parse-result-ast
] unit-test

{ "a" } [
  "abcd" 0 <parse-state> "a" token "b" token 2array choice parse parse-result-ast
] unit-test

{ "b" } [
  "bbcd" 0 <parse-state> "a" token "b" token 2array choice parse parse-result-ast
] unit-test

{ f } [
  "cbcd" 0 <parse-state> "a" token "b" token 2array choice parse 
] unit-test

{ f } [
  "" 0 <parse-state> "a" token "b" token 2array choice parse 
] unit-test

{ 0 } [
  "" 0 <parse-state> "a" token repeat0 parse parse-result-ast length
] unit-test

{ 0 } [
  "b" 0 <parse-state> "a" token repeat0 parse parse-result-ast length
] unit-test

{ V{ "a" "a" "a" } } [
  "aaab" 0 <parse-state> "a" token repeat0 parse parse-result-ast 
] unit-test

{ f } [
  "" 0 <parse-state> "a" token repeat1 parse 
] unit-test

{ f } [
  "b" 0 <parse-state> "a" token repeat1 parse 
] unit-test

{ V{ "a" "a" "a" } } [
  "aaab" 0 <parse-state> "a" token repeat1 parse parse-result-ast
] unit-test

{ V{ "a" "b" } } [ 
  "ab" 0 <parse-state> "a" token optional "b" token 2array seq parse parse-result-ast 
] unit-test

{ V{ f "b" } } [ 
  "b" 0 <parse-state> "a" token optional "b" token 2array seq parse parse-result-ast 
] unit-test

{ f } [ 
  "cb" 0 <parse-state> "a" token optional "b" token 2array seq parse  
] unit-test

{ V{ CHAR: a CHAR: b } } [
  "ab" 0 <parse-state> "a" token ensure CHAR: a CHAR: z range dup 3array seq parse parse-result-ast
] unit-test

{ f } [
  "bb" 0 <parse-state> "a" token ensure CHAR: a CHAR: z range 2array seq parse 
] unit-test

{ t } [
  "a+b" 0 <parse-state>
  "a" token "+" token dup ensure-not 2array seq "++" token 2array choice "b" token 3array seq
  parse [ t ] [ f ] if
] unit-test

{ t } [
  "a++b" 0 <parse-state>
  "a" token "+" token dup ensure-not 2array seq "++" token 2array choice "b" token 3array seq
  parse [ t ] [ f ] if
] unit-test

{ t } [
  "a+b" 0 <parse-state>
  "a" token "+" token "++" token 2array choice "b" token 3array seq
  parse [ t ] [ f ] if
] unit-test

{ f } [
  "a++b" 0 <parse-state>
  "a" token "+" token "++" token 2array choice "b" token 3array seq
  parse [ t ] [ f ] if
] unit-test

{ 1 } [
  "a" 0 <parse-state> "a" token [ drop 1 ] action parse parse-result-ast 
] unit-test

{ V{ 1 1 } } [
  "aa" 0 <parse-state> "a" token [ drop 1 ] action dup 2array seq parse parse-result-ast 
] unit-test

{ f } [
  "b" 0 <parse-state> "a" token [ drop 1 ] action parse 
] unit-test