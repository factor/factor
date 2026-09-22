! Copyright (C) 2010 Erik Charlebois.
! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Lua 5.5, with the default double / 64-bit integer configuration.
USING: accessors alien alien.accessors alien.c-types
alien.libraries alien.syntax alien.varargs
classes.struct kernel locals math system ;
IN: lua

C-LIBRARY: liblua5.5 {
    { windows "lua55.dll" }
    { macos "liblua5.5.dylib" }
    { linux "liblua5.5.so.0" }
    { unix "liblua-5.5.so" }
}

LIBRARY: liblua5.5

TYPEDEF: double LUA_NUMBER
TYPEDEF: longlong LUA_INTEGER
TYPEDEF: ulonglong LUA_UNSIGNED
TYPEDEF: LUA_NUMBER lua_Number
TYPEDEF: LUA_INTEGER lua_Integer
TYPEDEF: LUA_UNSIGNED lua_Unsigned
TYPEDEF: intptr_t lua_KContext

CONSTANT: LUA_VERSION_NUM 505
CONSTANT: LUA_VERSION "Lua 5.5"
CONSTANT: LUA_IDSIZE 60
CONSTANT: LUA_SIGNATURE B{ 27 76 117 97 }
CONSTANT: LUA_MULTRET -1
CONSTANT: LUA_REGISTRYINDEX -1073742823
CONSTANT: LUA_ERRFILE 6
CONSTANT: LUA_NOREF -2
CONSTANT: LUA_REFNIL -1
CONSTANT: LUA_GNAME "_G"
CONSTANT: LUA_LOADED_TABLE "_LOADED"
CONSTANT: LUA_PRELOAD_TABLE "_PRELOAD"
CONSTANT: LUA_FILEHANDLE "FILE*"
CONSTANT: LUA_MASKCALL 1
CONSTANT: LUA_MASKRET 2
CONSTANT: LUA_MASKLINE 4
CONSTANT: LUA_MASKCOUNT 8
CONSTANT: LUA_GLIBK 1
CONSTANT: LUA_LOADLIBK 2
CONSTANT: LUA_COLIBK 4
CONSTANT: LUA_DBLIBK 8
CONSTANT: LUA_IOLIBK 16
CONSTANT: LUA_MATHLIBK 32
CONSTANT: LUA_OSLIBK 64
CONSTANT: LUA_STRLIBK 128
CONSTANT: LUA_TABLIBK 256
CONSTANT: LUA_UTF8LIBK 512
CONSTANT: LUA_LOADLIBNAME "package"
CONSTANT: LUA_COLIBNAME "coroutine"
CONSTANT: LUA_DBLIBNAME "debug"
CONSTANT: LUA_IOLIBNAME "io"
CONSTANT: LUA_MATHLIBNAME "math"
CONSTANT: LUA_OSLIBNAME "os"
CONSTANT: LUA_STRLIBNAME "string"
CONSTANT: LUA_TABLIBNAME "table"
CONSTANT: LUA_UTF8LIBNAME "utf8"

: LUA_EXTRASPACE ( -- n ) void* heap-size ; inline
: LUAL_BUFFERSIZE ( -- n ) 16 void* heap-size * \ lua_Number heap-size * ; inline
: LUAL_NUMSIZES ( -- n ) \ lua_Integer heap-size 16 * \ lua_Number heap-size + ; inline

C-TYPE: lua_State
C-TYPE: lua_Debug
C-TYPE: luaL_Buffer
CALLBACK: int lua_CFunction ( lua_State* L )
CALLBACK: int lua_KFunction ( lua_State* L, int status, lua_KContext ctx )
CALLBACK: char* lua_Reader ( lua_State* L, void* ud, size_t* sz )
CALLBACK: int lua_Writer ( lua_State* L, void* p, size_t sz, void* ud )
CALLBACK: void* lua_Alloc ( void* ud, void* ptr, size_t osize, size_t nsize )
CALLBACK: void lua_WarnFunction ( void* ud, c-string msg, int tocont )
CALLBACK: void lua_Hook ( lua_State* L, lua_Debug* ar )

