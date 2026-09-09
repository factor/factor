/* Native controls and data providers; all ABI declarations come from SQLite's header. */
#include "sqlite3.h"
#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

sqlite3 *optional_open(void) {
  sqlite3 *db=0;
  assert(sqlite3_open(":memory:",&db)==SQLITE_OK);
  assert(sqlite3_exec(db,"CREATE TABLE t(id INTEGER PRIMARY KEY, v INTEGER)",0,0,0)==SQLITE_OK);
  return db;
}
int optional_exec(sqlite3 *db, const char *sql) { return sqlite3_exec(db,sql,0,0,0); }
sqlite3_stmt *optional_prepare(sqlite3 *db, const char *sql) {
  sqlite3_stmt *s=0; assert(sqlite3_prepare_v2(db,sql,-1,&s,0)==SQLITE_OK); return s;
}
int optional_sum(sqlite3 *db) {
  sqlite3_stmt *s=optional_prepare(db,"SELECT coalesce(sum(v),0) FROM t");
  assert(sqlite3_step(s)==SQLITE_ROW); int n=sqlite3_column_int(s,0);
  assert(sqlite3_finalize(s)==SQLITE_OK); return n;
}
static int conflict(void *ctx,int op,sqlite3_changeset_iter *it) { (void)ctx;(void)op;(void)it; return SQLITE_CHANGESET_ABORT; }
void *optional_conflict(void) { return (void*)conflict; }
static sqlite3_int64 array_data[]={-5000000000LL,42,6000000000LL};
static int destructor_token, destructor_calls;
static void array_delete(void *p) { assert(p==&destructor_token); destructor_calls++; }
void *optional_array(void) { destructor_calls=0; return array_data; }
void *optional_destructor(void) { return (void*)array_delete; }
void *optional_destructor_context(void) { return &destructor_token; }
int optional_destructor_calls(void) { return destructor_calls; }
static int preupdate_calls, preupdate_valid;
void optional_preupdate_reset(void) { preupdate_calls=0; preupdate_valid=0; }
void optional_preupdate_record(void *ctx,sqlite3 *db,int op,const char *schema,const char *table,sqlite3_int64 oldid,sqlite3_int64 newid) {
  sqlite3_value *old=0,*new=0;
  preupdate_calls++;
  preupdate_valid=ctx==&destructor_token && op==SQLITE_UPDATE && !strcmp(schema,"main") && !strcmp(table,"t") && oldid==7 && newid==7 && sqlite3_preupdate_count(db)==2 && sqlite3_preupdate_depth(db)==0 && sqlite3_preupdate_blobwrite(db)==-1;
  preupdate_valid=preupdate_valid && sqlite3_preupdate_old(db,1,&old)==SQLITE_OK && sqlite3_value_int(old)==11;
  preupdate_valid=preupdate_valid && sqlite3_preupdate_new(db,1,&new)==SQLITE_OK && sqlite3_value_int(new)==29;
}
int optional_preupdate_result(void) { return preupdate_calls==1 && preupdate_valid; }
fts5_api *optional_fts5_api(sqlite3 *db) {
  fts5_api *api=0; sqlite3_stmt *s=optional_prepare(db,"SELECT fts5(?1)");
  assert(sqlite3_bind_pointer(s,1,&api,"fts5_api_ptr",0)==SQLITE_OK);
  assert(sqlite3_step(s)==SQLITE_ROW); assert(sqlite3_finalize(s)==SQLITE_OK);
  assert(api && api->iVersion>=3); return api;
}
fts5_tokenizer_v2 *optional_fts5_tokenizer(fts5_api *api) {
  void *ctx=0; fts5_tokenizer_v2 *tok=0;
  assert(api->xFindTokenizer_v2(api,"unicode61",&ctx,&tok)==SQLITE_OK);
  return tok;
}
static int token_count;
static int token(void *ctx,int flags,const char *text,int n,int start,int end) {
  (void)ctx;(void)flags;(void)start;(void)end;
  assert((token_count==0 && n==5 && !memcmp(text,"hello",5)) || (token_count==1 && n==5 && !memcmp(text,"world",5)));
  token_count++; return SQLITE_OK;
}
int optional_fts5_verify(fts5_api *api,void *find,fts5_tokenizer_v2 *tok,void *create,void *destroy,void *tokenize) {
  void *ctx=0; fts5_tokenizer_v2 *found=0; Fts5Tokenizer *instance=0;
  if(find!=(void*)api->xFindTokenizer_v2 || create!=(void*)tok->xCreate || destroy!=(void*)tok->xDelete || tokenize!=(void*)tok->xTokenize) return 0;
  assert(api->xFindTokenizer_v2(api,"unicode61",&ctx,&found)==SQLITE_OK && found==tok);
  assert(tok->xCreate(ctx,0,0,&instance)==SQLITE_OK); token_count=0;
  assert(tok->xTokenize(instance,0,FTS5_TOKENIZE_DOCUMENT,"Hello world",11,0,0,token)==SQLITE_OK);
  tok->xDelete(instance); return token_count==2;
}
int optional_fts5_api_size(void) { return sizeof(fts5_api); }
int optional_fts5_tokenizer_size(void) { return sizeof(fts5_tokenizer_v2); }

