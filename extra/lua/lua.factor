! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.c-types
alien.libraries alien.syntax classes.struct combinators
io.encodings.ascii kernel math system ;
IN: lua

C-LIBRARY: liblua5.1 cdecl {
    { windows "lua5.1.dll" }
    { macos "liblua5.1.dylib" }
    { unix "liblua5.1.so" }
}

LIBRARY: liblua5.1

! luaconf.h
TYPEDEF: double LUA_NUMBER
TYPEDEF: ptrdiff_t LUA_INTEGER

CONSTANT: LUA_IDSIZE 60

! This is normally the BUFSIZ value of the given platform.
: LUAL_BUFFERSIZE ( -- x )
    {
        { [ os windows? ] [ 512 ] }
        { [ os macos? ] [ 1024 ] }
        { [ os unix? ] [ 8192 ] }
    } cond ;

! lua.h
CONSTANT: LUA_SIGNATURE B{ 27 76 117 97 }
CONSTANT: LUA_MULTRET -1

CONSTANT: LUA_REGISTRYINDEX -10000
CONSTANT: LUA_ENVIRONINDEX  -10001
CONSTANT: LUA_GLOBALSINDEX  -10002

: lua_upvalueindex ( i -- i ) [ LUA_GLOBALSINDEX ] dip - ; inline

CONSTANT: LUA_YIELD     1
CONSTANT: LUA_ERRRUN    2
CONSTANT: LUA_ERRSYNTAX 3
CONSTANT: LUA_ERRMEM    4
CONSTANT: LUA_ERRERR    5

C-TYPE: lua_State

CALLBACK: int lua_CFunction ( lua_State* L )
CALLBACK: char* lua_Reader ( lua_State* L, void* ud, size_t* sz )
CALLBACK: int lua_Writer ( lua_State* L, void* p, size_t sz, void* ud )
CALLBACK: void* lua_Alloc ( void* ud, void* ptr, size_t osize, size_t nsize )

CONSTANT: LUA_TNONE           -1
CONSTANT: LUA_TNIL            0
CONSTANT: LUA_TBOOLEAN        1
CONSTANT: LUA_TLIGHTUSERDATA  2
CONSTANT: LUA_TNUMBER         3
CONSTANT: LUA_TSTRING         4
CONSTANT: LUA_TTABLE          5
CONSTANT: LUA_TFUNCTION       6
CONSTANT: LUA_TUSERDATA       7
CONSTANT: LUA_TTHREAD         8

CONSTANT: LUA_MINSTACK 20

TYPEDEF: LUA_NUMBER lua_Number
TYPEDEF: LUA_INTEGER lua_Integer

FUNCTION: lua_State* lua_newstate ( lua_Alloc f, void* ud )
FUNCTION: void lua_close ( lua_State* L )
FUNCTION: lua_State* lua_newthread ( lua_State* L )

FUNCTION: lua_CFunction lua_atpanic ( lua_State* L, lua_CFunction panicf )

FUNCTION: int lua_gettop ( lua_State* L )
FUNCTION: void lua_settop ( lua_State* L, int idx )
FUNCTION: void lua_pushvalue ( lua_State* L, int idx )
FUNCTION: void lua_remove ( lua_State* L, int idx )
FUNCTION: void lua_insert ( lua_State* L, int idx )
FUNCTION: void lua_replace ( lua_State* L, int idx )
FUNCTION: int lua_checkstack ( lua_State* L, int sz )

FUNCTION: void lua_xmove ( lua_State* from, lua_State* to, int n )

FUNCTION: int lua_isnumber ( lua_State* L, int idx )
FUNCTION: int lua_isstring ( lua_State* L, int idx )
FUNCTION: int lua_iscfunction ( lua_State* L, int idx )
FUNCTION: int lua_isuserdata ( lua_State* L, int idx )
FUNCTION: int lua_type ( lua_State* L, int idx )
FUNCTION: c-string[ascii] lua_typename ( lua_State* L, int tp )

FUNCTION: int lua_equal ( lua_State* L, int idx1, int idx2 )
FUNCTION: int lua_rawequal ( lua_State* L, int idx1, int idx2 )
FUNCTION: int lua_lessthan ( lua_State* L, int idx1, int idx2 )

