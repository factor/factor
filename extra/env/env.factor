! (c)2009 Joe Groff, see bsd license
USING: assocs environment kernel sequences ;
IN: env

SINGLETON: env

INSTANCE: env assoc

M: env at*
    drop os-env dup >boolean ;

M: env assoc-size
    drop (os-envs) length ;

M: env >alist
    drop os-envs >alist ;

M: env set-at
    drop set-os-env ;

M: env delete-at
    drop unset-os-env ;

M: env clear-assoc
    drop os-envs keys [ unset-os-env ] each ;

