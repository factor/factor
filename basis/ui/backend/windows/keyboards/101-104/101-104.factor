! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces ui.backend.windows ;
IN: ui.backend.windows

SYMBOL: +oem&numpad-keydown-codes+

H{
    { 186 { ";" ":" } }  ! OEM_1
    { 187 { "=" "+" } }  ! OEM_PLUS
    { 188 { "," "<" } }  ! OEM_COMMA        
    { 189 { "-" "_" } }  ! OEM_MINUS
    { 190 { "." ">" } }  ! OEM_PERIOD
    { 191 { "/" "?" } }  ! OEM_2
    { 192 { "`" "~" } }  ! OEM_3
    { 219 { "[" "{" } }  ! OEM_4
    { 220 { "\\" "|" } } ! OEM_5
    { 221 { "]" "}" } }  ! OEM_6
    { 222 { "'" "\"" } } ! OEM_7
    { 96  { "0" "0" } }  ! NUMPAD0
    { 97  { "1" "1" } }  ! NUMPAD1
    { 98  { "2" "2" } }  ! NUMPAD2
    { 99  { "3" "3" } }  ! NUMPAD3
    { 100 { "4" "4" } }  ! NUMPAD4
    { 101 { "5" "5" } }  ! NUMPAD5
    { 102 { "6" "6" } }  ! NUMPAD6
    { 103 { "7" "7" } }  ! NUMPAD7
    { 104 { "8" "8" } }  ! NUMPAD8
    { 105 { "9" "9" } }  ! NUMPAD9
    { 106 { "*" "*" } }  ! MULTIPLY
    { 107 { "+" "+" } }  ! ADD
    { 109 { "-" "-" } }  ! SUBTRUCT
    { 110 { "." "." } }  ! DECIMAL
    { 111 { "/" "/" } }  ! DIVIDE
}
+oem&numpad-keydown-codes+ set-global 
