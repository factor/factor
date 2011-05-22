! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system ;
IN: graphviz.libcgraph

<<
"libcgraph"
{
    { [ os macosx? ] [ "libcgraph.dylib" ] }
    { [ os unix? ]   [ "libcgraph.so" ] }
    { [ os winnt? ]  [ "libcgraph.dll" ] }
} cond cdecl add-library
>>

LIBRARY: libcgraph

! Types

STRUCT: Agdesc_s
{ directed  uint bits: 1 }
{ strict    uint bits: 1 }
{ no_loop   uint bits: 1 }
{ maingraph uint bits: 1 }
{ flatlock  uint bits: 1 }
{ no_write  uint bits: 1 }
{ has_attrs uint bits: 1 }
{ has_cmpnd uint bits: 1 } ;

CONSTANT: Agdirected
    S{ Agdesc_s { directed 1 } { maingraph 1 } }
CONSTANT: Agstrictdirected
    S{ Agdesc_s { directed 1 } { strict 1 } { maingraph 1 } }
CONSTANT: Agundirected
    S{ Agdesc_s { maingraph 1 } }
CONSTANT: Agstrictundirected
    S{ Agdesc_s { strict 1 } { maingraph 1 } }

C-TYPE:  Agraph_t
C-TYPE:  Agnode_t
C-TYPE:  Agedge_t
TYPEDEF: Agdesc_s Agdesc_t
C-TYPE:  Agdisc_t

! Graphs

FUNCTION: Agraph_t* agopen ( c-string name, Agdesc_t kind, Agdisc_t* disc ) ;
FUNCTION: int       agclose ( Agraph_t* g ) ;
FUNCTION: int       agwrite ( Agraph_t* g, void* channel ) ;

! Subgraphs

FUNCTION: Agraph_t* agsubg ( Agraph_t* g, c-string name, int createflag ) ;

! Nodes

FUNCTION: Agnode_t* agnode ( Agraph_t* g, c-string name, int createflag ) ;
FUNCTION: Agnode_t* agfstnode ( Agraph_t* g ) ;
FUNCTION: Agnode_t* agnxtnode ( Agraph_t* g, Agnode_t* n ) ;

! Edges

FUNCTION: Agedge_t* agedge ( Agraph_t* g,
                             Agnode_t* t,
                             Agnode_t* h,
                             c-string name,
                             int createflag ) ;
FUNCTION: Agedge_t* agfstedge ( Agraph_t* g, Agnode_t* n ) ;
FUNCTION: Agedge_t* agnxtedge ( Agraph_t* g, Agedge_t* e, Agnode_t* n ) ;

! String attributes

FUNCTION: int agsafeset ( void* obj,
                          c-string name,
                          c-string value,
                          c-string default ) ;
