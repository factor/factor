USING: assocs hex-strings io.streams.string kernel sequences
strings terminfo tools.test ;

IN: terminfo.tests

! This is based on the LSI ADM-3 terminfo file given as an example in the
! term(5) man page, with some fields removed to make it more compact.
! Linebreaks are added to denote boundaries between sections: header,
! names, booleans, ints, strings, and the string table.
: test-terminfo-sysv ( -- bytes )
   "1a 01 10 00 02 00 03 00  18 00 31 00
                                         61 64 6d 33
    61 7c 6c 73 69 20 61 64  6d 33 61 00
                                         00 01
                                               50 00
    ff ff 18 00
                ff ff 00 00  02 00 ff ff ff ff 04 00
    ff ff ff ff ff ff ff ff  0a 00 25 00 27 00 ff ff
    29 00 ff ff ff ff 2b 00  ff ff 2d 00 ff ff ff ff
    ff ff ff ff
                07 00 0d 00  1a 24 3c 31 3e 00 1b 3d
    25 70 31 25 7b 33 32 7d  25 2b 25 63 25 70 32 25
    7b 33 32 7d 25 2b 25 63  00 0a 00 1e 00 08 00 0c
    00 0b 00 0a 00"
    [ hex-digit? ] filter hex-string>bytes ;

! The same terminfo file, but in Curses 6.1 "extended
! numeric format".
: test-terminfo-32bit ( -- bytes )
   "1e 02 10 00 02 00 03 00  18 00 31 00
                                         61 64 6d 33
    61 7c 6c 73 69 20 61 64  6d 33 61 00
                                         00 01
                                               50 00
    00 00 ff ff ff ff 18 00  00 00
                ff ff 00 00  02 00 ff ff ff ff 04 00
    ff ff ff ff ff ff ff ff  0a 00 25 00 27 00 ff ff
    29 00 ff ff ff ff 2b 00  ff ff 2d 00 ff ff ff ff
    ff ff ff ff
                07 00 0d 00  1a 24 3c 31 3e 00 1b 3d
    25 70 31 25 7b 33 32 7d  25 2b 25 63 25 70 32 25
    7b 33 32 7d 25 2b 25 63  00 0a 00 1e 00 08 00 0c
    00 0b 00 0a 00"
    [ hex-digit? ] filter hex-string>bytes ;

CONSTANT: ADM3-TERMINFO {
    H{
        { ".names" { "adm3a" "lsi adm3a" } }
        { "auto_right_margin" t }
        { "columns" 80 }
        { "lines" 24 }
        { "cursor_down" "\n" }
        { "cursor_up" "\v" }
        { "cursor_left" "\b" }
        { "cursor_right" "\f" }
        { "cursor_home" "\x1e" }
        { "carriage_return" "\r" }
        { "bell" "\a" }
        { "clear_screen" "\x1a$<1>" }
        { "cursor_address" "\e=%p1%{32}%+%c%p2%{32}%+%c" }
    }
}

! TODO: these aren't hermetic -- they assume the host system has a terminfo
! database with a vt102 entry. Which is probably a pretty safe assumption,
! but it's untidy.
{ t } [
    "vt102" terminfo-names member?
] unit-test

{ t } [
    "vt102" terminfo-path string?
] unit-test

ADM3-TERMINFO [
    test-terminfo-sysv bytes>terminfo
] unit-test

ADM3-TERMINFO [
    test-terminfo-32bit bytes>terminfo
] unit-test

{ t } [
    test-terminfo-sysv test-terminfo-32bit [ bytes>terminfo ] bi@ =
] unit-test
