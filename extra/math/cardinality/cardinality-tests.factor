USING: kernel layouts literals math math.cardinality
math.functions random sequences tools.test ;

${ fixnum-bits } [ 0 trailing-zeros ] unit-test
{ 0 } [ 0b1 trailing-zeros ] unit-test
{ 1 } [ 0b10 trailing-zeros ] unit-test
{ 2 } [ 0b100 trailing-zeros ] unit-test
{ 3 } [ 0b1000 trailing-zeros ] unit-test

{ t } [
    10 [
        10,000 [ random-units 10 estimate-cardinality ] [ / ] bi
    ] replicate [ 1.0 0.15 ~ ] all? ! should be 4%?
] unit-test
