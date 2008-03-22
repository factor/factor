USING: kernel windows.com windows.com.syntax windows.ole32
alien alien.syntax tools.test libc alien.c-types arrays.lib 
namespaces arrays continuations accessors ;
IN: windows.com.tests

COM-INTERFACE: ISimple IUnknown {216fb341-0eb2-44b1-8edb-60b76e353abc}
    HRESULT returnOK ( )
    HRESULT returnError ( ) ;

COM-INTERFACE: IInherited ISimple {9620ecec-8438-423b-bb14-86f835aa40dd}
    int getX ( )
    void setX ( int newX ) ;

COM-INTERFACE: IUnrelated IUnknown {b06ac3f4-30e4-406b-a7cd-c29cead4552c}
    int xPlus ( int y )
    int xMulAdd ( int mul, int add ) ;

"{216fb341-0eb2-44b1-8edb-60b76e353abc}" string>guid 1array [ ISimple-iid ] unit-test
"{9620ecec-8438-423b-bb14-86f835aa40dd}" string>guid 1array [ IInherited-iid ] unit-test
"{00000000-0000-0000-C000-000000000046}" string>guid 1array [ IUnknown-iid ] unit-test

SYMBOL: +test-vtbl+
SYMBOL: +guinea-pig-implementation+

TUPLE: test-implementation x ;
C: test-implementation <test-implementation>

{
    { "IInherited" {
        [ drop S_OK ] ! ISimple::returnOK
        [ drop E_FAIL ] ! ISimple::returnError
        [ x>> ] ! IInherited::getX
        [ >>x drop ] ! IInherited::setX
    } }
    { "IUnrelated" {
        [ swap x>> + ] ! IUnrelated::xPlus
        [ spin x>> * + ] ! IUnrealted::xMulAdd
    } }
} <com-vtbl>
dup +test-vtbl+ set [

    0 <test-implementation> +test-vtbl+ get com-wrap
    dup +guinea-pig-implementation+ set [

        S_OK 1array [ +guinea-pig-implementation+ get ISimple::returnOK ] unit-test
        E_FAIL <long> *long 1array [ +guinea-pig-implementation+ get ISimple::returnError ] unit-test
        20 1array [ +guinea-pig-implementation+ get dup 20 IInherited::setX IInherited::getX ] unit-test
        420 1array [ +guinea-pig-implementation+ get 20 20 IUnrelated::xMulAdd ] unit-test
        40 1array [ +guinea-pig-implementation+ get 20 IUnrelated::xPlus ] unit-test

        +guinea-pig-implementation+ get 1array [
            +guinea-pig-implementation+ get com-add-ref
        ] unit-test

        { } [ +guinea-pig-implementation+ get com-release ] unit-test

        +guinea-pig-implementation+ get 1array [
            +guinea-pig-implementation+ get IUnknown-iid com-query-interface
        ] unit-test
        +guinea-pig-implementation+ get 1array [
            +guinea-pig-implementation+ get ISimple-iid com-query-interface
        ] unit-test
        "void*" heap-size +guinea-pig-implementation+ get <displaced-alien> 1array [
            +guinea-pig-implementation+ get IUnrelated-iid com-query-interface
        ] unit-test

    ] with-com-interface

] [ free-com-vtbl ] [ ] cleanup