FUNCTION: lua_Number lua_tonumber ( lua_State* L, int idx )
FUNCTION: lua_Integer lua_tointeger ( lua_State* L, int idx )
FUNCTION: int lua_toboolean ( lua_State* L, int idx )
FUNCTION: c-string[ascii] lua_tolstring ( lua_State* L, int idx, size_t* len )
FUNCTION: size_t lua_objlen ( lua_State* L, int idx )
FUNCTION: lua_CFunction lua_tocfunction ( lua_State* L, int idx )
FUNCTION: void* lua_touserdata ( lua_State* L, int idx )
FUNCTION: lua_State* lua_tothread ( lua_State* L, int idx )
FUNCTION: void* lua_topointer ( lua_State* L, int idx )

FUNCTION: void lua_pushnil ( lua_State* L )
FUNCTION: void lua_pushnumber ( lua_State* L, lua_Number n )
FUNCTION: void lua_pushinteger ( lua_State* L, lua_Integer n )
FUNCTION: void lua_pushlstring ( lua_State* L, char* s, size_t l )
FUNCTION: void lua_pushstring ( lua_State* L, c-string[ascii] s )
! FUNCTION: c-string[ascii] lua_pushvfstring ( lua_State* L, c-string[ascii] fmt, va_list argp )
! FUNCTION: c-string[ascii] lua_pushfstring ( lua_State* L, c-string[ascii] fmt, ... )
FUNCTION: void lua_pushcclosure ( lua_State* L, lua_CFunction fn, int n )
FUNCTION: void lua_pushboolean ( lua_State* L, int b )
FUNCTION: void lua_pushlightuserdata ( lua_State* L, void* p )
FUNCTION: int lua_pushthread ( lua_State* L )

FUNCTION: void lua_gettable ( lua_State* L, int idx )
FUNCTION: void lua_getfield ( lua_State* L, int idx, c-string[ascii] k )
FUNCTION: void lua_rawget ( lua_State* L, int idx )
FUNCTION: void lua_rawgeti ( lua_State* L, int idx, int n )
FUNCTION: void lua_createtable ( lua_State* L, int narr, int nrec )
FUNCTION: void* lua_newuserdata ( lua_State* L, size_t sz )
FUNCTION: int lua_getmetatable ( lua_State* L, int objindex )
FUNCTION: void lua_getfenv ( lua_State* L, int idx )

FUNCTION: void lua_settable ( lua_State* L, int idx )
FUNCTION: void lua_setfield ( lua_State* L, int idx, c-string[ascii] k )
FUNCTION: void lua_rawset ( lua_State* L, int idx )
FUNCTION: void lua_rawseti ( lua_State* L, int idx, int n )
FUNCTION: int lua_setmetatable ( lua_State* L, int objindex )
FUNCTION: int lua_setfenv ( lua_State* L, int idx )

FUNCTION: void lua_call ( lua_State* L, int nargs, int nresults )
FUNCTION: int lua_pcall ( lua_State* L, int nargs, int nresults, int errfunc )
FUNCTION: int lua_cpcall ( lua_State* L, lua_CFunction func, void* ud )
FUNCTION: int lua_load ( lua_State* L, lua_Reader reader, void* dt, c-string[ascii] chunkname )

FUNCTION: int lua_dump ( lua_State* L, lua_Writer writer, void* data )

FUNCTION: int lua_yield ( lua_State* L, int nresults )
FUNCTION: int lua_resume ( lua_State* L, int narg )
FUNCTION: int lua_status ( lua_State* L )

CONSTANT: LUA_GCSTOP          0
CONSTANT: LUA_GCRESTART       1
CONSTANT: LUA_GCCOLLECT       2
CONSTANT: LUA_GCCOUNT         3
CONSTANT: LUA_GCCOUNTB        4
CONSTANT: LUA_GCSTEP          5
CONSTANT: LUA_GCSETPAUSE      6
CONSTANT: LUA_GCSETSTEPMUL    7

FUNCTION: int lua_gc ( lua_State* L, int what, int data )

FUNCTION: int lua_error ( lua_State* L )
FUNCTION: int lua_next ( lua_State* L, int idx )
FUNCTION: void lua_concat ( lua_State* L, int n )
FUNCTION: lua_Alloc lua_getallocf ( lua_State* L, void* *ud )
FUNCTION: void lua_setallocf ( lua_State* L, lua_Alloc f, void* ud )

TYPEDEF: lua_Reader lua_Chunkreader
TYPEDEF: lua_Writer lua_Chunkwriter

FUNCTION: void lua_setlevel ( lua_State* from, lua_State* to )

CONSTANT: LUA_HOOKCALL    0
CONSTANT: LUA_HOOKRET     1
CONSTANT: LUA_HOOKLINE    2
CONSTANT: LUA_HOOKCOUNT   3
CONSTANT: LUA_HOOKTAILRET 4

