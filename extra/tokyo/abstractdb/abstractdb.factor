! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel tokyo.alien.tcadb tokyo.assoc-functor ;
IN: tokyo.abstractdb

<< "tcadb" "abstractdb" define-tokyo-assoc-api >>

: <tokyo-abstractdb> ( name -- tokyo-abstractdb )
    tcadbnew [ swap tcadbopen drop ] keep
    tokyo-abstractdb new [ handle<< ] keep ;
