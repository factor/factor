USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.fs-info.haiku
LIBRARY: libc
STRUCT: fs-info
    { dev dev_t } { root ino_t } { flags uint } { block-size off_t }
    { io-size off_t } { total-blocks off_t } { free-blocks off_t }
    { total-nodes off_t } { free-nodes off_t }
    { device-name char[128] } { volume-name char[256] } { fsh-name char[32] } ;
FUNCTION: dev_t dev_for_path ( c-string path )
FUNCTION: dev_t next_dev ( int* position )
FUNCTION: int fs_stat_dev ( dev_t device, fs-info* info )
LIBRARY: factor
FUNCTION: int factor_haiku_volume_path ( dev_t device, void* buffer, size_t size )
