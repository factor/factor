! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel locals.types macros.expander fry ;
IN: locals.macros

M: lambda expand-macros clone [ expand-macros ] change-body ;

M: lambda expand-macros* expand-macros literal ;

M: binding-form expand-macros
    clone
        [ [ expand-macros ] assoc-map ] change-bindings
        [ expand-macros ] change-body ;

M: binding-form expand-macros* expand-macros literal ;

M: lambda condomize? drop t ;

M: lambda condomize '[ @ ] ;