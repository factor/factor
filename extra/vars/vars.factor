! Copyright (C) 2005, 2006 Eduardo Cavazos

! Thanks to Mackenzie Straight for the idea

USING: kernel parser words namespaces sequences quotations ;

IN: vars

: define-var-symbol ( str -- ) create-in define-symbol ;

: define-var-getter ( str -- )
dup ">" append create-in swap in get lookup [ get ] curry define-compound ;

: define-var-setter ( str -- )
">" over append create-in swap in get lookup [ set ] curry define-compound ;

: define-var ( str -- )
dup define-var-symbol dup define-var-getter define-var-setter ;

: VAR: ! var
    scan define-var ; parsing

: define-vars ( seq -- ) [ define-var ] each ;

: VARS: ! vars ...
";" parse-tokens define-vars ; parsing
