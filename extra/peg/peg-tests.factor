! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test strings namespaces arrays sequences peg peg.private ;
IN: temporary

{ 0 1 2 } [
  0 next-id set-global get-next-id get-next-id get-next-id 
] unit-test

{ f } [
  "endbegin" "begin" token parse
] unit-test

{ "begin" "end" } [
  "beginend" "begin" token parse 
  { parse-result-ast parse-result-remaining } get-slots
  >string
] unit-test

{ f } [
  "" CHAR: a CHAR: z range parse
] unit-test

{ f } [
  "1bcd" CHAR: a CHAR: z range parse
] unit-test

{ CHAR: a } [
  "abcd" CHAR: a CHAR: z range parse parse-result-ast
] unit-test

{ CHAR: z } [
  "zbcd" CHAR: a CHAR: z range parse parse-result-ast
] unit-test

{ f } [
  "bad" "a" token "b" token 2array seq parse
] unit-test

{ V{ "g" "o" } } [
  "good" "g" token "o" token 2array seq parse parse-result-ast
] unit-test

{ "a" } [
  "abcd" "a" token "b" token 2array choice parse parse-result-ast
] unit-test

{ "b" } [
  "bbcd" "a" token "b" token 2array choice parse parse-result-ast
] unit-test

{ f } [
  "cbcd" "a" token "b" token 2array choice parse 
] unit-test

{ f } [
  "" "a" token "b" token 2array choice parse 
] unit-test

{ 0 } [
  "" "a" token repeat0 parse parse-result-ast length
] unit-test

{ 0 } [
  "b" "a" token repeat0 parse parse-result-ast length
] unit-test

{ V{ "a" "a" "a" } } [
  "aaab" "a" token repeat0 parse parse-result-ast 
] unit-test

{ f } [
  "" "a" token repeat1 parse 
] unit-test

{ f } [
  "b" "a" token repeat1 parse 
] unit-test

{ V{ "a" "a" "a" } } [
  "aaab" "a" token repeat1 parse parse-result-ast
] unit-test

{ V{ "a" "b" } } [ 
  "ab" "a" token optional "b" token 2array seq parse parse-result-ast 
] unit-test

{ V{ f "b" } } [ 
  "b" "a" token optional "b" token 2array seq parse parse-result-ast 
] unit-test

{ f } [ 
  "cb" "a" token optional "b" token 2array seq parse  
] unit-test

{ V{ CHAR: a CHAR: b } } [
  "ab" "a" token ensure CHAR: a CHAR: z range dup 3array seq parse parse-result-ast
] unit-test

{ f } [
  "bb" "a" token ensure CHAR: a CHAR: z range 2array seq parse 
] unit-test

{ t } [
  "a+b" 
  "a" token "+" token dup ensure-not 2array seq "++" token 2array choice "b" token 3array seq
  parse [ t ] [ f ] if
] unit-test

{ t } [
  "a++b" 
  "a" token "+" token dup ensure-not 2array seq "++" token 2array choice "b" token 3array seq
  parse [ t ] [ f ] if
] unit-test

{ t } [
  "a+b" 
  "a" token "+" token "++" token 2array choice "b" token 3array seq
  parse [ t ] [ f ] if
] unit-test

{ f } [
  "a++b" 
  "a" token "+" token "++" token 2array choice "b" token 3array seq
  parse [ t ] [ f ] if
] unit-test

{ 1 } [
  "a" "a" token [ drop 1 ] action parse parse-result-ast 
] unit-test

{ V{ 1 1 } } [
  "aa" "a" token [ drop 1 ] action dup 2array seq parse parse-result-ast 
] unit-test

{ f } [
  "b" "a" token [ drop 1 ] action parse 
] unit-test