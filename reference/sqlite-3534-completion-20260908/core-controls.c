#include "sqlite3.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

int main(void) {
  sqlite3 *db=0, *copy=0;
  sqlite3_stmt *stmt=0;
  sqlite3_int64 size=0;
  assert(strcmp(sqlite3_libversion(), "3.53.4")==0);
  assert(sqlite3_open(":memory:", &db)==SQLITE_OK);
  assert(sqlite3_prepare_v2(db,"SELECT ?1",-1,&stmt,0)==SQLITE_OK);
  assert(sqlite3_bind_int(stmt,1,123)==SQLITE_OK);
  char *sql=sqlite3_expanded_sql(stmt);
  assert(sql && strcmp(sql,"SELECT 123")==0);
  sqlite3_free(sql);
  assert(sqlite3_finalize(stmt)==SQLITE_OK);
  assert(sqlite3_exec(db,"CREATE TABLE data(v); INSERT INTO data VALUES(8675309)",0,0,0)==SQLITE_OK);
  unsigned char *bytes=sqlite3_serialize(db,"main",&size,0);
  assert(bytes && size>=4096 && memcmp(bytes,"SQLite format 3",16)==0);
  assert(sqlite3_close(db)==SQLITE_OK);
  assert(sqlite3_open(":memory:",&copy)==SQLITE_OK);
  assert(sqlite3_deserialize(copy,"main",bytes,size,size,SQLITE_DESERIALIZE_FREEONCLOSE)==SQLITE_OK);
  assert(sqlite3_prepare_v2(copy,"SELECT v FROM data",-1,&stmt,0)==SQLITE_OK);
  assert(sqlite3_step(stmt)==SQLITE_ROW && sqlite3_column_int(stmt,0)==8675309);
  assert(sqlite3_finalize(stmt)==SQLITE_OK);
  const unsigned short utf16[]={ 'S','E','L','E','C','T',' ','\'',0x03bb,0x96ea,'\'',0 };
  assert(sqlite3_prepare16(copy,utf16,-1,&stmt,0)==SQLITE_OK);
  assert(sqlite3_step(stmt)==SQLITE_ROW && strcmp((const char *)sqlite3_column_text(stmt,0),"λ雪")==0);
  assert(sqlite3_finalize(stmt)==SQLITE_OK);
  assert(sqlite3_close(copy)==SQLITE_OK);
  sqlite3_filename name=sqlite3_create_filename("sample.db","sample.db-journal","sample.db-wal",0,0);
  assert(name && strcmp(sqlite3_filename_database(name),"sample.db")==0);
  assert(strcmp(sqlite3_filename_journal(name),"sample.db-journal")==0);
  assert(strcmp(sqlite3_filename_wal(name),"sample.db-wal")==0);
  sqlite3_free_filename(name);
  sqlite3_str *builder=sqlite3_str_new(0);
  sqlite3_str_appendall(builder,"abcdef");
  sqlite3_str_truncate(builder,3);
  sqlite3_str_appendall(builder,"XYZ");
  assert(strcmp(sqlite3_str_value(builder),"abcXYZ")==0);
  sqlite3_str_free(builder);
  puts("SQLite 3.53.4 core controls: PASS");
}
