USING: accessors classes.struct kernel kernel.private math math.order
tools.test ;
QUALIFIED: vm
IN: vm.tests

: get-ctx ( -- ctx )
    context vm:context memory>struct ;

{ t } [
    get-ctx [ callstack-bottom>> ] [ callstack-top>> ] bi - 0 >
] unit-test

{ t } [
    ! Callstack is in the callstack segment
    get-ctx [ callstack-top>> ] [
        callstack-seg>> [ start>> ] [ end>> ] bi
    ] bi between?
] unit-test
