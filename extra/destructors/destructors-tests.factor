USING: destructors kernel tools.test continuations ;
IN: temporary

TUPLE: dummy-obj destroyed? ;

TUPLE: dummy-destructor ;

: <dummy-destructor> ( obj ? -- newobj )
    <destructor> dummy-destructor construct-delegate ;

M: dummy-destructor (destruct) ( obj -- )
    destructor-obj t swap set-dummy-obj-destroyed? ;

: <dummy-obj>
    \ dummy-obj construct-empty ;

: destroy-always
    t <dummy-destructor> push-destructor ;

: destroy-later
    f <dummy-destructor> push-destructor ;

[ t ] [
    [
        <dummy-obj> dup destroy-always
    ] with-destructors dummy-obj-destroyed? 
] unit-test

[ f ] [
    [
        <dummy-obj> dup destroy-later
    ] with-destructors dummy-obj-destroyed? 
] unit-test

[ t ] [
    <dummy-obj> [
        [
            dup destroy-always
            "foo" throw
        ] with-destructors
    ] catch drop dummy-obj-destroyed? 
] unit-test

[ t ] [
    <dummy-obj> [
        [
            dup destroy-later
            "foo" throw
        ] with-destructors
    ] catch drop dummy-obj-destroyed? 
] unit-test

