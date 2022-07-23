USING: accessors combinators combinators.short-circuit
cuckoo-filters kernel math.parser sequences tools.test ;

{ t 1 t t f 0 } [
    "factor" 100 <cuckoo-filter> {
        [ cuckoo-insert ]
        [ nip size>> ]
        [ cuckoo-lookup ]
        [ cuckoo-delete ]
        [ cuckoo-lookup ]
        [ nip size>> ]
    } 2cleave
] unit-test

{ 250,000 250,000 0 } [
    250,000 <cuckoo-filter>
    250,000 [ number>string ] map-integers
    [
        [
            {
                [ over cuckoo-lookup not ]
                [ over cuckoo-insert ]
            } 1&&
        ] count swap
    ]
    [ [ over cuckoo-lookup ] count swap ]
    [ [ over cuckoo-delete drop ] each ] tri
    size>>
] unit-test