: LUA_MASKCALL ( n -- n ) LUA_HOOKCALL shift ; inline
: LUA_MASKRET ( n -- n ) LUA_HOOKRET shift ; inline
: LUA_MASKLINE ( n -- n ) LUA_HOOKLINE shift ; inline
: LUA_MASKCOUNT ( n -- n ) LUA_HOOKCOUNT shift ; inline

C-TYPE: lua_Debug
CALLBACK: void lua_Hook ( lua_State* L, lua_Debug* ar )

FUNCTION: int lua_getstack ( lua_State* L, int level, lua_Debug* ar )
FUNCTION: int lua_getinfo ( lua_State* L, c-string[ascii] what, lua_Debug* ar )
FUNCTION: c-string[ascii] lua_getlocal ( lua_State* L, lua_Debug* ar, int n )
FUNCTION: c-string[ascii] lua_setlocal ( lua_State* L, lua_Debug* ar, int n )
FUNCTION: c-string[ascii] lua_getupvalue ( lua_State* L, int funcindex, int n )
FUNCTION: c-string[ascii] lua_setupvalue ( lua_State* L, int funcindex, int n )

FUNCTION: int lua_sethook ( lua_State* L, lua_Hook func, int mask, int count )
FUNCTION: lua_Hook lua_gethook ( lua_State* L )
FUNCTION: int lua_gethookmask ( lua_State* L )
FUNCTION: int lua_gethookcount ( lua_State* L )

STRUCT: lua_Debug
    { event           int              }
    { name            char*            }
    { namewhat        char*            }
    { what            char*            }
    { source          char*            }
    { currentline     int              }
    { nups            int              }
    { linedefined     int              }
    { lastlinedefined int              }
    { short_src       char[LUA_IDSIZE] }
    { i_ci            int              } ;

! lauxlib.h

: luaL_getn ( L i -- int ) lua_objlen ; inline
: luaL_setn ( L i j -- ) 3drop ; inline

: LUA_ERRFILE ( -- x ) LUA_ERRERR 1 + ;

STRUCT: luaL_Reg
    { name char*         }
    { func lua_CFunction } ;

FUNCTION: void luaI_openlib ( lua_State* L, c-string[ascii] libname, luaL_Reg* l, int nup )
FUNCTION: void luaL_register ( lua_State* L, c-string[ascii] libname, luaL_Reg* l )
FUNCTION: int luaL_getmetafield ( lua_State* L, int obj, c-string[ascii] e )
FUNCTION: int luaL_callmeta ( lua_State* L, int obj, c-string[ascii] e )
FUNCTION: int luaL_typerror ( lua_State* L, int narg, c-string[ascii] tname )
FUNCTION: int luaL_argerror ( lua_State* L, int numarg, c-string[ascii] extramsg )
FUNCTION: c-string[ascii] luaL_checklstring ( lua_State* L, int numArg, size_t* l )
FUNCTION: c-string[ascii] luaL_optlstring ( lua_State* L, int numArg, c-string[ascii] def, size_t* l )
FUNCTION: lua_Number luaL_checknumber ( lua_State* L, int numArg )
FUNCTION: lua_Number luaL_optnumber ( lua_State* L, int nArg, lua_Number def )

FUNCTION: lua_Integer luaL_checkinteger ( lua_State* L, int numArg )
FUNCTION: lua_Integer luaL_optinteger ( lua_State* L, int nArg, lua_Integer def )

FUNCTION: void luaL_checkstack ( lua_State* L, int sz, c-string[ascii] msg )
FUNCTION: void luaL_checktype ( lua_State* L, int narg, int t )
FUNCTION: void luaL_checkany ( lua_State* L, int narg )

FUNCTION: int luaL_newmetatable ( lua_State* L, c-string[ascii] tname )
FUNCTION: void* luaL_checkudata ( lua_State* L, int ud, c-string[ascii] tname )

FUNCTION: void luaL_where ( lua_State* L, int lvl )
! FUNCTION: int luaL_error ( lua_State* L, c-string[ascii] fmt,  ... ) ;
FUNCTION: int luaL_checkoption ( lua_State* L, int narg, c-string[ascii] def, c-string[ascii] lst )

FUNCTION: int luaL_ref ( lua_State* L, int t )
FUNCTION: void luaL_unref ( lua_State* L, int t, int ref )

FUNCTION: int luaL_loadfile ( lua_State* L, c-string[ascii] filename )
FUNCTION: int luaL_loadbuffer ( lua_State* L, c-string[ascii] buff, size_t sz, c-string[ascii] name )
FUNCTION: int luaL_loadstring ( lua_State* L, c-string[ascii] s )

