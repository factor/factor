! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data
alien.destructors alien.libraries alien.strings alien.syntax
combinators debugger destructors fry graphviz io
io.encodings.ascii kernel libc literals locals math memoize
prettyprint sequences specialized-arrays splitting system ;
SPECIALIZED-ARRAY: void*
IN: graphviz.ffi

<<
"libgraph" {
    { [ os macosx? ] [ "libgraph.dylib" ] }
    { [ os unix?   ] [ "libgraph.so"    ] }
    { [ os windows?  ] [ "graph.dll"      ] }
} cond cdecl add-library

"libgvc"
{
    { [ os macosx? ] [ "libgvc.dylib" ] }
    { [ os unix?   ] [ "libgvc.so"    ] }
    { [ os windows?  ] [ "gvc.dll"      ] }
} cond cdecl add-library
>>

LIBRARY: libgraph

! Types

C-TYPE: Agraph_t
C-TYPE: Agnode_t
C-TYPE: Agedge_t

! Graphs & subgraphs

FUNCTION: Agraph_t* agopen  ( c-string name, int kind ) ;
FUNCTION: Agraph_t* agsubg  ( Agraph_t* g, c-string name ) ;
FUNCTION: void      agclose ( Agraph_t* g ) ;

DESTRUCTOR: agclose

: kind ( graph -- magic-constant )
    [ directed?>> ] [ strict?>> ] bi
    [ 3 2 ? ] [ 1 0 ? ] if ;

! Nodes

FUNCTION: Agnode_t* agnode    ( Agraph_t* g, c-string name ) ;
FUNCTION: Agnode_t* agfstnode ( Agraph_t* g ) ;
FUNCTION: Agnode_t* agnxtnode ( Agraph_t* g, Agnode_t* n ) ;

<PRIVATE

: next-node ( g n -- g n' )
    [ dup ] dip agnxtnode ; inline

: (each-node) ( Agraph_t* Agnode_t* quot -- )
    '[ [ nip @ ] 2keep next-node dup ] loop 2drop ; inline

PRIVATE>

: each-node ( Agraph_t* quot -- )
    [ dup agfstnode ] dip
    over [ (each-node) ] [ 3drop ] if ; inline

! Edges

FUNCTION: Agedge_t* agedge ( Agraph_t* g,
                             Agnode_t* t,
                             Agnode_t* h ) ;

! Attributes

FUNCTION: Agnode_t* agprotonode ( Agraph_t* g ) ;
FUNCTION: Agedge_t* agprotoedge ( Agraph_t* g ) ;

FUNCTION: c-string  agget ( void* obj, c-string name ) ;

FUNCTION: int agsafeset ( void* obj,
                          c-string name,
                          c-string value,
                          c-string default ) ;


LIBRARY: libgvc

! Graphviz contexts

C-TYPE: GVC_t

FUNCTION: GVC_t* gvContext ( ) ;

<PRIVATE

FUNCTION-ALIAS: int-gvFreeContext
    int gvFreeContext ( GVC_t* gvc ) ;

PRIVATE>

ERROR: ffi-errors n ;
M: ffi-errors error.
    "Graphviz FFI indicates that " write
    n>> pprint
    " error(s) occurred while rendering." print
    "(The messages were probably printed to STDERR.)" print ;

: ?ffi-errors ( n -- )
    [ ffi-errors ] unless-zero ; inline

: gvFreeContext ( gvc -- )
    int-gvFreeContext ?ffi-errors ;

DESTRUCTOR: gvFreeContext

! Layout

FUNCTION: int gvLayout     ( GVC_t* gvc,
                             Agraph_t* g,
                             c-string engine ) ;
FUNCTION: int gvFreeLayout ( GVC_t* gvc, Agraph_t* g ) ;

! Rendering

FUNCTION: int gvRenderFilename ( GVC_t* gvc,
                                 Agraph_t* g,
                                 c-string format,
                                 c-string filename ) ;

! Supported layout engines (dot, neato, etc.) and output
! formats (png, jpg, etc.)
<PRIVATE

ENUM: api_t
API_render
API_layout
API_textlayout
API_device
API_loadimage ;

! This function doesn't exist on the Linux mason in Graphviz 2.28
FUNCTION: char**
          gvPluginList
          ( GVC_t* gvc, c-string kind, int* size, c-string str ) ;

:: Plugin-list ( kind-string -- seq )
    [
        gvContext &gvFreeContext
        kind-string
        0 int <ref> dup :> size*
        f
        gvPluginList &(free) :> ret
        size* int deref :> size
        ret size void* <c-direct-array> [
            &(free) ascii alien>string
        ] { } map-as
    ] with-destructors ;

! This function doesn't exist on the Windows mason in Graphviz 2.28
FUNCTION: c-string
          gvplugin_list
          ( GVC_t* gvc, api_t api, c-string str ) ;

: plugin-list ( API_t -- seq )
    '[
        gvContext &gvFreeContext _ "" gvplugin_list
        " " split harvest
    ] with-destructors ;

PRIVATE>

MEMO: supported-engines ( -- seq ) API_layout plugin-list ;
MEMO: supported-formats ( -- seq ) API_device plugin-list ;

