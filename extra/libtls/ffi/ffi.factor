USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax combinators system unix.types ;

IN: libtls.ffi

C-LIBRARY: libtls {
    { windows "libtls-10.dll" }
    { macos "libtls.dylib" }
    { unix "libtls.so" }
}

C-TYPE: tls_config
C-TYPE: tls_ctx

LIBRARY: libtls

FUNCTION: int tls_init ( )
FUNCTION: c-string tls_error ( tls_ctx* ctx )
FUNCTION: tls_config*  tls_config_new ( )
FUNCTION: void tls_config_free ( tls_config* config )
FUNCTION: int tls_config_parse_protocols ( uint32_t* protocols, c-string protostr )
FUNCTION: int tls_config_set_ca_file ( tls_config* config, c-string ca_file )
FUNCTION: int tls_config_set_ca_path ( tls_config* config, c-string ca_path )
FUNCTION: int tls_config_set_ca_mem ( tls_config* config, uint8_t *cert, size_t len )
FUNCTION: int tls_config_set_cert_file ( tls_config* config, c-string cert_file )
FUNCTION: int tls_config_set_cert_mem ( tls_config* config, uint8_t *cert, size_t len )
FUNCTION: int tls_config_set_ciphers ( tls_config* config, c-string ciphers )
FUNCTION: int tls_config_set_dheparams ( tls_config* config, c-string params )
FUNCTION: int tls_config_set_ecdhecurve ( tls_config* config, c-string name )
FUNCTION: int tls_config_set_key_file ( tls_config* config, c-string key_file )
FUNCTION: int tls_config_set_key_mem ( tls_config* config, uint8_t *key, size_t len )
FUNCTION: void tls_config_set_protocols ( tls_config* config, uint32_t protocols )
FUNCTION: void tls_config_set_verify_depth ( tls_config* config, int verify_depth )
FUNCTION: void tls_config_prefer_ciphers_client ( tls_config* config )
FUNCTION: void tls_config_prefer_ciphers_server ( tls_config* config )
FUNCTION: void tls_config_clear_keys ( tls_config* config )
FUNCTION: void tls_config_insecure_noverifycert ( tls_config* config )
FUNCTION: void tls_config_insecure_noverifyname ( tls_config* config )
FUNCTION: void tls_config_insecure_noverifytime ( tls_config* config )
FUNCTION: void tls_config_verify ( tls_config* config )
FUNCTION: void tls_config_verify_client ( tls_config* config )
FUNCTION: void tls_config_verify_client_optional ( tls_config* config )
FUNCTION: int tls_peer_cert_provided ( tls_ctx* ctx )
FUNCTION: int tls_peer_cert_contains_name ( tls_ctx* ctx, c-string name )
FUNCTION: c-string  tls_peer_cert_issuer ( tls_ctx* ctx )
FUNCTION: c-string  tls_peer_cert_subject ( tls_ctx* ctx )
FUNCTION: c-string  tls_peer_cert_hash ( tls_ctx* ctx )
FUNCTION: time_t tls_peer_cert_notbefore ( tls_ctx* ctx )
FUNCTION: time_t tls_peer_cert_notafter ( tls_ctx* ctx )
FUNCTION: c-string  tls_conn_version ( tls_ctx* ctx )
FUNCTION: c-string  tls_conn_cipher ( tls_ctx* ctx )
FUNCTION: uint8_t* tls_load_file ( c-string file, size_t *len, char *password )
FUNCTION: tls_ctx* tls_client ( )
FUNCTION: tls_ctx* tls_server ( )
FUNCTION: int tls_configure ( tls_ctx* ctx, tls_config* config )
FUNCTION: void tls_reset ( tls_ctx* ctx )
FUNCTION: void tls_free ( tls_ctx* ctx )
FUNCTION: int tls_connect ( tls_ctx* ctx, c-string host, c-string port )
FUNCTION: int tls_connect_fds ( tls_ctx* ctx, int fd_read, int fd_write, c-string servername )
FUNCTION: int tls_connect_servername ( tls_ctx* ctx, c-string host, c-string port, c-string servername )
FUNCTION: int tls_connect_socket ( tls_ctx* ctx, int s, c-string servername )
FUNCTION: int tls_accept_fds ( tls_ctx* tls, tls_ctx* *cctx, int fd_read, int fd_write )
FUNCTION: int tls_accept_socket ( tls_ctx* tls, tls_ctx* *cctx, int socket )
FUNCTION: int tls_handshake ( tls_ctx* ctx )
FUNCTION: ssize_t tls_read ( tls_ctx* ctx, void* buf, size_t buflen )
FUNCTION: ssize_t tls_write ( tls_ctx* ctx, void* buf, size_t buflen )
FUNCTION: int tls_close ( tls_ctx* ctx )

DESTRUCTOR: tls_config_free
DESTRUCTOR: tls_free