STRUCT: luaL_Reg { name char* } { func lua_CFunction } ;

CONSTANT: LUA_OK 0
CONSTANT: LUA_YIELD 1
CONSTANT: LUA_ERRRUN 2
CONSTANT: LUA_ERRSYNTAX 3
CONSTANT: LUA_ERRMEM 4
CONSTANT: LUA_ERRERR 5
CONSTANT: LUA_TNIL 0
CONSTANT: LUA_TBOOLEAN 1
CONSTANT: LUA_TLIGHTUSERDATA 2
CONSTANT: LUA_TNUMBER 3
CONSTANT: LUA_TSTRING 4
CONSTANT: LUA_TTABLE 5
CONSTANT: LUA_TFUNCTION 6
CONSTANT: LUA_TUSERDATA 7
CONSTANT: LUA_TTHREAD 8
CONSTANT: LUA_NUMTYPES 9
CONSTANT: LUA_MINSTACK 20
CONSTANT: LUA_RIDX_GLOBALS 2
CONSTANT: LUA_RIDX_MAINTHREAD 3
CONSTANT: LUA_RIDX_LAST 3
CONSTANT: LUA_OPADD 0
CONSTANT: LUA_OPSUB 1
CONSTANT: LUA_OPMUL 2
CONSTANT: LUA_OPMOD 3
CONSTANT: LUA_OPPOW 4
CONSTANT: LUA_OPDIV 5
CONSTANT: LUA_OPIDIV 6
CONSTANT: LUA_OPBAND 7
CONSTANT: LUA_OPBOR 8
CONSTANT: LUA_OPBXOR 9
CONSTANT: LUA_OPSHL 10
CONSTANT: LUA_OPSHR 11
CONSTANT: LUA_OPUNM 12
CONSTANT: LUA_OPBNOT 13
CONSTANT: LUA_OPEQ 0
CONSTANT: LUA_OPLT 1
CONSTANT: LUA_OPLE 2
CONSTANT: LUA_GCSTOP 0
CONSTANT: LUA_GCRESTART 1
CONSTANT: LUA_GCCOLLECT 2
CONSTANT: LUA_GCCOUNT 3
CONSTANT: LUA_GCCOUNTB 4
CONSTANT: LUA_GCSTEP 5
CONSTANT: LUA_GCISRUNNING 6
CONSTANT: LUA_GCGEN 7
CONSTANT: LUA_GCINC 8
CONSTANT: LUA_GCPARAM 9
CONSTANT: LUA_GCPMINORMUL 0
CONSTANT: LUA_GCPMAJORMINOR 1
CONSTANT: LUA_GCPMINORMAJOR 2
CONSTANT: LUA_GCPPAUSE 3
CONSTANT: LUA_GCPSTEPMUL 4
CONSTANT: LUA_GCPSTEPSIZE 5
CONSTANT: LUA_GCPN 6
CONSTANT: LUA_N2SBUFFSZ 64
CONSTANT: LUA_HOOKCALL 0
CONSTANT: LUA_HOOKRET 1
CONSTANT: LUA_HOOKLINE 2
CONSTANT: LUA_HOOKCOUNT 3
CONSTANT: LUA_HOOKTAILCALL 4
CONSTANT: LUA_TNONE -1

