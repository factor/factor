! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data byte-arrays continuations fry
io.encodings.string io.encodings.utf8 io.files
javascriptcore.ffi javascriptcore.ffi.hack kernel namespaces
sequences ;
IN: javascriptcore

ERROR: javascriptcore-error error ;

SYMBOL: js-context

: with-global-context ( quot -- )
    [
        [ f JSGlobalContextCreate dup js-context set ] dip
        [ nip '[ @ ] ]
        [ drop '[ _ JSGlobalContextRelease ] ] 2bi
        [ ] cleanup
    ] with-scope ; inline

: with-javascriptcore ( quot -- )
    set-callstack-bounds
    with-global-context ; inline

: JSString>string ( JSString -- string )
    dup JSStringGetMaximumUTF8CStringSize [ <byte-array> ] keep
    [ JSStringGetUTF8CString drop ] [ drop ] 2bi
    utf8 decode [ 0 = ] trim-tail ;

: JSValueRef>string ( ctx JSValueRef/f -- string/f )
    [
        f JSValueToStringCopy
        [ JSString>string ] [ JSStringRelease ] bi
    ] [
        drop f
    ] if* ;

: eval-js ( string -- result-string )
    [ js-context get dup ] dip
    JSStringCreateWithUTF8CString f f 0 JSValueRef <c-object>
    [ JSEvaluateScript ] keep *void*
    dup [ nip JSValueRef>string javascriptcore-error ] [ drop JSValueRef>string ] if ;

: eval-js-standalone ( string -- result-string )
    '[ _ eval-js ] with-javascriptcore ;

: eval-js-path-standalone ( path -- result-string ) utf8 file-contents eval-js-standalone ;

