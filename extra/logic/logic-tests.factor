! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test logic lists assocs math kernel namespaces
accessors sequences
logic.examples.factorial
logic.examples.fib
logic.examples.fib2
logic.examples.hanoi
logic.examples.hanoi2
logic.examples.money
logic.examples.zebra
logic.examples.zebra2 ;

IN: logic.tests

LOGIC-PREDS: cato mouseo creatureo ;
LOGIC-VARS: X Y ;
SYMBOLS: Tom Jerry Nibbles ;
{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact

{ t } [ { cato Tom } query ] unit-test
{ f } [ { { cato Tom } { cato Jerry } } query ] unit-test
{ { H{ { X Jerry } } H{ { X Nibbles } } } } [
    { mouseo X } query
] unit-test

{ creatureo X } { cato X } rule

{ { H{ { Y Tom } } } } [ { creatureo Y } query ] unit-test

LOGIC-PREDS: youngo young-mouseo ;
{ youngo Nibbles } fact
{ young-mouseo X } {
    { mouseo X }
    { youngo X }
} rule

{ { H{ { X Nibbles } } } } [ { young-mouseo X } query ] unit-test

{ creatureo X } { mouseo X } rule

{ { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } } } [
    { creatureo X } query
] unit-test

creatureo clear-pred
{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule
{ "cato" } [
    creatureo get defs>> first second first pred>> name>>
] unit-test
{ "mouseo" } [
    creatureo get defs>> second second first pred>> name>>
] unit-test

creatureo clear-pred
{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule*
{ "cato" } [
    creatureo get defs>> first second first pred>> name>>
] unit-test
{ "mouseo" } [
    creatureo get defs>> second second first pred>> name>>
] unit-test

{ { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } } } [
    { creatureo X } query
] unit-test

{ { H{ { Y Tom } } H{ { Y Jerry } } } } [
    { creatureo Y } 2 nquery
] unit-test

SYMBOL: Spike
LOGIC-PREDS: dogo ;
{ dogo Spike } fact
creatureo clear-pred
{ creatureo X } { dogo X } rule
{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule
{ "dogo" } [
    creatureo get defs>> first second first pred>> name>>
] unit-test
{ "cato" } [
    creatureo get defs>> second second first pred>> name>>
] unit-test
{ "mouseo" } [
    creatureo get defs>> third second first pred>> name>>
] unit-test

creatureo clear-pred
{ creatureo X } { dogo X } rule
{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule*
{ "cato" } [
    creatureo get defs>> first second first pred>> name>>
] unit-test
{ "mouseo" } [
    creatureo get defs>> second second first pred>> name>>
] unit-test
{ "dogo" } [
    creatureo get defs>> third second first pred>> name>>
] unit-test

creatureo clear-pred
{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule

LOGIC-PREDS: likes-cheeseo dislikes-cheeseo ;
{ likes-cheeseo X } { mouseo X } rule
{ dislikes-cheeseo Y } {
    { creatureo Y }
    \+ { likes-cheeseo Y }
} rule

{ f } [ { dislikes-cheeseo Jerry } query ] unit-test
{ t } [ { dislikes-cheeseo Tom } query ] unit-test

{ L{ Tom Jerry Nibbles } } [ L{ Tom Jerry Nibbles } ] unit-test
{ t } [ { membero Jerry L{ Tom Jerry Nibbles } } query ] unit-test

{ f } [
    { membero Spike [ Tom Jerry Nibbles L{ } cons cons cons ] } query
] unit-test

TUPLE: house living dining kitchen in-the-wall ;
LOGIC-PREDS: houseo ;
{ houseo T{ house
            { living Tom }
            { dining f }
            { kitchen Nibbles }
            { in-the-wall Jerry }
          }
} fact

{ { H{ { X Nibbles } } } } [
    { houseo T{ house
                { living __ }
                { dining __ }
                { kitchen X }
                { in-the-wall __ }
              }
    } query
] unit-test

LOGIC-PREDS: is-ao consumeso ;
SYMBOLS: mouse cat milk cheese fresh-milk Emmentaler ;
{
    { is-ao Tom cat }
    { is-ao Jerry mouse }
    { is-ao Nibbles mouse }
    { is-ao fresh-milk milk }
    { is-ao Emmentaler cheese }
} facts
{
    {
        { consumeso X milk } {
            { is-ao X mouse } ;;
            { is-ao X cat }
        }
    }
    { { consumeso X cheese } { is-ao X mouse } }
    { { consumeso Tom mouse } { !! f } }
    { { consumeso X mouse } { is-ao X cat } }
} rules

{
    {
        H{ { X milk } { Y fresh-milk } }
        H{ { X cheese } { Y Emmentaler } }
    }
} [
    { { consumeso Jerry X } { is-ao Y X } } query
] unit-test
{ { H{ { X milk } { Y fresh-milk } } } } [
    { { consumeso Tom X } { is-ao Y X } } query
] unit-test

SYMBOL: a-cat
{ is-ao a-cat cat } fact
{ {
        H{ { X milk } { Y fresh-milk } }
        H{ { X mouse } { Y Jerry } }
        H{ { X mouse } { Y Nibbles } }
    }
} [
    { { consumeso a-cat X } { is-ao Y X } } query
] unit-test

cato clear-pred
mouseo clear-pred
{ f } [ { creatureo X } query ] unit-test

{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact*
{ { H{ { Y Nibbles } } H{ { Y Jerry } } } } [
    { mouseo Y } query
] unit-test

{ mouseo Jerry } retract
{ { H{ { X Nibbles } } } } [
    { mouseo X } query
] unit-test

{ mouseo Jerry } fact
{ { H{ { X Nibbles } } H{ { X Jerry } } } } [
    { mouseo X } query
] unit-test
{ mouseo __ } retract-all
{ f } [ { mouseo X } query ] unit-test

{ { mouseo Jerry } { mouseo Nibbles } } facts
SYMBOLS: big small a-big-cat a-small-cat ;
{ cato big a-big-cat } fact
{ cato small a-small-cat } fact
{ { H{ { X Tom } } } } [ { cato X } query ] unit-test
{
    {
        H{ { X big } { Y a-big-cat } }
        H{ { X small } { Y a-small-cat } }
    }
} [ { cato X Y } query ] unit-test
{
    { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }
} [ { creatureo X } query ] unit-test

{ cato __ __ } retract-all
{ f } [ { cato X Y } query ] unit-test
{ { H{ { X Tom } } } } [ { cato X } query ] unit-test

LOGIC-PREDS: factorialo N_>_0  N2_is_N_-_1  F_is_F2_*_N ;
LOGIC-VARS: N N2 F F2 ;
{ factorialo 0 1 } fact
{ factorialo N F } {
    { N_>_0 N }
    { N2_is_N_-_1 N2 N }
    { factorialo N2 F2 }
    { F_is_F2_*_N F F2 N }
} rule
{ N_>_0 N } [ N of 0 > ] callback
{
    { { N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] }
    { { F_is_F2_*_N F F2 N } [ dup [ N of ] [ F2 of ] bi * F unify ] }
} callbacks

{ { H{ { F 1 } } } } [ { factorialo 0 F } query ] unit-test
{ { H{ { F 1 } } } } [ { factorialo 1 F } query ] unit-test
{ { H{ { F 3628800 } } } } [ { factorialo 10 F } query ] unit-test

factorialo clear-pred
{ factorialo 0 1 } fact
{ factorialo N F } {
    { (>) N 0 }
    [ [ N of 1 - ] N2 is ]
    { factorialo N2 F2 }
    [ [ [ F2 of ] [ N of ] bi * ] F is ]
} rule

{ { H{ { F 1 } } } } [ { factorialo 0 F } query ] unit-test
{ { H{ { F 1 } } } } [ { factorialo 1 F } query ] unit-test
{ { H{ { F 3628800 } } } } [ { factorialo 10 F } query ] unit-test
