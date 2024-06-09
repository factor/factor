USING: assocs environment hex-strings io.backend
io.streams.string kernel namespaces sequences strings system
terminfo tools.test ;

IN: terminfo.tests

CONSTANT: ADM3-TERMINFO {
    H{
        { ".names" { "adm3a" "LSI adm3a" } }
        { "arrow_key_map" "\v\x10" }
        { "auto_right_margin" t }
        { "backspaces_with_bs" t }
        { "bell" "\a" }
        { "carriage_return" "\r" }
        { "clear_screen" "\x1a$<1/>" }
        { "columns" 80 }
        { "cursor_address" "\e=%p1%' '%+%c%p2%' '%+%c" }
        { "cursor_down" "\n" }
        { "cursor_home" "\x1e" }
        { "cursor_left" "\b" }
        { "cursor_right" "\f" }
        { "cursor_up" "\v" }
        { "key_down" "\n" }
        { "key_left" "\b" }
        { "key_right" "\f" }
        { "key_up" "\v" }
        { "linefeed_if_not_lf" "\n" }
        { "lines" 24 }
        { "reset_2string" "\x0e" }
        { "scroll_forward" "\n" }
    }
}

: terminfo-unit-test ( expected quot -- )
    '[
        "vocab:terminfo/test" normalize-path "TERMINFO"
        [ linux \ os _ with-variable ] with-os-env
    ] unit-test ; inline

{ t f } [
    "vt102-fictional" terminfo-names member?
    "vt102-missing" terminfo-names member?
] terminfo-unit-test

{ t f } [
    "vt102-fictional" terminfo-path string?
    "vt102-missing" terminfo-path
] terminfo-unit-test

ADM3-TERMINFO [
    "adm3a" name>terminfo
] terminfo-unit-test

ADM3-TERMINFO [
    "adm3a-32bit" name>terminfo
] terminfo-unit-test

{ t } [
    "adm3a" "adm3a-32bit" [ name>terminfo ] bi@ =
] terminfo-unit-test

{
    H{
        { ".names" { "ecma+strikeout" "ECMA-48 strikeout/crossed-out" } }
        { "rmxx" "\x1B[29m" }
        { "smxx" "\x1B[9m" } }
} [
  "ecma+strikeout" name>terminfo
] terminfo-unit-test

{
    { t 16777216 }
} [
    "kitty-direct" name>terminfo '[ _ at ] { "RGB" "max_colors" } swap map
] terminfo-unit-test
