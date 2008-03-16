USING: kernel windows.com windows.com.syntax windows.ole32
alien alien.syntax tools.test libc ;
IN: windows.com.tests

! Create some test COM interfaces

COM-INTERFACE: ISimple IUnknown {216fb341-0eb2-44b1-8edb-60b76e353abc}
    HRESULT returnOK ( )
    HRESULT returnError ( ) ;

COM-INTERFACE: IInherited ISimple {9620ecec-8438-423b-bb14-86f835aa40dd}
    int getX ( ) ;
    void setX ( int newX ) ;

! Implement the IInherited interface in factor using alien-callbacks

: QueryInterface-callback
    "HRESULT" { "void*" "REFGUID" "void**" } "stdcall" [ nip 0 -rot set-void*-nth ]
    alien-callback ;
: AddRef-callback
    "ULONG" { "void*" } "stdcall" [ drop 2 ]
    alien-callback ;
: Release-callback
    "ULONG" { "void*" } "stdcall" [ drop 1 ]
    alien-callback ;
: returnOK-callback
    "HRESULT"{ "void*" } "stdcall" [ drop S_OK ]
    alien-callback ;
: returnError-callback
    "HRESULT"{ "void*" } "stdcall" [ drop E_FAIL ]
    alien-callback ;
: getX-callback
    "int" { "void*" } "stdcall" [ test-interface-x ]
    alien-callback ;
: setX-callback
    "void" { "void*" "int" } "stdcall" [ swap set-test-interface-x ]
    alien-callback ;

SYMBOL: +test-implementation-vtbl+
{
    QueryInterface-callback
    AddRef-callback
    Release-callback
    returnOK-callback
    returnError-callback
    getX-callback
    setX-callback
} [ execute ] map >c-void*-array
+test-implementation-vtbl+ set

C-STRUCT: test-implementation
    { "void*" "vtbl" }
    { "int" "x" } ;

: (make-test-implementation) ( x imp -- imp )
    [ set-test-implementation-x ] keep
    +test-implementation-vtbl+ get over set-test-implementation-vtbl ;

: <test-implementation> ( x -- imp )
    "test-implementation" <c-object> (make-test-implementation) ;

! Test that the words defined by COM-INTERFACE: do their magic

"{216fb341-0eb2-44b1-8edb-60b76e353abc}" string>guid 1array [ ISimple-iid ] unit-test
"{9620ecec-8438-423b-bb14-86f835aa40dd}" string>guid 1array [ IInherited-iid ] unit-test
"{00000000-0000-0000-C000-000000000046}" string>guid 1array [ IUnknown-iid ] unit-test
S_OK 1array [ 0 <test-implementation> ISimple::returnOK ] unit-test
E_FAIL 1array [ 0 <test-implementation> ISimple::returnError ] unit-test
1984 1array [ 0 <test-implementation> dup 1984 IInherited::setX IInherited::getX ] unit-test

! Test that the helper functions for QueryInterface, AddRef, Release work

: <malloced-test-implementation> ( x -- imp )
    "test-implementation" heap-size malloc (make-test-implementation) ;

SYMBOL: +guinea-pig-implementation+

0 <malloced-test-implementation> +guinea-pig-implementation+ set
[
    +guinea-pig-implementation+ get 1array [
        +guinea-pig-implementation+ get IUnknown-iid com-query-interface
    ] unit-test

    { } [ +guinea-pig-implementation+ get com-add-ref ] unit-test
    { } [ +guinea-pig-implementation+ get com-release ] unit-test
] [ +guinea-pig-implementation+ get free ] [ ] cleanup

