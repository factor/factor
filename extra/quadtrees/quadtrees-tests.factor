USING: assocs kernel tools.test quadtrees math.geometry.rect sorting ;
IN: quadtrees.tests

: unit-bounds ( -- rect ) { -1.0 -1.0 } { 2.0 2.0 } <rect> ;

: value>>key ( assoc value key -- assoc )
    pick set-at ; inline
: delete>>key ( assoc key -- assoc )
    over delete-at ; inline

[ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } {  0.0  -0.25 } "a" f f f f t } ]
[
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
] unit-test

[ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } {  0.0  -0.25 } "b" f f f f t } ]
[
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.0  -0.25 } value>>key
] unit-test

[ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
    T{ quadtree f T{ rect f { -1.0 -1.0 } { 1.0 1.0 } } { -0.5  -0.75 } "c" f f f f t }
    T{ quadtree f T{ rect f {  0.0 -1.0 } { 1.0 1.0 } } {  0.0  -0.25 } "a" f f f f t }
    T{ quadtree f T{ rect f { -1.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    T{ quadtree f T{ rect f {  0.0  0.0 } { 1.0 1.0 } } {  0.25  0.25 } "b" f f f f t }
    f 
} ] [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
] unit-test

[ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
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
} ] [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key
] unit-test

[ "b" t ] [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

    {  0.25  0.25 } swap at*
] unit-test

[ f f ] [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

    {  1.0   1.0  } swap at*
] unit-test

[ { "a" "c" } ] [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

    { -0.6 -0.8 } { 0.8 1.0 } <rect> swap in-rect natural-sort
] unit-test

[ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
    T{ quadtree f T{ rect f { -1.0 -1.0 } { 1.0 1.0 } } { -0.5  -0.75 } "c" f f f f t }
    T{ quadtree f T{ rect f {  0.0 -1.0 } { 1.0 1.0 } } {  0.0  -0.25 } "a" f f f f t }
    T{ quadtree f T{ rect f { -1.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    T{ quadtree f T{ rect f {  0.0  0.0 } { 1.0 1.0 } } {  0.75  0.25 } "d" f f f f t }
    f
} ] [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

        {  0.25  0.25 } delete>>key
        prune
] unit-test

[ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
    T{ quadtree f T{ rect f { -1.0 -1.0 } { 1.0 1.0 } } { -0.5  -0.75 } "c" f f f f t }
    T{ quadtree f T{ rect f {  0.0 -1.0 } { 1.0 1.0 } } {  0.0  -0.25 } "a" f f f f t }
    T{ quadtree f T{ rect f { -1.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    T{ quadtree f T{ rect f {  0.0  0.0 } { 1.0 1.0 } } f               f   f f f f t }
    f
} ] [
    unit-bounds <quadtree>
        "a" {  0.0  -0.25 } value>>key
        "b" {  0.25  0.25 } value>>key
        "c" { -0.5  -0.75 } value>>key
        "d" {  0.75  0.25 } value>>key

        {  0.25  0.25 } delete>>key
        {  0.75  0.25 } delete>>key
        prune
] unit-test

[ T{ quadtree f T{ rect f { -1.0 -1.0 } { 2.0 2.0 } } f f
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
} ] [
    unit-bounds <quadtree>
        "a" { -0.25 -0.25 } value>>key
        "b" { -0.75 -0.75 } value>>key
        "c" { -0.25  0.25 } value>>key
        "d" { -0.75  0.75 } value>>key
        "e" {  0.25 -0.25 } value>>key
        "f" {  0.75 -0.75 } value>>key
        "g" {  0.25  0.25 } value>>key
        "h" {  0.75  0.75 } value>>key

        prune
] unit-test

[ 8 ] [
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

[ 8 ] [
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


