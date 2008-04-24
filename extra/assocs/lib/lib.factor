USING: arrays assocs kernel vectors sequences namespaces
random math.parser ;
IN: assocs.lib

: >set ( seq -- hash )
    [ dup ] H{ } map>assoc ;

: ref-at ( table key -- value ) swap at ;

: put-at* ( table key value -- ) swap rot set-at ;

: put-at ( table key value -- table ) swap pick set-at ;

: set-assoc-stack ( value key seq -- )
    dupd [ key? ] with find-last nip set-at ;

: at-default ( key assoc -- value/key )
    dupd at [ nip ] when* ;

: replace-at ( assoc value key -- assoc )
    >r >r dup r> 1vector r> rot set-at ;

: insert-at ( value key assoc -- )
    [ ?push ] change-at ;

: peek-at* ( assoc key -- obj ? )
    swap at* dup [ >r peek r> ] when ;

: peek-at ( assoc key -- obj )
    peek-at* drop ;

: >multi-assoc ( assoc -- new-assoc )
    [ 1vector ] assoc-map ;

: multi-assoc-each ( assoc quot -- )
    [ with each ] curry assoc-each ; inline

: insert ( value variable -- ) namespace insert-at ;

: generate-key ( assoc -- str )
    >r 256 random-bits >hex r>
    2dup key? [ nip generate-key ] [ drop ] if ;

: set-at-unique ( value assoc -- key )
    dup generate-key [ swap set-at ] keep ;
