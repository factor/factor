USING: help.markup help.syntax io kernel math quotations
multiline ;
IN: windows.com.syntax

HELP: COM-INTERFACE:
{ $syntax <"
COM-INTERFACE: <interface> <parent> <iid>
    <function-1> ( <params1> )
    <function-2> ( <params2> )
    ... ;
"> }
{ $description "\nFor the interface " { $snippet "<interface>" } ", a word " { $snippet "<interface>-iid ( -- iid )" } " is defined to push the interface GUID (IID) onto the stack. Words of the form " { $snippet "<interface>::<function>" } " are also defined to invoke each method, as well as the methods inherited from " { $snippet "<parent>" } ". A " { $snippet "<parent>" } " of " { $snippet "f" } " indicates that the interface is a root interface. (Note that COM conventions demand that all interfaces at least inherit from " { $snippet "IUnknown" } ".)\n\nExample:" }
{ $code <"
COM-INTERFACE: IUnknown f {00000000-0000-0000-C000-000000000046}
    HRESULT QueryInterface ( REFGUID iid, void** ppvObject )
    ULONG AddRef ( )
    ULONG Release ( ) ;

COM-INTERFACE: ISimple IUnknown {216fb341-0eb2-44b1-8edb-60b76e353abc}
    HRESULT returnOK ( )
    HRESULT returnError ( ) ;

COM-INTERFACE: IInherited ISimple {9620ecec-8438-423b-bb14-86f835aa40dd}
    int getX ( )
    void setX ( int newX ) ;
"> } ;
