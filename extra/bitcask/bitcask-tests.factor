USING: assocs bitcask combinators kernel math random sequences
sorting tools.test ;

{
    f f
    "value" t
    { { "key" "value" } }
    f t
    f f
    { { "key" "value2" } }
    { }
} [
    [
        "key" "data.log" <bitcask> {
            [ at* ]
            [ "value" -rot set-at ]
            [ at* ]
            [ nip >alist ]
            [ f -rot set-at ]
            [ at* ]
            [ delete-at ]
            [ at* ]
            [ "value2" -rot set-at ]
            [ nip >alist ]
            [ nip clear-assoc ]
            [ nip >alist ]
        } 2cleave
    ] with-test-directory
] unit-test


{ 10 5 { 1 3 5 7 9 } 0 { } } [
    [
        "data.log" <bitcask>
        10,000 10 randoms [ dup pick set-at ] each
        [ assoc-size ] keep
        10 <iota> [ even? ] filter [ over delete-at ] each

        save-index

        "data.log" <bitcask>
        [ assoc-size ] keep
        [ keys sort ] keep
        [ clear-assoc ] keep

        save-index

        "data.log" <bitcask>
        [ assoc-size ] keep
        >alist
    ] with-test-directory
] unit-test
