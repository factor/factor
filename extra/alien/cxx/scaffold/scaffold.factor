! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.cxx.demangle assocs combinators io.pathnames
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
