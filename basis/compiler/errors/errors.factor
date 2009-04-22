! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors source-files.errors kernel namespaces assocs ;
IN: compiler.errors

TUPLE: compiler-error < source-file-error ;

M: compiler-error error-type error>> error-type ;

SYMBOL: compiler-errors

compiler-errors [ H{ } clone ] initialize

SYMBOLS: +compiler-error+ +compiler-warning+ +linkage-error+ ;

: errors-of-type ( type -- assoc )
    compiler-errors get-global
    swap [ [ nip error-type ] dip eq? ] curry
    assoc-filter ;

T{ error-type
   { type +compiler-error+ }
   { word ":errors" }
   { plural "compiler errors" }
   { icon "vocab:ui/tools/error-list/icons/compiler-error.tiff" }
   { quot [ +compiler-error+ errors-of-type values ] }
   { forget-quot [ compiler-errors get delete-at ] }
} define-error-type

T{ error-type
   { type +compiler-warning+ }
   { word ":warnings" }
   { plural "compiler warnings" }
   { icon "vocab:ui/tools/error-list/icons/compiler-warning.tiff" }
   { quot [ +compiler-warning+ errors-of-type values ] }
   { forget-quot [ compiler-errors get delete-at ] }
} define-error-type

T{ error-type
   { type +linkage-error+ }
   { word ":linkage" }
   { plural "linkage errors" }
   { icon "vocab:ui/tools/error-list/icons/linkage-error.tiff" }
   { quot [ +linkage-error+ errors-of-type values ] }
   { forget-quot [ compiler-errors get delete-at ] }
   { fatal? f }
} define-error-type

: <compiler-error> ( error word -- compiler-error )
    \ compiler-error <definition-error> ;

: compiler-error ( error word -- )
    compiler-errors get-global pick
    [ [ [ <compiler-error> ] keep ] dip set-at ] [ delete-at drop ] if ;

ERROR: not-compiled word error ;