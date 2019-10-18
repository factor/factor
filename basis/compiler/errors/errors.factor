! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors source-files.errors kernel namespaces assocs fry
summary ;
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

: compiler-error ( error -- )
    dup asset>> compiler-errors get-global set-at ;

T{ error-type
   { type +compiler-error+ }
   { word ":errors" }
   { plural "compiler errors" }
   { icon "vocab:ui/tools/error-list/icons/compiler-error.tiff" }
   { quot [ compiler-errors get values ] }
   { forget-quot [ compiler-errors get delete-at ] }
} define-error-type

: <compiler-error> ( error word -- compiler-error )
    \ compiler-error <definition-error> ;

: <linkage-error> ( error word -- linkage-error )
    \ linkage-error <definition-error> ;

: linkage-error ( error word class -- )
    '[ _ boa ] dip <linkage-error> dup asset>> linkage-errors get set-at ; inline

T{ error-type
   { type +linkage-error+ }
   { word ":linkage" }
   { plural "linkage errors" }
   { icon "vocab:ui/tools/error-list/icons/linkage-error.tiff" }
   { quot [ linkage-errors get values ] }
   { forget-quot [ linkage-errors get delete-at ] }
   { fatal? f }
} define-error-type

TUPLE: no-such-library name ;

M: no-such-library summary drop "Library not found" ;

: no-such-library ( name word -- ) \ no-such-library linkage-error ;

TUPLE: no-such-symbol name ;

M: no-such-symbol summary drop "Symbol not found" ;

: no-such-symbol ( name word -- ) \ no-such-symbol linkage-error ;

ERROR: not-compiled word error ;