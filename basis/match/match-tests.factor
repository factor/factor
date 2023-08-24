! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel match namespaces tools.test ;
FROM: match => _ ;
IN: match.tests

MATCH-VARS: ?a ?b ;

{ f } [ { ?a ?a } { 1 2 } match ] unit-test

{ H{ { ?a 1 } { ?b 2 } } } [
    { ?a ?b } { 1 2 } match
] unit-test

{ { 1 2 } } [
    { 1 2 }
    {
        { { ?a ?b } [ ?a ?b 2array ] }
    } match-cond
] unit-test

{ t } [
    { 1 2 }
    {
        { { 1 2 } [ t ] }
        { f [ f ] }
    } match-cond
] unit-test

{ t } [
    { 1 3 }
    {
        { { 1 2 } [ t ] }
        { { 1 3 } [ t ] }
    } match-cond
] unit-test

{ f } [
    { 1 5 }
    {
        { { 1 2 } [ t ] }
        { { 1 3 } [ t ] }
        { _       [ f ] }
    } match-cond
] unit-test

TUPLE: foo a b ;

C: <foo> foo

{ 1 2 } [
    1 2 <foo> T{ foo f ?a ?b } match [
        ?a ?b
    ] with-variables
] unit-test

{ 1 2 } [
    1 2 <foo> \ ?a \ ?b <foo> match [
        ?a ?b
    ] with-variables
] unit-test

{ H{ { ?a ?a } } } [
    \ ?a \ ?a match
] unit-test

{ "match" } [
    "abcd" {
        { ?a [ "match" ] }
    } match-cond
] unit-test

{ "one" } [
    1 {
        { 1 [ "one" ] }
    } match-cond
] unit-test

[
    2 {
        { 1 [ "one" ] }
    } match-cond
] [ no-match-cond? ] must-fail-with

{ "default" } [
    2 {
        { 1 [ "one" ] }
        [ drop "default" ]
    } match-cond
] unit-test

{ { 2 1 } } [
    { "a" 1 2 "b" } { _ ?a ?b _ } { ?b ?a } match-replace
] unit-test

TUPLE: match-replace-test a b ;

{
    T{ match-replace-test f 2 1 }
} [
    T{ match-replace-test f 1 2 }
    T{ match-replace-test f ?a ?b }
    T{ match-replace-test f ?b ?a }
    match-replace
] unit-test
