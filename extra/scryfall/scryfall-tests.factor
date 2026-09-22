! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: scryfall tools.test ;
IN: scryfall.tests

{ { { { "Creature" } { "Elf" "Druid" } } } } [
    "Creature — Elf Druid" parse-type-line
] unit-test

{ { { { "Artifact" "Creature" } { "Golem" } } } } [
    "Artifact Creature — Golem" parse-type-line
] unit-test

{ { { { "Land" } { } } } } [ "Land" parse-type-line ] unit-test

{ { { { "Creature" } { "Human" } } { { "Land" } { "Forest" } } } } [
    "Creature — Human // Land — Forest" parse-type-line
] unit-test

{ { { { "" } { } } } } [ "" parse-type-line ] unit-test

{ { { { "Creature" } { "Human" } } { { "Land" } { } } } } [
    "Creature — Human // Land" parse-type-line
] unit-test