FUNCTION: lua_State* lua_newstate ( lua_Alloc f, void* ud, uint seed )
FUNCTION: void lua_close ( lua_State* L )
FUNCTION: lua_State* lua_newthread ( lua_State* L )
FUNCTION: int lua_closethread ( lua_State* L, lua_State* from )
FUNCTION: lua_CFunction lua_atpanic ( lua_State* L, lua_CFunction panicf )
FUNCTION: lua_Number lua_version ( lua_State* L )
FUNCTION: int lua_absindex ( lua_State* L, int idx )
FUNCTION: int lua_gettop ( lua_State* L )
FUNCTION: void lua_settop ( lua_State* L, int idx )
FUNCTION: void lua_pushvalue ( lua_State* L, int idx )
FUNCTION: void lua_rotate ( lua_State* L, int idx, int n )
FUNCTION: void lua_copy ( lua_State* L, int fromidx, int toidx )
FUNCTION: int lua_checkstack ( lua_State* L, int n )
FUNCTION: void lua_xmove ( lua_State* from, lua_State* to, int n )
FUNCTION: int lua_isnumber ( lua_State* L, int idx )
FUNCTION: int lua_isstring ( lua_State* L, int idx )
FUNCTION: int lua_iscfunction ( lua_State* L, int idx )
FUNCTION: int lua_isinteger ( lua_State* L, int idx )
FUNCTION: int lua_isuserdata ( lua_State* L, int idx )
FUNCTION: int lua_type ( lua_State* L, int idx )
FUNCTION: c-string lua_typename ( lua_State* L, int tp )
FUNCTION: lua_Number lua_tonumberx ( lua_State* L, int idx, int* isnum )
FUNCTION: lua_Integer lua_tointegerx ( lua_State* L, int idx, int* isnum )
FUNCTION: int lua_toboolean ( lua_State* L, int idx )
FUNCTION: c-string lua_tolstring ( lua_State* L, int idx, size_t* len )
FUNCTION: lua_Unsigned lua_rawlen ( lua_State* L, int idx )
FUNCTION: lua_CFunction lua_tocfunction ( lua_State* L, int idx )
FUNCTION: void* lua_touserdata ( lua_State* L, int idx )
FUNCTION: lua_State* lua_tothread ( lua_State* L, int idx )
FUNCTION: void* lua_topointer ( lua_State* L, int idx )
FUNCTION: void lua_arith ( lua_State* L, int op )
FUNCTION: int lua_rawequal ( lua_State* L, int idx1, int idx2 )
FUNCTION: int lua_compare ( lua_State* L, int idx1, int idx2, int op )
FUNCTION: void lua_pushnil ( lua_State* L )
FUNCTION: void lua_pushnumber ( lua_State* L, lua_Number n )
FUNCTION: void lua_pushinteger ( lua_State* L, lua_Integer n )
FUNCTION: char* lua_pushlstring ( lua_State* L, char* s, size_t len )
FUNCTION: char* lua_pushexternalstring ( lua_State* L, char* s, size_t len, lua_Alloc falloc, void* ud )
FUNCTION: c-string lua_pushstring ( lua_State* L, c-string s )
FUNCTION: c-string lua_pushvfstring ( lua_State* L, c-string fmt, va_list argp )
FUNCTION: c-string lua_pushfstring ( lua_State* L, c-string fmt, ... )
FUNCTION: void lua_pushcclosure ( lua_State* L, lua_CFunction fn, int n )
FUNCTION: void lua_pushboolean ( lua_State* L, int b )
FUNCTION: void lua_pushlightuserdata ( lua_State* L, void* p )
FUNCTION: int lua_pushthread ( lua_State* L )
FUNCTION: int lua_getglobal ( lua_State* L, c-string name )
FUNCTION: int lua_gettable ( lua_State* L, int idx )
FUNCTION: int lua_getfield ( lua_State* L, int idx, c-string k )
FUNCTION: int lua_geti ( lua_State* L, int idx, lua_Integer n )
FUNCTION: int lua_rawget ( lua_State* L, int idx )
FUNCTION: int lua_rawgeti ( lua_State* L, int idx, lua_Integer n )
FUNCTION: int lua_rawgetp ( lua_State* L, int idx, void* p )
FUNCTION: void lua_createtable ( lua_State* L, int narr, int nrec )
FUNCTION: void* lua_newuserdatauv ( lua_State* L, size_t sz, int nuvalue )
FUNCTION: int lua_getmetatable ( lua_State* L, int objindex )
FUNCTION: int lua_getiuservalue ( lua_State* L, int idx, int n )
FUNCTION: void lua_setglobal ( lua_State* L, c-string name )
FUNCTION: void lua_settable ( lua_State* L, int idx )
FUNCTION: void lua_setfield ( lua_State* L, int idx, c-string k )
FUNCTION: void lua_seti ( lua_State* L, int idx, lua_Integer n )
FUNCTION: void lua_rawset ( lua_State* L, int idx )
FUNCTION: void lua_rawseti ( lua_State* L, int idx, lua_Integer n )
FUNCTION: void lua_rawsetp ( lua_State* L, int idx, void* p )
FUNCTION: int lua_setmetatable ( lua_State* L, int objindex )
FUNCTION: int lua_setiuservalue ( lua_State* L, int idx, int n )
FUNCTION: void lua_callk ( lua_State* L, int nargs, int nresults, lua_KContext ctx, lua_KFunction k )
FUNCTION: int lua_pcallk ( lua_State* L, int nargs, int nresults, int errfunc, lua_KContext ctx, lua_KFunction k )
FUNCTION: int lua_load ( lua_State* L, lua_Reader reader, void* dt, c-string chunkname, c-string mode )
FUNCTION: int lua_dump ( lua_State* L, lua_Writer writer, void* data, int strip )
FUNCTION: int lua_yieldk ( lua_State* L, int nresults, lua_KContext ctx, lua_KFunction k )
FUNCTION: int lua_resume ( lua_State* L, lua_State* from, int narg, int* nres )
FUNCTION: int lua_status ( lua_State* L )
FUNCTION: int lua_isyieldable ( lua_State* L )
FUNCTION: void lua_setwarnf ( lua_State* L, lua_WarnFunction f, void* ud )
FUNCTION: void lua_warning ( lua_State* L, c-string msg, int tocont )
FUNCTION: int lua_gc ( lua_State* L, int what, ... )
FUNCTION: int lua_error ( lua_State* L )
FUNCTION: int lua_next ( lua_State* L, int idx )
FUNCTION: void lua_concat ( lua_State* L, int n )
FUNCTION: void lua_len ( lua_State* L, int idx )
FUNCTION: uint lua_numbertocstring ( lua_State* L, int idx, char* buff )
FUNCTION: size_t lua_stringtonumber ( lua_State* L, c-string s )
FUNCTION: lua_Alloc lua_getallocf ( lua_State* L, void** ud )
FUNCTION: void lua_setallocf ( lua_State* L, lua_Alloc f, void* ud )
FUNCTION: void lua_toclose ( lua_State* L, int idx )
FUNCTION: void lua_closeslot ( lua_State* L, int idx )
FUNCTION: int lua_getstack ( lua_State* L, int level, lua_Debug* ar )
FUNCTION: int lua_getinfo ( lua_State* L, c-string what, lua_Debug* ar )
FUNCTION: c-string lua_getlocal ( lua_State* L, lua_Debug* ar, int n )
FUNCTION: c-string lua_setlocal ( lua_State* L, lua_Debug* ar, int n )
FUNCTION: c-string lua_getupvalue ( lua_State* L, int funcindex, int n )
FUNCTION: c-string lua_setupvalue ( lua_State* L, int funcindex, int n )
FUNCTION: void* lua_upvalueid ( lua_State* L, int fidx, int n )
FUNCTION: void lua_upvaluejoin ( lua_State* L, int fidx1, int n1, int fidx2, int n2 )
FUNCTION: void lua_sethook ( lua_State* L, lua_Hook func, int mask, int count )
FUNCTION: lua_Hook lua_gethook ( lua_State* L )
FUNCTION: int lua_gethookmask ( lua_State* L )
FUNCTION: int lua_gethookcount ( lua_State* L )
FUNCTION: void luaL_checkversion_ ( lua_State* L, lua_Number ver, size_t sz )
FUNCTION: int luaL_getmetafield ( lua_State* L, int obj, c-string e )
FUNCTION: int luaL_callmeta ( lua_State* L, int obj, c-string e )
FUNCTION: c-string luaL_tolstring ( lua_State* L, int idx, size_t* len )
FUNCTION: int luaL_argerror ( lua_State* L, int arg, c-string extramsg )
FUNCTION: int luaL_typeerror ( lua_State* L, int arg, c-string tname )
FUNCTION: c-string luaL_checklstring ( lua_State* L, int arg, size_t* l )
FUNCTION: c-string luaL_optlstring ( lua_State* L, int arg, c-string def, size_t* l )
FUNCTION: lua_Number luaL_checknumber ( lua_State* L, int arg )
FUNCTION: lua_Number luaL_optnumber ( lua_State* L, int arg, lua_Number def )
FUNCTION: lua_Integer luaL_checkinteger ( lua_State* L, int arg )
FUNCTION: lua_Integer luaL_optinteger ( lua_State* L, int arg, lua_Integer def )
FUNCTION: void luaL_checkstack ( lua_State* L, int sz, c-string msg )
FUNCTION: void luaL_checktype ( lua_State* L, int arg, int t )
FUNCTION: void luaL_checkany ( lua_State* L, int arg )
FUNCTION: int luaL_newmetatable ( lua_State* L, c-string tname )
FUNCTION: void luaL_setmetatable ( lua_State* L, c-string tname )
FUNCTION: void* luaL_testudata ( lua_State* L, int ud, c-string tname )
FUNCTION: void* luaL_checkudata ( lua_State* L, int ud, c-string tname )
FUNCTION: void luaL_where ( lua_State* L, int lvl )
FUNCTION: int luaL_error ( lua_State* L, c-string fmt, ... )
FUNCTION: int luaL_checkoption ( lua_State* L, int arg, c-string def, char** lst )
FUNCTION: int luaL_fileresult ( lua_State* L, int stat, c-string fname )
FUNCTION: int luaL_execresult ( lua_State* L, int stat )
FUNCTION: void* luaL_alloc ( void* ud, void* ptr, size_t osize, size_t nsize )
FUNCTION: int luaL_ref ( lua_State* L, int t )
FUNCTION: void luaL_unref ( lua_State* L, int t, int ref )
FUNCTION: int luaL_loadfilex ( lua_State* L, c-string filename, c-string mode )
FUNCTION: int luaL_loadbufferx ( lua_State* L, char* buff, size_t sz, c-string name, c-string mode )
FUNCTION: int luaL_loadstring ( lua_State* L, c-string s )
FUNCTION: lua_State* luaL_newstate (  )
FUNCTION: uint luaL_makeseed ( lua_State* L )
FUNCTION: lua_Integer luaL_len ( lua_State* L, int idx )
FUNCTION: void luaL_addgsub ( luaL_Buffer* b, c-string s, c-string p, c-string r )
FUNCTION: c-string luaL_gsub ( lua_State* L, c-string s, c-string p, c-string r )
FUNCTION: void luaL_setfuncs ( lua_State* L, luaL_Reg* l, int nup )
FUNCTION: int luaL_getsubtable ( lua_State* L, int idx, c-string fname )
FUNCTION: void luaL_traceback ( lua_State* L, lua_State* L1, c-string msg, int level )
FUNCTION: void luaL_requiref ( lua_State* L, c-string modname, lua_CFunction openf, int glb )
FUNCTION: void luaL_buffinit ( lua_State* L, luaL_Buffer* B )
FUNCTION: char* luaL_prepbuffsize ( luaL_Buffer* B, size_t sz )
FUNCTION: void luaL_addlstring ( luaL_Buffer* B, char* s, size_t l )
FUNCTION: void luaL_addstring ( luaL_Buffer* B, c-string s )
FUNCTION: void luaL_addvalue ( luaL_Buffer* B )
FUNCTION: void luaL_pushresult ( luaL_Buffer* B )
FUNCTION: void luaL_pushresultsize ( luaL_Buffer* B, size_t sz )
FUNCTION: char* luaL_buffinitsize ( lua_State* L, luaL_Buffer* B, size_t sz )
FUNCTION: int luaopen_base ( lua_State* L )
FUNCTION: int luaopen_package ( lua_State* L )
FUNCTION: int luaopen_coroutine ( lua_State* L )
FUNCTION: int luaopen_debug ( lua_State* L )
FUNCTION: int luaopen_io ( lua_State* L )
FUNCTION: int luaopen_math ( lua_State* L )
FUNCTION: int luaopen_os ( lua_State* L )
FUNCTION: int luaopen_string ( lua_State* L )
FUNCTION: int luaopen_table ( lua_State* L )
FUNCTION: int luaopen_utf8 ( lua_State* L )
FUNCTION: void luaL_openselectedlibs ( lua_State* L, int load, int preload )

