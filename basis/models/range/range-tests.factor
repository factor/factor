IN: models.range.tests
USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.range ;

! Test <range> 
: setup-range ( -- range ) 0 0 0 255 <range> ;

! clamp-value should not go past range ends
[ 0   ] [ -10 setup-range clamp-value ] unit-test
[ 255 ] [ 2000 setup-range clamp-value ] unit-test
[ 14  ] [ 14 setup-range clamp-value ] unit-test

! range min/max/page values should be correct
[ 0 ] [ setup-range range-page-value ] unit-test
[ 0 ] [ setup-range range-min-value ] unit-test
[ 255 ] [ setup-range range-max-value ] unit-test

! should be able to set the value within the range and get back
[ 15 ] [ setup-range 15 over set-range-value range-value ] unit-test
[ 0 ] [ setup-range -15 over set-range-value range-value ] unit-test
[ 255 ] [ setup-range 4000 over set-range-value range-value ] unit-test

! should be able to change the range min/max/page value
[ 1 ] [ setup-range 1 over set-range-page-value range-page-value ] unit-test
[ 50 ] [ setup-range 50 over set-range-min-value range-min-value ] unit-test
[ 4000 ] [ setup-range 4000 over set-range-max-value range-max-value ] unit-test

! should be able to move by positive and negative values
[ 30 ] [ setup-range 30 over move-by range-value ] unit-test
[ 0 ] [ setup-range 30 over move-by -30 over move-by range-value ] unit-test

! should be able to move by a page of 10
[ 10 ] [ 
    setup-range 10 over set-range-page-value 
    1 over move-by-page range-value 
] unit-test
