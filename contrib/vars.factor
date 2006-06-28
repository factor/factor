! Copyright (C) 2005, 2006 Eduardo Cavazos

! Thanks to Mackenzie Straight for the idea

USING: kernel parser words namespaces sequences ;

IN: vars

: define-var-symbol ( str -- ) create-in define-symbol ;

: define-var-getter ( str -- )
dup ">" append create-in swap in get lookup [ get ] curry define-compound ;

: define-var-setter ( str -- )
">" over append create-in swap in get lookup [ set ] curry define-compound ;

: define-var ( str -- )
dup define-var-symbol dup define-var-getter define-var-setter ;

: VAR: ( variable -- ) scan define-var ; parsing

: define-vars ( seq -- ) [ define-var ] each ;

: VARS: ( vars ... -- )
string-mode on [ string-mode off define-vars ] f ; parsing

PROVIDE: vars ;