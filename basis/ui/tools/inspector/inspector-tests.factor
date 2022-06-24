USING: assocs formatting kernel math math.parser models
sequences strings tools.test ui.tools.inspector unicode ;

{ } [ \ + <model> <inspector-gadget> com-edit-slot ] unit-test

! Make sure we can click around in the inspector
{ } [
    "abcdefg" [
        swap [ dup number>string ] dip dup
        dup unicode:printable? [ 1string ] [
            dup 0xff <= [
                H{
                    { CHAR: \a "\\a" }
                    { CHAR: \b "\\b" }
                    { CHAR: \e "\\e" }
                    { CHAR: \f "\\f" }
                    { CHAR: \n "\\n" }
                    { CHAR: \r "\\r" }
                    { CHAR: \t "\\t" }
                    { CHAR: \v "\\v" }
                    { CHAR: \0 "\\0" }
                } ?at [ "\\x%02x" sprintf ] unless
            ] [
                "\\u{%x}" sprintf
            ] if
        ] if slot-description boa
    ] { } map-index-as drop
] unit-test