! Byte-preserving access; the returned pointer is borrowed from the Lua state.
FUNCTION-ALIAS: lua_tolstring-raw char* lua_tolstring ( lua_State* L, int idx, size_t* len )
FUNCTION-ALIAS: luaL_checklstring-raw char* luaL_checklstring ( lua_State* L, int arg, size_t* len )
FUNCTION-ALIAS: luaL_optlstring-raw char* luaL_optlstring ( lua_State* L, int arg, char* def, size_t* len )
FUNCTION-ALIAS: luaL_tolstring-raw char* luaL_tolstring ( lua_State* L, int idx, size_t* len )

STRUCT: lua_Debug
    { event int }
    { name char* } { namewhat char* } { what char* } { source char* }
    { srclen size_t }
    { currentline int } { linedefined int } { lastlinedefined int }
    { nups uchar } { nparams uchar } { isvararg char }
    { extraargs uchar } { istailcall char }
    { ftransfer int } { ntransfer int }
    { short_src char[LUA_IDSIZE] }
    { i_ci void* } ;

! Storage-only stand-in for LUAI_MAXALIGN's long double member. The union's
! payload is the byte buffer; no long double value crosses the Factor FFI.
SYMBOL: luaL_Alignment
<<
    ulonglong lookup-c-type clone
    os windows? os macos? cpu arm.64? and or [ 8 ] [
        cpu x86.32? os macos? not and [ 4 ] [ 16 ] if
    ] if dup [ >>align ] dip >>align-first
    \ luaL_Alignment typedef
