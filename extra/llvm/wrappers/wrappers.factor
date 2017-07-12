! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings destructors io
io.encodings.utf8 kernel llvm.ffi ;
IN: llvm.wrappers

ERROR: llvm-error message ;

: llvm-throw ( c-string -- )
    [ utf8 alien>string ] [ LLVMDisposeMessage ] bi llvm-error ;

: <dispose> ( alien class -- disposable ) new swap >>value ;

TUPLE: module value disposed ;
M: module dispose* value>> LLVMDisposeModule ;

: <module> ( name -- module )
    LLVMModuleCreateWithName module <dispose> ;

TUPLE: provider value module disposed ;
M: provider dispose* value>> LLVMDisposeModuleProvider ;

: (provider) ( module -- provider )
    [ value>> LLVMCreateModuleProviderForExistingModule provider <dispose> ]
    [ t >>disposed value>> ] bi
    >>module ;

: <provider> ( module -- provider )
    [ (provider) ] with-disposal ;

TUPLE: buffer value disposed ;
M: buffer dispose* value>> LLVMDisposeMemoryBuffer ;

: <buffer> ( path -- buffer )
    f void* <ref> f void* <ref>
    [ LLVMCreateMemoryBufferWithContentsOfFile drop ] 2keep
    void* deref [ llvm-throw ] when* void* deref buffer <dispose> ;
