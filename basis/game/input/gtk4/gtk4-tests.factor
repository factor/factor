! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators game.input game.input.gtk4
game.input.scancodes kernel namespaces sequences tools.test
ui.backend.gtk4.input-state ;
IN: game.input.gtk4.tests

{ t t f } [
    clear-input-state
    113 t record-key 114 t record-key
    -1 t record-key 999 t record-key 0 t record-key
    M\ gtk4-game-input-backend read-keyboard execute keys>>
    [ key-left-arrow swap nth ] [ key-right-arrow swap nth ] bi
    113 f record-key
    M\ gtk4-game-input-backend read-keyboard execute keys>> key-left-arrow swap nth
] unit-test

{ 7 4 1 -2 { t f f t f } } [
    clear-input-state
    { 10 20 } record-motion { 14 18 } record-motion { 17 24 } record-motion
    { 1 -1 } record-scroll { 0 -1 } record-scroll
    1 t record-button 8 t record-button 99 t record-button
    M\ gtk4-game-input-backend read-mouse execute
    { [ dx>> ] [ dy>> ] [ scroll-dx>> ] [ scroll-dy>> ] [ buttons>> ] } cleave
] unit-test

{ 2 3 0 0 { t f f f f } } [
    clear-input-state
    { 10 20 } record-motion { 30 40 } record-motion
    { 1 2 } record-scroll 1 t record-button
    M\ gtk4-game-input-backend reset-mouse execute
    { 32 43 } record-motion
    M\ gtk4-game-input-backend read-mouse execute
    { [ dx>> ] [ dy>> ] [ scroll-dx>> ] [ scroll-dy>> ] [ buttons>> ] } cleave
] unit-test

{ { t f f f f } f t } [
    clear-input-state
    1 t record-button 9 t record-key
    M\ gtk4-game-input-backend read-mouse execute
    1 f record-button buttons>>
    clear-input-state
    M\ gtk4-game-input-backend read-keyboard execute keys>> key-escape swap nth
    current-input-state get-global keycodes>> assoc-empty?
] unit-test
