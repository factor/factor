! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays combinators
kernel llvm.core locals math.parser math multiline namespaces
parser peg.ebnf sequences sequences.deep specialized-arrays
strings vocabs words ;
SPECIALIZED-ARRAY: void*
IN: llvm.types

! Type resolution strategy:
!  pass 1:
!    create the type with uprefs mapped to opaque types
!    cache typerefs in enclosing types for pass 2
!    if our type is concrete, then we are done
!
!  pass 2:
!    wrap our abstract type in a type handle
!    create a second type, using the cached enclosing type info
!    resolve the first type to the second
!
GENERIC: (>tref) ( type -- LLVMTypeRef )
GENERIC: ((tref>)) ( LLVMTypeRef type -- type )
GENERIC: c-type ( type -- str )

! default implementation for simple types
M: object ((tref>)) nip ;
: unsupported-type ( -- )
    "cannot generate c-type: unsupported llvm type" throw ;
M: object c-type unsupported-type ;

TUPLE: integer size ;
C: <integer> integer

M: integer (>tref) size>> LLVMIntType ;
M: integer ((tref>)) swap LLVMGetIntTypeWidth >>size ;
M: integer c-type size>> {
    { 64 [ "longlong" ] }
    { 32 [ "int" ] }
    { 16 [ "short" ] }
    { 8  [ "char" ] }
    [ unsupported-type ]
} case ;

SINGLETONS: float double x86_fp80 fp128 ppc_fp128 ;

M: float (>tref) drop LLVMFloatType ;
M: double (>tref) drop LLVMDoubleType ;
M: double c-type drop "double" ;
M: x86_fp80 (>tref) drop LLVMX86FP80Type ;
M: fp128 (>tref) drop LLVMFP128Type ;
M: ppc_fp128 (>tref) drop LLVMPPCFP128Type ;

SINGLETONS: opaque label void metadata ;

M: opaque (>tref) drop LLVMOpaqueType ;
M: label (>tref) drop LLVMLabelType ;
M: void (>tref) drop LLVMVoidType ;
M: void c-type drop "void" ;
M: metadata (>tref) drop
    "metadata types unsupported by llvm c bindings" throw ;

! enclosing types cache their llvm refs during
! the first pass, used in the second pass to
! resolve uprefs
TUPLE: enclosing cached ;

GENERIC: clean ( type -- )
GENERIC: clean* ( type -- )
M: object clean drop ;
M: enclosing clean f >>cached clean* ;

! builds the stack of types that uprefs need to refer to
SYMBOL: types
:: push-type ( type quot: ( type -- LLVMTypeRef ) -- LLVMTypeRef )
    type types get push
    type quot call( type -- LLVMTypeRef )
    types get pop over >>cached drop ;

DEFER: <up-ref>
:: push-ref ( ref quot: ( LLVMTypeRef -- type ) -- type )
    ref types get index
    [ types get length swap - <up-ref> ] [
        ref types get push
        ref quot call( LLVMTypeRef -- type )
        types get pop drop
    ] if* ;

GENERIC: (>tref)* ( type -- LLVMTypeRef )
M: enclosing (>tref) [ (>tref)* ] push-type ;

DEFER: type-kind
GENERIC: (tref>)* ( LLVMTypeRef type -- type )
M: enclosing ((tref>)) [ (tref>)* ] curry push-ref ;

: (tref>) ( LLVMTypeRef -- type ) dup type-kind ((tref>)) ;

TUPLE: pointer < enclosing type ;
: <pointer> ( t -- o ) pointer new swap >>type ;

M: pointer (>tref)* type>> (>tref) 0 LLVMPointerType ;
M: pointer clean* type>> clean ;
M: pointer (tref>)* swap LLVMGetElementType (tref>) >>type ;
M: pointer c-type type>> 8 <integer> = "c-string" "void*" ? ;

TUPLE: vector < enclosing size type ;
: <vector> ( s t -- o )
    vector new
    swap >>type swap >>size ;

M: vector (>tref)* [ type>> (>tref) ] [ size>> ] bi LLVMVectorType ;
M: vector clean* type>> clean ;
M: vector (tref>)*
    over LLVMGetElementType (tref>) >>type
    swap LLVMGetVectorSize >>size ;

TUPLE: struct < enclosing types packed? ;
: <struct> ( ts p? -- o )
    struct new
    swap >>packed? swap >>types ;

M: struct (>tref)*
    [ types>> [ (>tref) ] map void* >c-array ]
    [ types>> length ]
    [ packed?>> 1 0 ? ] tri LLVMStructType ;
M: struct clean* types>> [ clean ] each ;
M: struct (tref>)*
    over LLVMIsPackedStruct 0 = not >>packed?
    swap dup LLVMCountStructElementTypes void* <c-array>
    [ LLVMGetStructElementTypes ] keep >array
    [ (tref>) ] map >>types ;

TUPLE: array < enclosing size type ;
: <array> ( s t -- o )
    array new
    swap >>type swap >>size ;

M: array (>tref)* [ type>> (>tref) ] [ size>> ] bi LLVMArrayType ;
M: array clean* type>> clean ;
M: array (tref>)*
    over LLVMGetElementType (tref>) >>type
    swap LLVMGetArrayLength >>size ;

