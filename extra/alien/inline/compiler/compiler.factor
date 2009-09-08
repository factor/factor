! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry generalizations
io.encodings.ascii io.files io.files.temp io.launcher kernel
locals make sequences system vocabs.parser words io.directories
io.pathnames ;
IN: alien.inline.compiler

SYMBOL: C
SYMBOL: C++

: inline-libs-directory ( -- path )
    "alien-inline-libs" resource-path dup make-directories ;

: inline-library-file ( name -- path )
    inline-libs-directory prepend-path ;

: library-suffix ( -- str )
    os {
        { [ dup macosx? ]  [ drop ".dylib" ] }
        { [ dup unix? ]    [ drop ".so" ] }
        { [ dup windows? ] [ drop ".dll" ] }
    } cond ;

: library-path ( str -- path )
    '[ "lib" % _ % library-suffix % ] "" make inline-library-file ;

HOOK: compiler os ( lang -- str )

M: word compiler
    {
        { C [ "gcc" ] }
        { C++ [ "g++" ] }
    } case ;

M: openbsd compiler
    {
        { C [ "gcc" ] }
        { C++ [ "eg++" ] }
    } case ;

M: windows compiler
    {
        { C [ "gcc" ] }
        { C++ [ "g++" ] }
    } case ;

HOOK: compiler-descr os ( lang -- descr )

M: word compiler-descr compiler 1array ;
M: macosx compiler-descr
    call-next-method cpu x86.64?
    [ { "-arch" "x86_64" } append ] when ;

HOOK: link-descr os ( lang -- descr )

M: word link-descr drop { "-shared" "-o" } ;
M: macosx link-descr
    drop { "-g" "-prebind" "-dynamiclib" "-o" }
    cpu x86.64? [ { "-arch" "x86_64" } prepend ] when ;
M: windows link-descr
    {
        { C [ { "-mno-cygwin" "-shared" "-o" } ] }
        { C++ [ { "-lstdc++" "-mno-cygwin" "-shared" "-o" } ] }
    } case ;

<PRIVATE
: src-suffix ( lang -- str )
    {
        { C [ ".c" ] }
        { C++ [ ".cpp" ] }
    } case ;

: link-command ( args in out lang -- descr )
    [ 2array ] dip [ compiler 1array ] [ link-descr ] bi
    append prepend prepend ;

:: compile-to-object ( lang contents name -- )
    name ".o" append temp-file
    contents name lang src-suffix append temp-file
    [ ascii set-file-contents ] keep 2array
    lang compiler-descr { "-fPIC" "-c" "-o" } append prepend
    try-process ;

:: link-object ( lang args name -- )
    args name [ library-path ]
    [ ".o" append temp-file ] bi
    lang link-command try-process ;
PRIVATE>

:: compile-to-library ( lang args contents name -- )
    lang contents name compile-to-object
    lang args name link-object ;
