USING: tools.test math.rectangles prettyprint io.streams.string
kernel accessors ;
IN: math.rectangles.tests

{ rect: { 10 10 } { 20 20 } }
[
    rect: { 10 10 } { 50 50 }
    rect: { -10 -10 } { 40 40 }
    rect-intersect
] unit-test

{ rect: { 200 200 } { 0 0 } }
[
    rect: { 100 100 } { 50 50 }
    rect: { 200 200 } { 40 40 }
    rect-intersect
] unit-test

{ f } [
    rect: { 100 100 } { 50 50 }
    rect: { 200 200 } { 40 40 }
    contains-rect?
] unit-test

{ t } [
    rect: { 100 100 } { 50 50 }
    rect: { 120 120 } { 40 40 }
    contains-rect?
] unit-test

{ f } [
    rect: { 1000 100 } { 50 50 }
    rect: { 120 120 } { 40 40 }
    contains-rect?
] unit-test

{ rect: { 10 20 } { 20 20 } } [
    {
        { 20 20 }
        { 10 40 }
        { 30 30 }
    } rect-containing
] unit-test

! Prettyprint for rect: didn't do nesting check properly
{ } [ [ rect: f f dup >>dim . ] with-string-writer drop ] unit-test
