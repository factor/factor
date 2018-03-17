USING: help.markup help.syntax io kernel math quotations
alien windows.com windows.com.syntax continuations
destructors ;
IN: windows.com.wrapper

HELP: <com-wrapper>
{ $values { "implementations" "an assoc relating COM interface names to arrays of quotations implementing that interface" } { "wrapper" "a " { $link com-wrapper } " tuple" } }
{ $description "Constructs a " { $link com-wrapper } " tuple. Each key in the " { $snippet "implementations" } " assoc must be the name of an interface defined with " { $link POSTPONE: COM-INTERFACE: } ". The corresponding value must be an array of quotations implementing the methods of that interface in order, including those of its parent interfaces. The " { $snippet "IUnknown" } " methods (" { $link IUnknown::QueryInterface } ", " { $link IUnknown::AddRef } ", and " { $link IUnknown::Release } ") will be defined automatically and must not be specified in the array. These quotations should have stack effects mirroring those of the interface methods being implemented; for example, a method " { $snippet "void foobar ( int foo, int bar )" } " should be implemented with a quotation of effect " { $snippet "( this foo bar -- )" } ". The " { $snippet "this" } " parameter (that is, the leftmost parameter of any COM method) will be automatically converted from an alien pointer to the underlying Factor object before the quotation is invoked.\n\nThe resulting wrapper can be applied to a Factor object using the " { $link com-wrap } " word. The COM interface pointer returned by " { $snippet "com-wrap" } " can then be passed to C functions requiring a COM object as a parameter. The vtables constructed by " { $snippet "<com-wrapper>" } " are stored on the non-GC heap in order to be accessible to C functions; when the wrapper object and its vtables are no longer needed, the object's resources must be freed using " { $link dispose } ".\n\nExample:" }
{ $code "
<<
COM-INTERFACE: ISimple IUnknown {216fb341-0eb2-44b1-8edb-60b76e353abc}
    HRESULT returnOK ( )
    HRESULT returnError ( ) ;

COM-INTERFACE: IInherited ISimple {9620ecec-8438-423b-bb14-86f835aa40dd}
    int getX ( )
    void setX ( int newX ) ;

COM-INTERFACE: IUnrelated IUnknown {b06ac3f4-30e4-406b-a7cd-c29cead4552c}
    int xPlus ( int y )
    int xMulAdd ( int mul, int add ) ;
>>
<<
{
    { IInherited {
        [ drop S_OK ]    ! ISimple::returnOK
        [ drop E_FAIL ]  ! ISimple::returnError
        [ x>> ]          ! IInherited::getX
        [ >>x drop ]     ! IInherited::setX
    } }
    { IUnrelated {
        [ [ x>> ] [ + ] bi* ]   ! IUnrelated::xPlus
        [ [ x>> ] [ * ] [ + ] tri* ] ! IUnrealted::xMulAdd
    } }
} <com-wrapper> . ! In your code, set to a variable instead of printing
>>" } ;

HELP: com-wrap
{ $values { "object" "The factor object to wrap" } { "wrapper" "A " { $link com-wrapper } " object" } { "wrapped-object" "A COM object referencing " { $snippet "object" } } }
{ $description "Allocates a COM object using the implementations in the " { $snippet "wrapper" } " object for the vtables and " { $snippet "object" } " for the \"this\" parameter. The COM object is allocated on the heap with an initial reference count of 1. The object will automatically deallocate itself when its reference count reaches 0 as a result of calling " { $link IUnknown::Release } " or " { $link com-release } " on it.\n\nNote that if " { $snippet "wrapper" } " implements multiple interfaces, you cannot count on the returned COM object pointer implementing any particular interface beyond " { $snippet "IUnknown" } ". You will need to use " { $link com-query-interface } " or " { $link IUnknown::QueryInterface } " to ask the object for the particular interface you need." } ;

HELP: com-wrapper
{ $class-description "The tuple class used to store COM wrapper information. Objects of this class should be treated as opaque by user code. A com-wrapper can be constructed using the " { $link <com-wrapper> } " constructor and applied to a Factor object using " { $link com-wrap } ". When no longer needed, release the com-wrapper's internally allocated data with " { $link dispose } "." } ;
