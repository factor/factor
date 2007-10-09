USING: destructors kernel tools.test continuations ;
IN: temporary

TUPLE: dummy-obj destroyed? ;

: <dummy-obj>
    \ dummy-obj construct-empty ;

[ t ] [
    [
        <dummy-obj>
        dup [ t swap set-dummy-obj-destroyed? ] t add-destructor
    ] with-destructors dummy-obj-destroyed? 
] unit-test

[ f ] [
    [
        <dummy-obj>
        dup [ t swap set-dummy-obj-destroyed? ] f add-destructor
    ] with-destructors dummy-obj-destroyed? 
] unit-test

[ t ] [
    <dummy-obj> [
        [
            dup [ t swap set-dummy-obj-destroyed? ] t add-destructor
            "foo" throw
        ] with-destructors
    ] catch drop dummy-obj-destroyed? 
] unit-test

[ t ] [
    <dummy-obj> [
        [
            dup [ t swap set-dummy-obj-destroyed? ] f add-destructor
            "foo" throw
        ] with-destructors
    ] catch drop dummy-obj-destroyed? 
] unit-test

