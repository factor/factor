USING: accessors arrays bank calendar kernel math math.functions
namespaces make tools.test tools.walker ;
FROM: bank => balance>> ;
IN: bank.tests

SYMBOL: my-account
"Alex's Take Over the World Fund" 0.07 1 2007 11 1 <date> 6101.94 open-account
my-account [
    [ 6137 ] [ my-account get 2007 12 2 <date> process-to-date balance>> round >integer ] unit-test
    [ 6137 ] [ my-account get 2007 12 2 <date> process-to-date balance>> round >integer ] unit-test
] with-variable

"Petty Cash" 0.07 1 2006 12 1 <date> 10962.18 open-account
my-account [
    [ 11027 ] [ my-account get 2007 1 2 <date> process-to-date balance>> round >integer ] unit-test
] with-variable

"Saving to buy a pony" 0.0725 1 2008 3 3 <date> 11106.24 open-account
my-account [
    [ 8416 ] [
        my-account get [
           2008 3 11 <date> -750 "Need to buy food" <transaction> ,
           2008 3 25 <date> -500 "Going to a party" <transaction> ,
           2008 4  8 <date> -800 "Losing interest in the pony..." <transaction> ,
           2008 4  8 <date> -700 "Buying a rocking horse" <transaction> ,
        ] { } make inserting-transactions balance>> round >integer
    ] unit-test
] with-variable

{ 6781 } [
    "..." 0.07 1 2007 4 10 <date> 4398.50 open-account
    2007 10 26 <date> 2000 "..." <transaction> 1array inserting-transactions
    2008 4 10 <date> process-to-date dup balance>> swap unpaid-interest>> + round >integer
] unit-test