>>
UNION-STRUCT: luaL_BufferInit
    { alignment luaL_Alignment }
    { b char[LUAL_BUFFERSIZE] } ;
STRUCT: luaL_Buffer
    { b char* } { size size_t } { n size_t } { L lua_State* }
    { init luaL_BufferInit } ;
STRUCT: luaL_Stream { f void* } { closef lua_CFunction } ;

! Function-like macros from lua.h and lauxlib.h.
: lua_upvalueindex ( i -- i ) LUA_REGISTRYINDEX swap - ; inline
: lua_getextraspace ( L -- pointer ) LUA_EXTRASPACE neg swap <displaced-alien> ; inline
: lua_tonumber ( L idx -- n ) f lua_tonumberx ; inline
: lua_tointeger ( L idx -- n ) f lua_tointegerx ; inline
: lua_pop ( L n -- ) neg 1 - lua_settop ; inline
: lua_newtable ( L -- ) 0 0 lua_createtable ; inline
: lua_pushcfunction ( L fn -- ) 0 lua_pushcclosure ; inline
: lua_register ( L name fn -- ) pick swap lua_pushcfunction lua_setglobal ; inline
: lua_call ( L nargs nresults -- ) 0 f lua_callk ; inline
: lua_pcall ( L nargs nresults errfunc -- status ) 0 f lua_pcallk ; inline
: lua_yield ( L nresults -- status ) 0 f lua_yieldk ; inline
: lua_isfunction ( L idx -- ? ) lua_type LUA_TFUNCTION = ; inline
: lua_istable ( L idx -- ? ) lua_type LUA_TTABLE = ; inline
: lua_islightuserdata ( L idx -- ? ) lua_type LUA_TLIGHTUSERDATA = ; inline
: lua_isnil ( L idx -- ? ) lua_type LUA_TNIL = ; inline
: lua_isboolean ( L idx -- ? ) lua_type LUA_TBOOLEAN = ; inline
: lua_isthread ( L idx -- ? ) lua_type LUA_TTHREAD = ; inline
: lua_isnone ( L idx -- ? ) lua_type LUA_TNONE = ; inline
: lua_isnoneornil ( L idx -- ? ) lua_type 0 <= ; inline
: lua_pushglobaltable ( L -- ) LUA_REGISTRYINDEX LUA_RIDX_GLOBALS lua_rawgeti drop ; inline
: lua_tostring ( L idx -- string ) f lua_tolstring ; inline
: lua_insert ( L idx -- ) 1 lua_rotate ; inline
:: lua_remove ( L idx -- ) L idx -1 lua_rotate L 1 lua_pop ; inline
:: lua_replace ( L idx -- ) L -1 idx lua_copy L 1 lua_pop ; inline
: lua_newuserdata ( L size -- pointer ) 1 lua_newuserdatauv ; inline
: lua_getuservalue ( L idx -- type ) 1 lua_getiuservalue ; inline
: lua_setuservalue ( L idx -- ? ) 1 lua_setiuservalue ; inline
: lua_resetthread ( L -- status ) f lua_closethread ; inline
: luaL_checkversion ( L -- ) LUA_VERSION_NUM >float LUAL_NUMSIZES luaL_checkversion_ ; inline
: luaL_loadfile ( L filename -- status ) f luaL_loadfilex ; inline
: luaL_loadbuffer ( L buffer size name -- status ) f luaL_loadbufferx ; inline
: luaL_checkstring ( L arg -- string ) f luaL_checklstring ; inline
: luaL_optstring ( L arg def -- string ) f luaL_optlstring ; inline
: luaL_typename ( L idx -- string ) dupd lua_type lua_typename ; inline
: luaL_getmetatable ( L name -- type ) [ LUA_REGISTRYINDEX ] dip lua_getfield ; inline
: luaL_dofile ( L filename -- status )
    dupd luaL_loadfile dup LUA_OK = [ drop 0 LUA_MULTRET 0 lua_pcall ] [ nip ] if ; inline
