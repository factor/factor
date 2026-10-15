USING: accessors kernel libc namespaces random random.haiku sequences tools.test
unix unix.ffi ;
IN: random.haiku.tests

{ { 0 1 255 256 257 4096 } } [
    { 0 1 255 256 257 4096 }
    [ haiku-random new random-bytes* length ] map
] unit-test

! Preserve native errors; oversized direct calls exceed the API limit.
[ f 257 get-entropy ]
[ errno>> EINVAL = ] must-fail-with

! Both startup providers must select the Haiku entropy interface.
{ t t } [
    secure-random-generator get haiku-random?
    system-random-generator get haiku-random?
] unit-test
