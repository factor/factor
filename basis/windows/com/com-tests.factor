USING: kernel windows.com windows.com.syntax windows.ole32
windows.types alien alien.data alien.syntax tools.test libc
alien.c-types namespaces arrays continuations accessors math
windows.com.wrapper windows.com.wrapper.private destructors
effects compiler.units ;
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

COM-INTERFACE: ISelfReferential IUnknown {d4f45bf8-f720-4701-a09d-e8e341981121}
    ISelfReferential* selfReference ( ) ;

{ GUID: {216fb341-0eb2-44b1-8edb-60b76e353abc} } [ ISimple-iid ] unit-test
{ GUID: {9620ecec-8438-423b-bb14-86f835aa40dd} } [ IInherited-iid ] unit-test
{ GUID: {00000000-0000-0000-C000-000000000046} } [ IUnknown-iid ] unit-test
{ GUID: {b06ac3f4-30e4-406b-a7cd-c29cead4552c} } [ IUnrelated-iid ] unit-test

{ ( -- iid ) } [ \ ISimple-iid stack-effect ] unit-test
{ ( this -- HRESULT ) } [ \ ISimple::returnOK stack-effect ] unit-test
{ ( this -- int ) } [ \ IInherited::getX stack-effect ] unit-test
{ ( this newX -- ) } [ \ IInherited::setX stack-effect ] unit-test
{ ( this mul add -- int ) } [ \ IUnrelated::xMulAdd stack-effect ] unit-test

SYMBOL: +test-wrapper+
SYMBOL: +guinea-pig-implementation+
SYMBOL: +orig-wrapped-objects+

+wrapped-objects+ get-global clone +orig-wrapped-objects+ set-global

TUPLE: test-implementation x ;
C: <test-implementation> test-implementation

[
    [
        {
            { IInherited {
                [ drop S_OK ] ! ISimple::returnOK
                [ drop E_FAIL ] ! ISimple::returnError
                [ x>> ] ! IInherited::getX
                [ >>x drop ] ! IInherited::setX
            } }
            { IUnrelated {
                [ [ x>> ] [ + ] bi* ] ! IUnrelated::xPlus
                [ [ x>> ] [ * ] [ + ] tri* ] ! IUnrelated::xMulAdd
            } }
        } <com-wrapper>
        dup +test-wrapper+ set [

            0 <test-implementation> swap com-wrap
            dup +guinea-pig-implementation+ set [
                drop

                S_OK 1array [ +guinea-pig-implementation+ get ISimple::returnOK ] unit-test
                E_FAIL long <ref> long deref 1array [ +guinea-pig-implementation+ get ISimple::returnError ] unit-test
                20 1array [
                    +guinea-pig-implementation+ get
                    [ 20 IInherited::setX ]
                    [ IInherited::getX ] bi
                ] unit-test
                420 1array [
                    +guinea-pig-implementation+ get
                    IUnrelated-iid com-query-interface
                    [ 20 20 IUnrelated::xMulAdd ] with-com-interface
                ] unit-test
                40 1array [
                    +guinea-pig-implementation+ get
                    IUnrelated-iid com-query-interface
                    [ 20 IUnrelated::xPlus ] with-com-interface
                ] unit-test

                +guinea-pig-implementation+ get 1array [
                    +guinea-pig-implementation+ get com-add-ref
                ] unit-test

                { } [ +guinea-pig-implementation+ get com-release ] unit-test

                +guinea-pig-implementation+ get 1array [
                    +guinea-pig-implementation+ get IUnknown-iid com-query-interface
                    dup com-release
                ] unit-test
                +guinea-pig-implementation+ get 1array [
                    +guinea-pig-implementation+ get ISimple-iid com-query-interface
                    dup com-release
                ] unit-test
                void* heap-size +guinea-pig-implementation+ get <displaced-alien>
                +guinea-pig-implementation+ get
                2array [
                    +guinea-pig-implementation+ get IUnrelated-iid com-query-interface
                    dup ISimple-iid com-query-interface
                    over com-release dup com-release
                ] unit-test
            ] with-com-interface
        ] with-disposal
    ] with-compilation-unit
] with-destructors

! Ensure that we freed +guinea-pig-implementation
+orig-wrapped-objects+ get-global 1array [ +wrapped-objects+ get-global ] unit-test
