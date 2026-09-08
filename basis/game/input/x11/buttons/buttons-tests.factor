USING: game.input game.input.x11.buttons tools.test ;

{ { f f f f f } } [ 0 button-mask>buttons ] unit-test
{ { f f f f f } } [ 0xff button-mask>buttons ] unit-test
{ { t f f f f } } [ 0x100 button-mask>buttons ] unit-test
{ { f t f f f } } [ 0x200 button-mask>buttons ] unit-test
{ { f f t f f } } [ 0x400 button-mask>buttons ] unit-test
{ { f f f t f } } [ 0x800 button-mask>buttons ] unit-test
{ { f f f f t } } [ 0x1000 button-mask>buttons ] unit-test
{ { t t t t t } } [ 0x1fff button-mask>buttons ] unit-test
{ { f f f f f } } [ 0x2000 button-mask>buttons ] unit-test

{ { pressed released f f f } } [
    0x200 button-mask>buttons 0x100 button-mask>buttons buttons-delta
] unit-test