FUNCTION: lua_State* luaL_newstate ( )
FUNCTION: c-string[ascii] luaL_gsub ( lua_State* L, c-string[ascii] s, c-string[ascii] p, c-string[ascii] r )
FUNCTION: c-string[ascii] luaL_findtable ( lua_State* L, int idx, c-string[ascii] fname, int szhint )

: lua_pop ( L n -- ) neg 1 - lua_settop ; inline
: lua_newtable ( L -- ) 0 0 lua_createtable ; inline
: lua_pushcfunction ( L f -- ) 0 lua_pushcclosure ; inline
: lua_setglobal ( L s -- ) [ LUA_GLOBALSINDEX ] dip lua_setfield ; inline
: lua_register ( L n f -- ) pick swap lua_pushcfunction lua_setglobal ; inline
: lua_strlen ( L i -- size_t ) lua_objlen ; inline
: lua_isfunction ( L n -- ? ) lua_type LUA_TFUNCTION = ; inline
: lua_istable ( L n -- ? ) lua_type LUA_TTABLE = ; inline
: lua_islightuserdata ( L n -- ? ) lua_type LUA_TLIGHTUSERDATA = ; inline
: lua_isnil ( L n -- ? ) lua_type LUA_TNIL = ; inline
: lua_isboolean ( L n -- ? ) lua_type LUA_TBOOLEAN = ; inline
: lua_isthread ( L n -- ? ) lua_type LUA_TTHREAD = ; inline
: lua_isnone ( L n -- ? ) lua_type LUA_TNONE = ; inline
: lua_isnoneornil ( L n -- ? ) lua_type 0 <= ; inline
: lua_getglobal ( L s -- ) [ LUA_GLOBALSINDEX ] dip lua_getfield ; inline
: lua_tostring ( L i -- string ) f lua_tolstring ; inline
: lua_open ( -- lua_State* ) luaL_newstate ; inline
: lua_getregistry ( L -- ) LUA_REGISTRYINDEX lua_pushvalue ; inline
: lua_getgccount ( L -- int ) LUA_GCCOUNT 0 lua_gc ; inline

: luaL_argcheck ( L cond numarg extramsg -- int ) rot 0 = [ luaL_argerror ] [ 3drop 1 ] if ; inline
: luaL_checkstring ( L n -- string ) f luaL_checklstring ; inline
: luaL_optstring ( L n d -- string ) f luaL_optlstring ; inline
: luaL_checkint ( L n -- int ) luaL_checkinteger ; inline
: luaL_optint ( L  n d -- int ) luaL_optinteger ; inline
: luaL_checklong ( L n -- long ) luaL_checkinteger ; inline
: luaL_optlong ( L n d -- long ) luaL_optinteger ; inline

: luaL_typename ( L i -- string ) dupd lua_type lua_typename ; inline
: luaL_dofile ( L fn -- int )
    dupd luaL_loadfile 0 = [
        0 LUA_MULTRET 0 lua_pcall
    ] [ drop 1 ] if ; inline
: luaL_dostring ( L s -- int )
    dupd luaL_loadstring 0 = [
        0 LUA_MULTRET 0 lua_pcall
    ] [ drop 1 ] if ; inline

: luaL_getmetatable ( L n -- ) [ LUA_REGISTRYINDEX ] dip lua_getfield ; inline

STRUCT: luaL_Buffer
    { p      char*                 }
    { lvl    int                   }
    { L      lua_State*            }
    { buffer char[LUAL_BUFFERSIZE] } ;

FUNCTION: void luaL_buffinit ( lua_State* L, luaL_Buffer* B )
FUNCTION: char* luaL_prepbuffer ( luaL_Buffer* B )
FUNCTION: void luaL_addlstring ( luaL_Buffer* B, char* s, size_t l )
FUNCTION: void luaL_addstring ( luaL_Buffer* B, char* s )
FUNCTION: void luaL_addvalue ( luaL_Buffer* B )
FUNCTION: void luaL_pushresult ( luaL_Buffer* B )

:: luaL_addchar ( B c -- )
    B p>> alien-address
    LUAL_BUFFERSIZE B buffer>> <displaced-alien> alien-address
    >= [ B luaL_prepbuffer drop ] when
    c B p>> 0 set-alien-signed-1
    B [ 1 swap <displaced-alien> ] change-p drop ; inline

: luaL_putchar ( B c -- ) luaL_addchar ; inline
: luaL_addsize ( B n -- ) [ swap <displaced-alien> ] curry change-p drop ; inline
