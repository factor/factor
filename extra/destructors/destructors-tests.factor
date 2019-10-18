USING: destructors kernel tools.test continuations ;
IN: temporary

TUPLE: dummy-obj destroyed? ;

: <dummy-obj> dummy-obj construct-empty ;

TUPLE: dummy-destructor obj ;

C: <dummy-destructor> dummy-destructor

M: dummy-destructor destruct ( obj -- )
    dummy-destructor-obj t swap set-dummy-obj-destroyed? ;

: destroy-always
    <dummy-destructor> add-always-destructor ;

: destroy-later
    <dummy-destructor> add-error-destructor ;

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

