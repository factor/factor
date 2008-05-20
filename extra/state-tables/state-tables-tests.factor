USING: kernel tables tools.test ;
IN: tables.tests

: test-table
    <table>
    "a" "c" "z" <entry> over set-entry
    "a" "o" "y" <entry> over set-entry
    "a" "l" "x" <entry> over set-entry
    "b" "o" "y" <entry> over set-entry
    "b" "l" "x" <entry> over set-entry
    "b" "s" "u" <entry> over set-entry ;

[
    T{ table f
    H{ 
        { "a" H{ { "l" "x" } { "c" "z" } { "o" "y" } } }
        { "b" H{ { "l" "x" } { "s" "u" } { "o" "y" } } }
    }
    H{ { "l" t } { "s" t } { "c" t } { "o" t } } }
] [ test-table ] unit-test

[ "x" t ] [ "a" "l" test-table get-entry ] unit-test
[ "har" t ] [
    "a" "z" "har" <entry> test-table [ set-entry ] keep
    >r "a" "z" r> get-entry
] unit-test

: vector-test-table
    <vector-table>
    "a" "c" "z" <entry> over add-value
    "a" "c" "r" <entry> over add-value
    "a" "o" "y" <entry> over add-value
    "a" "l" "x" <entry> over add-value
    "b" "o" "y" <entry> over add-value
    "b" "l" "x" <entry> over add-value
    "b" "s" "u" <entry> over add-value ;

[
T{ vector-table f
    H{ 
        { "a"
            H{ { "l" "x" } { "c" V{ "z" "r" } } { "o" "y" } } }
        { "b"
            H{ { "l" "x" } { "s" "u" } { "o" "y" } } }
    }
    H{ { "l" t } { "s" t } { "c" t } { "o" t } }
}
] [ vector-test-table ] unit-test

