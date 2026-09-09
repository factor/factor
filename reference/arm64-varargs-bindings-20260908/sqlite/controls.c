#include <sqlite3.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

static int lists(const char *format,...) {
    va_list original,copy;
    va_start(original,format);
    va_copy(copy,original);
    char *text=sqlite3_vmprintf(format,copy);
    va_end(copy);
    int ok=text && strcmp(text,"'O''Brien':42:1.25")==0;
    sqlite3_free(text);
    char buffer[8];
    va_copy(copy,original);
    ok=ok && sqlite3_vsnprintf(sizeof buffer,buffer,format,copy)==buffer;
    va_end(copy);
    ok=ok && strcmp(buffer,"'O''Bri")==0;
    sqlite3_str *builder=sqlite3_str_new(NULL);
    sqlite3_str_appendf(builder,"prefix:");
    va_copy(copy,original);
    sqlite3_str_vappendf(builder,format,copy);
    va_end(copy);
    text=sqlite3_str_finish(builder);
    ok=ok && text && strcmp(text,"prefix:'O''Brien':42:1.25")==0;
    sqlite3_free(text);
    va_end(original);
    return ok;
}

int main(void) {
    char *text=sqlite3_mprintf("%Q:%d:%.2f","O'Brien",42,1.25);
    int ok=text && strcmp(text,"'O''Brien':42:1.25")==0;
    sqlite3_free(text);
    char buffer[8];
    ok=ok && sqlite3_snprintf(sizeof buffer,buffer,"%Q:%d:%.2f","O'Brien",42,1.25)==buffer;
    ok=ok && strcmp(buffer,"'O''Bri")==0;
    buffer[0]='x';
    ok=ok && sqlite3_snprintf(0,buffer,"unchanged")==buffer && buffer[0]=='x';
    ok=ok && lists("%Q:%d:%.2f","O'Brien",42,1.25);
    printf("SQLite %s C formatting controls: %s\n",sqlite3_libversion(),ok ? "PASS" : "FAIL");
    return !ok;
}
