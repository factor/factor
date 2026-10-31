USING: generic kernel system text-to-speech text-to-speech.unix
tools.test ;
IN: text-to-speech.unix.tests

! Check dispatch without launching Festival or producing audio.
{ t } [
    freebsd \ speak-text method-for-class M\ unix speak-text eq?
] unit-test

{ t } [
    linux \ speak-text method-for-class M\ unix speak-text eq?
] unit-test
