! (c)2010 Joe Groff bsd license
USING: alien.cxx.demangle assocs combinators fry io.pathnames
kernel macho sequences ;
IN: alien.cxx.scaffold

: library-symbols ( file -- symbols )
    dup file-extension {
        { "dylib" [ dylib-exports ] }
        { f       [ dylib-exports ] }
    } case ;

: c++-library-symbols ( file abi -- symbols )
    [ library-symbols ] dip
    [ '[ _ c++-symbol? ] filter ]
    [ '[ dup _ demangle ] H{ } map>assoc ] bi ;
