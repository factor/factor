! Copyright (C) 2008 William Schlieper <schlieper@unc.edu>
! See http://factorcode.org/license.txt for BSD license.
USING: kernel combinators fry continuations sequences arrays
vectors assocs hashtables heaps namespaces ;
IN: graph-theory

MIXIN: graph
SYMBOL: visited?
ERROR: end-search ;

GENERIC: vertices ( graph -- seq ) flushable

GENERIC: num-vertices ( graph -- n ) flushable

GENERIC: num-edges ( graph -- n ) flushable

GENERIC: adjlist ( from graph -- seq ) flushable

GENERIC: adj? ( from to graph -- ? ) flushable

GENERIC: add-blank-vertex ( index graph -- )

GENERIC: delete-blank-vertex ( index graph -- )

GENERIC: add-edge* ( from to graph -- )

GENERIC: add-edge ( u v graph -- )

GENERIC: delete-edge* ( from to graph -- )

GENERIC: delete-edge ( u v graph -- )

M: graph num-vertices
    vertices length ;

M: graph num-edges
   [ vertices ] [ '[ _ adjlist length ] sigma ] bi ;

M: graph adjlist
    [ vertices ] [ swapd '[ _ swap _ adj? ] filter ] bi ;

M: graph adj?
    swapd adjlist index >boolean ;

M: graph add-edge
    [ add-edge* ] [ swapd add-edge* ] 3bi ;

M: graph delete-edge
    [ delete-edge* ] [ swapd delete-edge* ] 3bi ;

: add-blank-vertices ( seq graph -- )
    '[ _ add-blank-vertex ] each ;

: delete-vertex ( index graph -- )
    [ adjlist ]
    [ '[ _ _ 3dup adj? [ delete-edge* ] [ 3drop ] if ] each ]
    [ delete-blank-vertex ] 2tri ;

<PRIVATE

: search-wrap ( quot graph -- ? )
    [ [ graph set ] [ vertices [ f 2array ] map >hashtable visited? set ] bi
      [ t ] compose [ dup end-search? [ drop f ] [ rethrow ] if ] recover ] with-scope ; inline

: (depth-first) ( v pre post -- )
    { [ 2drop visited? get t -rot set-at ] 
      [ drop call ]
      [ [ graph get adjlist ] 2dip
        '[ dup visited? get at [ drop ] [ _ _ (depth-first) ] if ] each ]
      [ nip call ] } 3cleave ; inline

PRIVATE>

: depth-first ( v graph pre post -- ?list ? )
    '[ _ _ (depth-first) visited? get ] swap search-wrap ; inline

: full-depth-first ( graph pre post tail -- ? )
    '[ [ visited? get [ nip not ] assoc-find ] 
       [ drop _ _ (depth-first) @ ] 
       while 2drop ] swap search-wrap ; inline

: dag? ( graph -- ? )
    V{ } clone swap [ 2dup swap push dupd
                     '[ _ swap graph get adj? not ] all? 
                      [ end-search ] unless ]
                    [ drop dup pop* ] [ ] full-depth-first nip ;

: topological-sort ( graph -- seq/f )
    dup dag?
    [ V{ } clone swap [ drop ] [ prefix ] [ ] full-depth-first drop ]
    [ drop f ] if ;
