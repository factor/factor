USING: kernel lua tools.test vocabs words ;
{ t } [ "lua_pushfstring" "lua" lookup-word >boolean ] unit-test
{ t } [ "lua_pushvfstring" "lua" lookup-word >boolean ] unit-test
{ t } [ "luaL_error" "lua" lookup-word >boolean ] unit-test
