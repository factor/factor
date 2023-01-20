! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel locals.types macros.expander ;
IN: locals.macros

M: lambda expand-macros clone [ expand-macros ] change-body ;

M: lambda expand-macros* expand-macros literal ;

M: let expand-macros
    clone [ expand-macros ] change-body ;

M: let expand-macros* expand-macros literal ;

M: lambda condomize? drop t ;

M: lambda condomize [ call ] curry ;