: luaL_dostring ( L source -- status )
    dupd luaL_loadstring dup LUA_OK = [ drop 0 LUA_MULTRET 0 lua_pcall ] [ nip ] if ; inline
: luaL_argcheck ( L cond arg message -- )
    rot 0 = [ luaL_argerror drop ] [ 3drop ] if ; inline
: luaL_openlibs ( L -- ) -1 0 luaL_openselectedlibs ; inline
: luaL_bufflen ( B -- n ) n>> ; inline
: luaL_buffaddr ( B -- pointer ) b>> ; inline
: luaL_addsize ( B n -- ) [ + ] curry change-n drop ; inline
: luaL_buffsub ( B n -- ) [ - ] curry change-n drop ; inline
: luaL_prepbuffer ( B -- pointer ) LUAL_BUFFERSIZE luaL_prepbuffsize ; inline
:: luaL_addchar ( B c -- )
    B n>> B size>> >= [ B 1 luaL_prepbuffsize drop ] when
    c B b>> B n>> set-alien-unsigned-1
    B 1 luaL_addsize ; inline

! Older convenience names whose operations still have direct equivalents.
: lua_open ( -- L ) luaL_newstate ; inline
: lua_objlen ( L idx -- n ) lua_rawlen ; inline
: lua_strlen ( L idx -- n ) lua_rawlen ; inline
: lua_equal ( L a b -- ? ) LUA_OPEQ lua_compare ; inline
: lua_lessthan ( L a b -- ? ) LUA_OPLT lua_compare ; inline
: lua_getregistry ( L -- ) LUA_REGISTRYINDEX lua_pushvalue ; inline
: lua_getgccount ( L -- n ) LUA_GCCOUNT lua_gc ; inline
: luaL_getn ( L idx -- n ) lua_rawlen ; inline
: luaL_checkint ( L arg -- n ) luaL_checkinteger ; inline
: luaL_optint ( L arg def -- n ) luaL_optinteger ; inline
: luaL_checklong ( L arg -- n ) luaL_checkinteger ; inline
: luaL_optlong ( L arg def -- n ) luaL_optinteger ; inline
: luaL_putchar ( B c -- ) luaL_addchar ; inline
