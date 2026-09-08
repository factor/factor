USING: accessors bubble-chamber kernel tools.test ;

{ { 600 400 } } [
    <bubble-chamber> { 1200 800 } >>dim
    <quark> swap >>bubble-chamber center
] unit-test

! Bounds must follow the allocated dimensions, including after shrinking.
{ f t } [
    <bubble-chamber> { 1200 800 } >>dim
    <quark> swap >>bubble-chamber { 2100 500 } >>pos
    dup out-of-bounds? swap
    dup bubble-chamber>> { 600 400 } >>dim drop out-of-bounds?
] unit-test
