! (c) 2009 Joe Groff, see BSD license
USING: accessors assocs kernel tools.test quadtrees math.rectangles sorting ;
IN: quadtrees.tests

: unit-bounds ( -- rect ) { -1.0 -1.0 } { 2.0 2.0 } <rect> ;

: value>>key ( assoc value key -- assoc )
    pick set-at ; inline
: delete>>key ( assoc key -- assoc )
    over delete-at ; inline

{ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } {  0.0  -0.25 } "a" f f f f t } }
[
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
] unit-test

{ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } {  0.0  -0.25 } "b" f f f f t } }
[
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.0  -0.25 } value>>key
] unit-test

{ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
    T{ quadtree f T{ rect f { -1.0 -1.0 } { 1.0 1.0 } } { -0.5  -0.75 } "c" f f f f t }
    T{ quadtree f T{ rect f {  0.0 -1.0 } { 1.0 1.0 } } {  0.0  -0.25 } "a" f f f f t }
    T{ quadtree f T{ rect f { -1.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    T{ quadtree f T{ rect f {  0.0  0.0 } { 1.0 1.0 } } {  0.25  0.25 } "b" f f f f t }
    f
} } [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
] unit-test

{ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
    T{ quadtree f T{ rect f { -1.0 -1.0 } { 1.0 1.0 } } { -0.5  -0.75 } "c" f f f f t }
    T{ quadtree f T{ rect f {  0.0 -1.0 } { 1.0 1.0 } } {  0.0  -0.25 } "a" f f f f t }
    T{ quadtree f T{ rect f { -1.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    T{ quadtree f T{ rect f {  0.0  0.0 } { 1.0 1.0 } } f f
        T{ quadtree f T{ rect f {  0.0  0.0 } { 0.5 0.5 } } {  0.25  0.25 } "b" f f f f t }
        T{ quadtree f T{ rect f {  0.5  0.0 } { 0.5 0.5 } } {  0.75  0.25 } "d" f f f f t }
        T{ quadtree f T{ rect f {  0.0  0.5 } { 0.5 0.5 } } f               f   f f f f t }
        T{ quadtree f T{ rect f {  0.5  0.5 } { 0.5 0.5 } } f               f   f f f f t }
    }
    f
} } [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key
] unit-test

{ "b" t } [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

    {  0.25  0.25 } ?of
] unit-test

{ { 1.0 1.0 } f } [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

    {  1.0   1.0  } ?of
] unit-test

{ { "a" "c" } } [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

    { -0.6 -0.8 } { 0.8 1.0 } <rect> swap in-rect sort
] unit-test

{ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
    T{ quadtree f T{ rect f { -1.0 -1.0 } { 1.0 1.0 } } { -0.5  -0.75 } "c" f f f f t }
    T{ quadtree f T{ rect f {  0.0 -1.0 } { 1.0 1.0 } } {  0.0  -0.25 } "a" f f f f t }
    T{ quadtree f T{ rect f { -1.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    T{ quadtree f T{ rect f {  0.0  0.0 } { 1.0 1.0 } } {  0.75  0.25 } "d" f f f f t }
    f
} } [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

        {  0.25  0.25 } delete>>key
        prune-quadtree
] unit-test

{ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
    T{ quadtree f T{ rect f { -1.0 -1.0 } { 1.0 1.0 } } { -0.5  -0.75 } "c" f f f f t }
    T{ quadtree f T{ rect f {  0.0 -1.0 } { 1.0 1.0 } } {  0.0  -0.25 } "a" f f f f t }
    T{ quadtree f T{ rect f { -1.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    T{ quadtree f T{ rect f {  0.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    f
} } [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

        {  0.25  0.25 } delete>>key
        {  0.75  0.25 } delete>>key
        prune-quadtree
] unit-test

{ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
    T{ quadtree f T{ rect f { -1.0 -1.0 } { 1.0 1.0 } } f f
        T{ quadtree f T{ rect f { -1.0 -1.0 } { 0.5 0.5 } } { -0.75 -0.75 } "b" f f f f t }
        T{ quadtree f T{ rect f { -0.5 -1.0 } { 0.5 0.5 } } f               f   f f f f t }
        T{ quadtree f T{ rect f { -1.0 -0.5 } { 0.5 0.5 } } f               f   f f f f t }
        T{ quadtree f T{ rect f { -0.5 -0.5 } { 0.5 0.5 } } { -0.25 -0.25 } "a" f f f f t }
        f
    }
    T{ quadtree f T{ rect f {  0.0 -1.0 } { 1.0 1.0 } } f f
        T{ quadtree f T{ rect f {  0.0 -1.0 } { 0.5 0.5 } } f               f   f f f f t }
        T{ quadtree f T{ rect f {  0.5 -1.0 } { 0.5 0.5 } } {  0.75 -0.75 } "f" f f f f t }
        T{ quadtree f T{ rect f {  0.0 -0.5 } { 0.5 0.5 } } {  0.25 -0.25 } "e" f f f f t }
        T{ quadtree f T{ rect f {  0.5 -0.5 } { 0.5 0.5 } } f               f   f f f f t }
        f
    }
    T{ quadtree f T{ rect f { -1.0  0.0 } { 1.0 1.0 } } f f
        T{ quadtree f T{ rect f { -1.0  0.0 } { 0.5 0.5 } } f               f   f f f f t }
        T{ quadtree f T{ rect f { -0.5  0.0 } { 0.5 0.5 } } { -0.25  0.25 } "c" f f f f t }
        T{ quadtree f T{ rect f { -1.0  0.5 } { 0.5 0.5 } } { -0.75  0.75 } "d" f f f f t }
        T{ quadtree f T{ rect f { -0.5  0.5 } { 0.5 0.5 } } f               f   f f f f t }
        f
    }
    T{ quadtree f T{ rect f {  0.0  0.0 } { 1.0 1.0 } } f f
        T{ quadtree f T{ rect f {  0.0  0.0 } { 0.5 0.5 } } {  0.25  0.25 } "g" f f f f t }
        T{ quadtree f T{ rect f {  0.5  0.0 } { 0.5 0.5 } } f               f   f f f f t }
        T{ quadtree f T{ rect f {  0.0  0.5 } { 0.5 0.5 } } f               f   f f f f t }
        T{ quadtree f T{ rect f {  0.5  0.5 } { 0.5 0.5 } } {  0.75  0.75 } "h" f f f f t }
        f
    }
    f
} } [
    unit-bounds <quadtree>
        "a" { -0.25 -0.25 } value>>key
        "b" { -0.75 -0.75 } value>>key
        "c" { -0.25  0.25 } value>>key
        "d" { -0.75  0.75 } value>>key
        "e" {  0.25 -0.25 } value>>key
        "f" {  0.75 -0.75 } value>>key
        "g" {  0.25  0.25 } value>>key
        "h" {  0.75  0.75 } value>>key

        prune-quadtree
] unit-test

{ 8 } [
    unit-bounds <quadtree>
        "a" { -0.25 -0.25 } value>>key
        "b" { -0.75 -0.75 } value>>key
        "c" { -0.25  0.25 } value>>key
        "d" { -0.75  0.75 } value>>key
        "e" {  0.25 -0.25 } value>>key
        "f" {  0.75 -0.75 } value>>key
        "g" {  0.25  0.25 } value>>key
        "h" {  0.75  0.75 } value>>key

        assoc-size
] unit-test

{ {
    { { -0.75 -0.75 } "b" }
    { { -0.75  0.75 } "d" }
    { { -0.25 -0.25 } "a" }
    { { -0.25  0.25 } "c" }
    { {  0.25 -0.25 } "e" }
    { {  0.25  0.25 } "g" }
    { {  0.75 -0.75 } "f" }
    { {  0.75  0.75 } "h" }
} } [
    unit-bounds <quadtree>
        "a" { -0.25 -0.25 } value>>key
        "b" { -0.75 -0.75 } value>>key
        "c" { -0.25  0.25 } value>>key
        "d" { -0.75  0.75 } value>>key
        "e" {  0.25 -0.25 } value>>key
        "f" {  0.75 -0.75 } value>>key
        "g" {  0.25  0.25 } value>>key
        "h" {  0.75  0.75 } value>>key

        >alist sort
] unit-test

TUPLE: pointy-thing center ;

{ {
    T{ pointy-thing f { 0 0 } }
    T{ pointy-thing f { 1 0 } }
    T{ pointy-thing f { 0 1 } }
    T{ pointy-thing f { 1 1 } }
    T{ pointy-thing f { 2 0 } }
    T{ pointy-thing f { 3 0 } }
    T{ pointy-thing f { 2 1 } }
    T{ pointy-thing f { 3 1 } }
    T{ pointy-thing f { 0 2 } }
    T{ pointy-thing f { 1 2 } }
    T{ pointy-thing f { 0 3 } }
    T{ pointy-thing f { 1 3 } }
    T{ pointy-thing f { 2 2 } }
    T{ pointy-thing f { 3 2 } }
    T{ pointy-thing f { 2 3 } }
    T{ pointy-thing f { 3 3 } }
} } [
    {
        T{ pointy-thing f { 3 1 } }
        T{ pointy-thing f { 2 3 } }
        T{ pointy-thing f { 3 2 } }
        T{ pointy-thing f { 0 1 } }
        T{ pointy-thing f { 2 2 } }
        T{ pointy-thing f { 1 1 } }
        T{ pointy-thing f { 3 0 } }
        T{ pointy-thing f { 3 3 } }
        T{ pointy-thing f { 1 3 } }
        T{ pointy-thing f { 2 1 } }
        T{ pointy-thing f { 0 0 } }
        T{ pointy-thing f { 2 0 } }
        T{ pointy-thing f { 1 0 } }
        T{ pointy-thing f { 0 2 } }
        T{ pointy-thing f { 1 2 } }
        T{ pointy-thing f { 0 3 } }
    } [ center>> ] swizzle
] unit-test