SYMBOL: ...
TUPLE: function < enclosing return params vararg? ;
: <function> ( ret params var? -- o )
    function new
    swap >>vararg? swap >>params swap >>return ;

M: function (>tref)* {
    [ return>> (>tref) ]
    [ params>> [ (>tref) ] map void* >c-array ]
    [ params>> length ]
    [ vararg?>> 1 0 ? ]
} cleave LLVMFunctionType ;
M: function clean* [ return>> clean ] [ params>> [ clean ] each ] bi ;
M: function (tref>)*
    over LLVMIsFunctionVarArg 0 = not >>vararg?
    over LLVMGetReturnType (tref>) >>return
    swap dup LLVMCountParamTypes void* <c-array>
    [ LLVMGetParamTypes ] keep >array
    [ (tref>) ] map >>params ;

: type-kind ( LLVMTypeRef -- class )
    LLVMGetTypeKind {
        { LLVMVoidTypeKind [ void ] }
        { LLVMFloatTypeKind [ float ] }
        { LLVMDoubleTypeKind [ double ] }
        { LLVMX86_FP80TypeKind [ x86_fp80 ] }
        { LLVMFP128TypeKind [ fp128 ] }
        { LLVMPPC_FP128TypeKind [ ppc_fp128 ] }
        { LLVMLabelTypeKind [ label ] }
        { LLVMIntegerTypeKind [ integer new ] }
        { LLVMFunctionTypeKind [ function new ] }
        { LLVMStructTypeKind [ struct new ] }
        { LLVMArrayTypeKind [ array new ] }
        { LLVMPointerTypeKind [ pointer new ] }
        { LLVMOpaqueTypeKind [ opaque ] }
        { LLVMVectorTypeKind [ vector new ] }
   } case ;

TUPLE: up-ref height ;
C: <up-ref> up-ref

M: up-ref (>tref)
    types get length swap height>> - types get nth
    cached>> [ LLVMOpaqueType ] unless* ;

: resolve-types ( typeref typeref -- typeref )
    over LLVMCreateTypeHandle [ LLVMRefineType ] dip
    [ LLVMResolveTypeHandle ] keep LLVMDisposeTypeHandle ;

: >tref-caching ( type -- LLVMTypeRef )
    V{ } clone types [ (>tref) ] with-variable ;

: >tref ( type -- LLVMTypeRef )
    [ >tref-caching ] [ >tref-caching ] [ clean ] tri
    2dup = [ drop ] [ resolve-types ] if ;

: tref> ( LLVMTypeRef -- type )
    V{ } clone types [ (tref>) ] with-variable ;

: t. ( type -- )
    >tref
    "type-info" LLVMModuleCreateWithName
    [ "t" rot LLVMAddTypeName drop ]
    [ LLVMDumpModule ]
    [ LLVMDisposeModule ] tri ;

EBNF: parse-type

WhiteSpace = " "*

Zero = "0" => [[ drop 0 ]]
LeadingDigit = [1-9]
DecimalDigit = [0-9]
Number = LeadingDigit:d (DecimalDigit)*:ds => [[ ds d prefix string>number ]]
WhiteNumberSpace = WhiteSpace Number:n WhiteSpace => [[ n ]]
WhiteZeroSpace = WhiteSpace (Zero | Number):n WhiteSpace => [[ n ]]

Integer = "i" Number:n => [[ n <integer> ]]
FloatingPoint = ( "float" | "double" | "x86_fp80" | "fp128" | "ppc_fp128" ) => [[ "llvm.types" vocab lookup-word ]]
LabelVoidMetadata = ( "label" | "void" | "metadata" | "opaque" ) => [[ "llvm.types" vocab lookup-word ]]
Primitive = LabelVoidMetadata | FloatingPoint
Pointer = T:t WhiteSpace "*" => [[ t <pointer> ]]
Vector = "<" WhiteNumberSpace:n "x" Type:t ">" => [[ n t <vector> ]]
StructureTypesList = "," Type:t => [[ t ]]
Structure = "{" Type:t (StructureTypesList)*:ts "}" => [[ ts t prefix >array f <struct> ]]
Array = "[" WhiteZeroSpace:n "x" Type:t "]" => [[ n t <array> ]]
NoFunctionParams = "(" WhiteSpace ")" => [[ drop { } ]]
VarArgs = WhiteSpace "..." WhiteSpace => [[ drop ... ]]
ParamListContinued = "," (Type | VarArgs):t => [[ t ]]
ParamList = "(" Type:t (ParamListContinued*):ts ")" => [[ ts t prefix ]]
Function = T:t WhiteSpace ( ParamList | NoFunctionParams ):ts => [[ ... ts member? dup [ ... ts remove! drop ] when t ts >array rot <function> ]]
PackedStructure = "<" WhiteSpace "{" Type:ty (StructureTypesList)*:ts "}" WhiteSpace ">" => [[ ts ty prefix >array t <struct> ]]
UpReference = "\\" Number:n => [[ n <up-ref> ]]
Name = '%' ([a-zA-Z][a-zA-Z0-9]*):id => [[ id flatten >string ]]

T = Pointer | Function | Primitive | Integer | Vector | Structure | PackedStructure | Array | UpReference | Name

Type = WhiteSpace T:t WhiteSpace => [[ t ]]

Program = Type

;EBNF

SYNTAX: TYPE: ";" parse-multiline-string parse-type suffix! ;
