! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry generalizations
io.encodings.ascii io.files io.files.temp io.launcher kernel
locals sequences system ;
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

: link-command ( in out lang -- descr )
    compiler os {
        { [ dup linux? ]
          [ drop { "-shared" "-o" } ] }
        { [ dup macosx? ]
          [ drop { "-g" "-prebind" "-dynamiclib" "-o" } ] }
        [ name>> "unimplemented for: " prepend throw ]
    } cond swap prefix prepend prepend ;

:: compile-to-object ( lang contents name -- )
    name ".o" append temp-file
    contents name lang src-suffix append temp-file
    [ ascii set-file-contents ] keep 2array
    { "-fPIC" "-c" "-o" } lang compiler prefix prepend
    try-process ;

:: link-object ( lang args name -- )
    args name [ "lib" prepend library-suffix append ]
    [ ".o" append ] bi [ temp-file ] bi@ 2array
    lang link-command try-process ;

:: compile-to-library ( lang args contents name -- )
    lang contents name compile-to-object
    lang args name link-object ;
