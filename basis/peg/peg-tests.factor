! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays compiler concurrency.futures
continuations kernel make math namespaces peg peg.parsers
peg.private sequences strings tools.test words ;

IN: peg.tests

{ } [ reset-pegs ] unit-test

[
    "endbegin" "begin" token parse
] must-fail

{ "begin" "end" } [
    "beginend" "begin" token (parse)
    [ ast>> ] [ remaining>> ] bi
    >string
] unit-test

[
    "" CHAR: a CHAR: z range parse
] must-fail

[
    "1bcd" CHAR: a CHAR: z range parse
] must-fail

{ CHAR: a } [
    "abcd" CHAR: a CHAR: z range parse
] unit-test

{ CHAR: z } [
    "zbcd" CHAR: a CHAR: z range parse
] unit-test

[
    "bad" "a" token "b" token 2array seq parse
] must-fail

{ V{ "g" "o" } } [
    "good" "g" token "o" token 2array seq parse
] unit-test

{ "a" } [
    "abcd" "a" token "b" token 2array choice parse
] unit-test

{ "b" } [
    "bbcd" "a" token "b" token 2array choice parse
] unit-test

[
    "cbcd" "a" token "b" token 2array choice parse
] must-fail

[
    "" "a" token "b" token 2array choice parse
] must-fail

{ 0 } [
    "" "a" token repeat0 parse length
] unit-test

{ 0 } [
    "b" "a" token repeat0 parse length
] unit-test

{ V{ "a" "a" "a" } } [
    "aaab" "a" token repeat0 parse
] unit-test

[
    "" "a" token repeat1 parse
] must-fail

[
    "b" "a" token repeat1 parse
] must-fail

{ V{ "a" "a" "a" } } [
    "aaab" "a" token repeat1 parse
] unit-test

{ V{ "a" "b" } } [
    "ab" "a" token optional "b" token 2array seq parse
] unit-test

{ V{ f "b" } } [
    "b" "a" token optional "b" token 2array seq parse
] unit-test

[
    "cb" "a" token optional "b" token 2array seq parse
] must-fail

{ V{ CHAR: a CHAR: b } } [
    "ab" "a" token ensure CHAR: a CHAR: z range dup 3array seq parse
] unit-test

[
    "bb" "a" token ensure CHAR: a CHAR: z range 2array seq parse
] must-fail

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

[
    "a++b"
    "a" token "+" token "++" token 2array choice "b" token 3array seq
    parse [ t ] [ f ] if
] must-fail

{ 1 } [
    "a" "a" token [ drop 1 ] action parse
] unit-test

{ V{ 1 1 } } [
    "aa" "a" token [ drop 1 ] action dup 2array seq parse
] unit-test

[
    "b" "a" token [ drop 1 ] action parse
] must-fail

[
    "b" [ CHAR: a = ] satisfy parse
] must-fail

{ CHAR: a } [
    "a" [ CHAR: a = ] satisfy parse
] unit-test

{ "a" } [
    "    a" "a" token sp parse
] unit-test

{ "a" } [
    "a" "a" token sp parse
] unit-test

{ V{ "a" } } [
    "[a]" "[" token hide "a" token "]" token hide 3array seq parse
] unit-test

[
    "a]" "[" token hide "a" token "]" token hide 3array seq parse
] must-fail


{ V{ "1" "-" "1" } V{ "1" "+" "1" } } [
    [
        [ "1" token , "-" token , "1" token , ] seq* ,
        [ "1" token , "+" token , "1" token , ] seq* ,
    ] choice*
    "1-1" over parse swap
    "1+1" swap parse
] unit-test

: expr ( -- parser )
    ! Test direct left recursion. Currently left recursion should cause a
    ! failure of that parser.
    [ expr ] delay "+" token "1" token 3seq "1" token 2choice ;

{ V{ V{ "1" "+" "1" } "+" "1" } } [
    "1+1+1" expr parse
] unit-test

{ t } [
    ! Ensure a circular parser doesn't loop infinitely
    [ f , "a" token , ] seq*
    dup peg>> parsers>>
    dupd 0 swap set-nth compile-parser word?
] unit-test

[
    "A" [ drop t ] satisfy [ 66 >= ] semantic parse
] must-fail

{ CHAR: B } [
    "B" [ drop t ] satisfy [ 66 >= ] semantic parse
] unit-test

{ f } [ \ + T{ parser f f f } equal? ] unit-test

{ } [ disable-optimizer ] unit-test

{ } [ "" epsilon parse drop ] unit-test

{ } [ enable-optimizer ] unit-test

{ [ ] } [ "" epsilon [ drop [ [ ] ] call ] action parse ] unit-test

{
    T{ parse-error
       { position 0 }
       { got "fbcd" }
       { messages V{ "'a'" "'b'" } }
    }
} [
    [ "fbcd" "a" token "b" token 2array choice parse ] [ ] recover
] unit-test

PEG: foo ( x -- x ) "abc" token ;

{ t } [
    2,000 [ [ "abc" foo ] future ] replicate
    [ ?future "abc" = ] all?
] unit-test
