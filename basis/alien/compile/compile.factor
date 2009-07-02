USING: accessors arrays combinators fry generalizations
io.encodings.ascii io.files io.files.temp io.launcher kernel
sequences system ;
IN: alien.compile

: library-suffix ( -- str )
    os {
        { [ dup macosx? ]  [ drop ".dylib" ] }
        { [ dup unix? ]    [ drop ".so" ] }
        { [ dup windows? ] [ drop ".dll" ] }
    } cond ;

: src-suffix ( lang -- str )
    {
        { "C" [ ".c" ] }
        { "C++" [ ".cpp" ] }
    } case ;

: compile-to-object ( lang contents name -- )
    rot '[ _ src-suffix append ] [ ".o" append ] bi
    [ temp-file ] bi@
    [ tuck ascii set-file-contents ] dip
    swap 2array { "gcc" "-fPIC" "-c" "-o" } prepend
    try-process ;

: link-object ( args name -- )
    [ "lib" prepend library-suffix append ] [ ".o" append ] bi
    [ temp-file ] bi@ 2array
    os {
        { [ dup linux? ]
            [ drop { "gcc" "-shared" "-o" } ] }
        { [ dup macosx? ]
            [ drop { "gcc" "-g" "-prebind" "-dynamiclib" "-o" } ] }
        [ name>> "unimplemented for: " prepend throw ]
    } cond prepend prepend try-process ;

: compile-to-library ( lang args contents name -- )
    [ [ nip ] dip compile-to-object ] 4 nkeep
    nip link-object drop ;
