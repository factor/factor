! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry generalizations
io.encodings.ascii io.files io.files.temp io.launcher kernel
locals sequences system words ;
IN: alien.inline.compiler

SYMBOL: C
SYMBOL: C++

: library-suffix ( -- str )
    os {
        { [ dup macosx? ]  [ drop ".dylib" ] }
        { [ dup unix? ]    [ drop ".so" ] }
        { [ dup windows? ] [ drop ".dll" ] }
    } cond ;

: src-suffix ( lang -- str )
    {
        { C [ ".c" ] }
        { C++ [ ".cpp" ] }
    } case ;

: compiler ( lang -- str )
    {
        { C [ "gcc" ] }
        { C++ [ "g++" ] }
    } case ;

HOOK: compiler-descr os ( lang -- descr )

M: word compiler-descr compiler 1array ;
M: macosx compiler-descr
    call-next-method cpu x86.64?
    [ { "-arch" "x86_64" } append ] when ;

HOOK: link-descr os ( -- descr )

M: word link-descr { "-shared" "-o" } ;
M: macosx link-descr
    { "-g" "-prebind" "-dynamiclib" "-o" }
    cpu x86.64? [ { "-arch" "x86_64" } prepend ] when ;

: link-command ( in out lang -- descr )
    compiler-descr link-descr append prepend prepend ;

:: compile-to-object ( lang contents name -- )
    name ".o" append temp-file
    contents name lang src-suffix append temp-file
    [ ascii set-file-contents ] keep 2array
    lang compiler-descr { "-fPIC" "-c" "-o" } append prepend
    try-process ;

:: link-object ( lang args name -- )
    args name [ "lib" prepend library-suffix append ]
    [ ".o" append ] bi [ temp-file ] bi@ 2array
    lang link-command try-process ;

:: compile-to-library ( lang args contents name -- )
    lang contents name compile-to-object
    lang args name link-object ;
