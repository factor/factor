! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs command-line fry kernel namespaces
source-files.errors summary ;
IN: compiler.errors

SYMBOL: +compiler-error+
SYMBOL: compiler-errors

compiler-errors [ H{ } clone ] initialize

TUPLE: compiler-error < source-file-error ;

M: compiler-error error-type drop +compiler-error+ ;

SYMBOL: +linkage-error+
SYMBOL: linkage-errors

linkage-errors [ H{ } clone ] initialize

TUPLE: linkage-error < source-file-error ;

M: linkage-error error-type drop +linkage-error+ ;

: clear-compiler-error ( word -- )
    compiler-errors linkage-errors
    [ get-global delete-at ] bi-curry@ bi ;

: save-compiler-error ( error -- )
    dup asset>> compiler-errors get-global set-at ;

T{ error-type-holder
    { type +compiler-error+ }
    { word ":errors" }
    { plural "compiler errors" }
    { icon "vocab:ui/tools/error-list/icons/compiler-error.png" }
    { quot [ compiler-errors get values ] }
    { forget-quot [ compiler-errors get delete-at ] }
} define-error-type

: <compiler-error> ( error word -- compiler-error )
    compiler-error new-source-file-error ;

: <linkage-error> ( error word -- linkage-error )
    linkage-error new-source-file-error ;

: set-linkage-error ( name message word class -- )
    '[ _ boa ] dip <linkage-error> dup asset>> linkage-errors get set-at ; inline

T{ error-type-holder
    { type +linkage-error+ }
    { word ":linkage" }
    { plural "linkage errors" }
    { icon "vocab:ui/tools/error-list/icons/linkage-error.png" }
    { quot [ linkage-errors get values ] }
    { forget-quot [ linkage-errors get delete-at ] }
    { fatal? f }
} define-error-type

ERROR: no-such-library name message ;

M: no-such-library summary drop "Library not found" ;

: no-such-library-error ( name message word -- )
    \ no-such-library set-linkage-error ;

ERROR: no-such-symbol name message ;

M: no-such-symbol summary drop "Symbol not found" ;

: no-such-symbol-error ( name message word -- )
    \ no-such-symbol set-linkage-error ;

ERROR: not-compiled word error ;

T{ error-type-holder
    { type +user-init-error+ }
    { word ":user-init-errors" }
    { plural "rc file errors" }
    { icon "vocab:ui/tools/error-list/icons/user-init-error.png" }
    { quot [ user-init-errors get-global values ] }
    { forget-quot [ user-init-errors get-global delete-at ] }
} define-error-type