/* The filename metadata is valid only during xOpen for a journal/WAL file. */
typedef sqlite3_file *(*optional_filename_callback)(sqlite3_filename);
static sqlite3_vfs *filename_parent;
static sqlite3_file *filename_main;
static optional_filename_callback filename_callback;
static int filename_seen, filename_bad;
static int filename_open(sqlite3_vfs *vfs,sqlite3_filename name,sqlite3_file *file,int flags,int *outflags) {
  (void)vfs;
  if(flags & SQLITE_OPEN_MAIN_DB) filename_main=file;
  if(flags & (SQLITE_OPEN_MAIN_JOURNAL|SQLITE_OPEN_WAL)) {
    assert(name && filename_main && filename_callback);
    sqlite3_file *actual=filename_callback(name);
    if(actual!=filename_main) filename_bad++;
    filename_seen |= (flags & SQLITE_OPEN_WAL) ? 2 : 1;
  }
  return filename_parent->xOpen(filename_parent,name,file,flags,outflags);
}
int optional_filename_oracle(optional_filename_callback callback) {
  char path[]="/tmp/factor-sqlite3534-vfs-XXXXXX";
  int fd=mkstemp(path); assert(fd>=0); assert(close(fd)==0);
  filename_parent=sqlite3_vfs_find(0); assert(filename_parent);
  sqlite3_vfs forwarding=*filename_parent;
  forwarding.zName="factor-sqlite3534-filename-oracle";
  forwarding.xOpen=filename_open;
  filename_main=0; filename_callback=callback; filename_seen=filename_bad=0;
  assert(sqlite3_vfs_register(&forwarding,0)==SQLITE_OK);
  sqlite3 *db=0;
  assert(sqlite3_open_v2(path,&db,SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE,forwarding.zName)==SQLITE_OK);
  assert(sqlite3_exec(db,"CREATE TABLE t(v); INSERT INTO t VALUES(1); PRAGMA journal_mode=WAL; INSERT INTO t VALUES(2)",0,0,0)==SQLITE_OK);
  assert(sqlite3_close(db)==SQLITE_OK);
  assert(sqlite3_vfs_unregister(&forwarding)==SQLITE_OK);
  assert(unlink(path)==0);
  filename_callback=0; filename_main=0; filename_parent=0;
  return filename_bad ? 0 : filename_seen;
}

#ifdef OPTIONAL_MAIN
int main(void) {
  assert(sqlite3_libversion_number()==3053004);
  const char *opts[]={"ENABLE_SESSION","ENABLE_PREUPDATE_HOOK","ENABLE_FTS5","ENABLE_CARRAY","ENABLE_COLUMN_METADATA","ENABLE_STMT_SCANSTATUS","ENABLE_NORMALIZE","ENABLE_SNAPSHOT"};
  for(unsigned i=0;i<sizeof(opts)/sizeof(opts[0]);i++) assert(sqlite3_compileoption_used(opts[i]));
  sqlite3 *a=optional_open(),*b=optional_open(); sqlite3_session *session=0; int n=0; void *data=0;
  assert(sqlite3session_create(a,"main",&session)==SQLITE_OK);
  assert(sqlite3session_attach(session,"t")==SQLITE_OK);
  assert(optional_exec(a,"INSERT INTO t VALUES(7,11),(8,19); UPDATE t SET v=29 WHERE id=7")==SQLITE_OK);
  assert(sqlite3session_changeset(session,&n,&data)==SQLITE_OK && n>0);
  assert(sqlite3changeset_apply(b,n,data,0,conflict,0)==SQLITE_OK);
  assert(optional_sum(b)==48); sqlite3_free(data); sqlite3session_delete(session);
  puts("session changeset/apply: PASS (48)");
  sqlite3_stmt *s=optional_prepare(a,"SELECT sum(value) FROM carray(?1)");
  assert(sqlite3_carray_bind_v2(s,1,optional_array(),3,SQLITE_CARRAY_INT64,array_delete,optional_destructor_context())==SQLITE_OK);
  assert(sqlite3_step(s)==SQLITE_ROW && sqlite3_column_int64(s,0)==1000000042LL);
  assert(sqlite3_finalize(s)==SQLITE_OK && optional_destructor_calls()==1);
  puts("carray_bind_v2 int64 + distinct destructor context: PASS (1000000042, 1)");
  optional_preupdate_reset(); sqlite3_preupdate_hook(b,optional_preupdate_record,optional_destructor_context());
  assert(optional_exec(b,"UPDATE t SET v=11 WHERE id=7")==SQLITE_OK); /* establish old value */
  optional_preupdate_reset(); assert(optional_exec(b,"UPDATE t SET v=29 WHERE id=7")==SQLITE_OK);
  assert(optional_preupdate_result()); sqlite3_preupdate_hook(b,0,0);
  puts("preupdate callback + old/new/count/depth/blobwrite: PASS");
  fts5_api *api=optional_fts5_api(a); fts5_tokenizer_v2 *tok=optional_fts5_tokenizer(api);
  assert(optional_fts5_verify(api,(void*)api->xFindTokenizer_v2,tok,(void*)tok->xCreate,(void*)tok->xDelete,(void*)tok->xTokenize));
  printf("FTS5 API v%d tokenizer v%d layout and tokenization: PASS (%zu, %zu)\n",api->iVersion,tok->iVersion,sizeof(*api),sizeof(*tok));
  assert(sqlite3_close(a)==SQLITE_OK && sqlite3_close(b)==SQLITE_OK);
  assert(optional_filename_oracle(sqlite3_database_file_object)==3);
  puts("VFS original journal + WAL filename to main database file: PASS (3)");
  return 0;
}
#endif
