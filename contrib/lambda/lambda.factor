#! An interpreter for lambda expressions, by Matthew Willis
REQUIRES: lazy-lists ;
USING: lazy-lists io strings hashtables sequences kernel ;
IN: lambda

#! every expression has a canonical representation of this form
: bound-variables-list ( -- lazy-list ) 65 lfrom [ ch>string ] lmap ;

TUPLE: linterp names reps ;
: (lint>string) ( linterp expr -- linterp )
    bound-variables-list swap expr>string over dupd linterp-reps hash 
    ", " join ":" append swap append "=> " swap append ;

: update-names ( names-hash name expr -- names-hash )
    swap rot [ set-hash ] keep ;

C: linterp ( names-hash )
    #! take a names hash, and generate the reverse lookup hash from it.
    #! TODO: make this really ugly code cleaner
    2dup set-linterp-names swap H{ } clone [ swap hash>alist
    [ [ first ] keep second bound-variables-list swap expr>string rot
    [ hash ] 2keep rot dup not [ drop rot { } swap add -rot ] 
    [ >r rot r> swap add -rot ] if set-hash ] each-with ] keep
    swap [ set-linterp-reps ] keep ;

: lint-read ( -- input )
    readln [ "." = ] keep swap ;

: lint-eval ( linterp input -- linterp name expr )
    lambda-parse [ first ] keep second pick linterp-names swap replace-names
    evaluate ;

: lint>string ( linterp name expr -- linterp  )
    rot linterp-names -rot [ update-names ] keep [ <linterp> ] dip
    (lint>string) ;

: lint-print ( linterp name expr -- linterp )
    lint>string print flush ;

: lint-boot ( -- initial-names )
    H{ } clone <linterp> ;

: (lint) ( linterp -- linterp )
     lint-read [ drop ] [ lint-eval lint-print (lint) ] if ;

: lint ( -- linterp )
    lint-boot (lint) ;