
USING: alien.syntax ;

IN: unix.linux.fs

: MS_RDONLY		1    ; ! Mount read-only.
: MS_NOSUID		2    ; ! Ignore suid and sgid bits.
: MS_NODEV		4    ; ! Disallow access to device special files.
: MS_NOEXEC		8    ; ! Disallow program execution.
: MS_SYNCHRONOUS	16   ; ! Writes are synced at once.
: MS_REMOUNT		32   ; ! Alter flags of a mounted FS.
: MS_MANDLOCK		64   ; ! Allow mandatory locks on an FS.
: S_WRITE		128  ; ! Write on file/directory/symlink.
: S_APPEND		256  ; ! Append-only file.
: S_IMMUTABLE		512  ; ! Immutable file.
: MS_NOATIME		1024 ; ! Do not update access times.
: MS_NODIRATIME		2048 ; ! Do not update directory access times.
: MS_BIND		4096 ; ! Bind directory at different place.

FUNCTION: int mount
( char* special_file, char* dir, char* fstype, ulong options, void* data ) ;

! FUNCTION: int umount2 ( char* file, int flags ) ;

FUNCTION: int umount ( char* file ) ;