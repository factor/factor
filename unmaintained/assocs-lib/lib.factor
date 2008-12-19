USING: arrays assocs kernel vectors sequences namespaces
       random math.parser math fry ;

IN: assocs.lib

: set-assoc-stack ( value key seq -- )
    dupd [ key? ] with find-last nip set-at ;

: at-default ( key assoc -- value/key )
    dupd at [ nip ] when* ;

: replace-at ( assoc value key -- assoc )
    [ dupd 1vector ] dip rot set-at ;

: peek-at* ( assoc key -- obj ? )
    swap at* dup [ [ peek ] dip ] when ;

: peek-at ( assoc key -- obj )
    peek-at* drop ;

: >multi-assoc ( assoc -- new-assoc )
    [ 1vector ] assoc-map ;

: multi-assoc-each ( assoc quot -- )
    [ with each ] curry assoc-each ; inline

: insert ( value variable -- ) namespace push-at ;

: generate-key ( assoc -- str )
    [ 32 random-bits >hex ] dip
    2dup key? [ nip generate-key ] [ drop ] if ;

: set-at-unique ( value assoc -- key )
    dup generate-key [ swap set-at ] keep ;

: histogram ( assoc quot -- assoc' )
    H{ } clone [
        swap [ change-at ] 2curry assoc-each
    ] keep ; inline

: ?at ( obj assoc -- value/obj ? )
    dupd at* [ [ nip ] [ drop ] if ] keep ;

: if-at ( obj assoc quot1 quot2 -- )
    [ ?at ] 2dip if ; inline

: when-at ( obj assoc quot -- ) [ ] if-at ; inline

: unless-at ( obj assoc quot -- ) [ ] swap if-at ; inline
