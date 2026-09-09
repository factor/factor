#include <curl/curl.h>
#include <lua5.1/lua.h>
#include <lua5.1/lauxlib.h>
#include <stdio.h>
#include <string.h>
int main(void) {
    CURL *curl = curl_easy_init();
    if (!curl) return 1;
    if (curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, -1L) != CURLE_BAD_FUNCTION_ARGUMENT) return 1;
    if (curl_easy_setopt(curl, CURLOPT_MAX_RECV_SPEED_LARGE, (curl_off_t)-1) != CURLE_BAD_FUNCTION_ARGUMENT) return 1;
    if (curl_easy_setopt(curl, CURLOPT_URL, "https://example.invalid/no-transfer") != CURLE_OK) return 1;
    char *url = NULL;
    if (curl_easy_getinfo(curl, CURLINFO_EFFECTIVE_URL, &url) != CURLE_OK || strcmp(url, "https://example.invalid/no-transfer")) return 1;
    curl_easy_cleanup(curl);
    lua_State *lua = luaL_newstate();
    if (!lua) return 1;
    const char *text = lua_pushfstring(lua, "%s/%d/%f/%c/%%", "lua", -37, 2.5, 'Z');
    if (strcmp(text, "lua/-37/2.5/Z/%") || lua_gettop(lua) != 1) return 1;
    lua_close(lua);
    puts("C controls: curl local options and Lua 5.1 variadic formatting passed");
    return 0;
}
