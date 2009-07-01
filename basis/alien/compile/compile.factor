USING: accessors arrays combinators generalizations
io.encodings.ascii io.files io.files.temp io.launcher kernel
sequences system ;
IN: alien.compile

: library-suffix ( -- str )
    os {
        { [ dup macosx? ]  [ drop ".dylib" ] }
        { [ dup unix? ]    [ drop ".so" ] }
        { [ dup windows? ] [ drop ".dll" ] }
    } cond ;

: compile-to-object ( compiler contents name -- )
    [ ".src" append ] [ ".o" append ] bi [ temp-file ] bi@
    [ tuck ascii set-file-contents ] dip
    swap 2array { "-fPIC" "-c" "-o" } prepend
    swap prefix try-process ;

: link-object ( compiler args name -- )
    [ "lib" prepend library-suffix append ] [ ".o" append ] bi
    [ temp-file ] bi@ 2array
    os {
        { [ dup linux? ]
            [ drop { "-shared" "-o" } ] }
        { [ dup macosx? ]
            [ drop { "-g" "-prebind" "-dynamiclib" "-o" } ] }
        [ name>> "unimplemented for: " prepend throw ]
    } cond prepend prepend swap prefix try-process ;

: compile-to-library ( compiler args contents name -- )
    [ [ nip ] dip compile-to-object ] 4 nkeep nip link-object ;
