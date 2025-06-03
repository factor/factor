USING: assocs bitcask combinators kernel tools.test ;

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
