USING: colors hashtables io.streams.ansi io.streams.string io.styles tools.test ;
IN: io.streams.ansi.tests

: ansi-unit-test ( expected quot use-dim -- )
    '[ [ _ _ (with-ansi) ] with-string-writer ] unit-test ; inline

{ "\e[1mbold\e[0m" } [
    "bold" bold font-style associate format
] t ansi-unit-test

{ "\e[32mgreen\e[0m" } [
    "green" 0 1 0 1 <rgba> foreground associate format
] t ansi-unit-test

{ "\e[96mcyan\e[0m" } [
    "cyan" 0 1 1 1 <rgba> foreground associate format
] t ansi-unit-test

{ "\e[31;2mdimred\e[0m" } [
    "dimred" 0.5 0 0 1 <rgba> foreground associate format
] t ansi-unit-test

{ "\e[31mdimred\e[0m" } [
    "dimred" 0.5 0 0 1 <rgba> foreground associate format
] f ansi-unit-test
