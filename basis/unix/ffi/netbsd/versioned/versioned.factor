USING: alien.c-types alien.syntax unix.time unix.types ;
IN: unix.ffi

FUNCTION-ALIAS: opendir DIR* __opendir30 ( c-string path )
FUNCTION-ALIAS: readdir dirent* __readdir30 ( DIR* dirp )
FUNCTION-ALIAS: readdir_r int __readdir_r30 ( void* dirp, dirent* entry, dirent** result )
FUNCTION-ALIAS: futimes int __futimes50 ( int id, timeval[2] times )
FUNCTION-ALIAS: utimes int __utimes50 ( c-string path, timeval[2] times )
FUNCTION-ALIAS: utime int __utime50 ( c-string path, utimbuf* buf )
FUNCTION-ALIAS: getpwent passwd* __getpwent50 ( )
FUNCTION-ALIAS: getpwuid passwd* __getpwuid50 ( uid_t uid )
FUNCTION-ALIAS: getpwnam passwd* __getpwnam50 ( c-string login )
FUNCTION-ALIAS: getpwnam_r int __getpwnam_r50 ( c-string login, passwd* pwd, c-string buffer, size_t bufsize, passwd** result )
FUNCTION-ALIAS: select int __select50 ( int nfds, void* readfds, void* writefds, void* exceptfds, timeval* timeout )
FUNCTION-ALIAS: getrusage int __getrusage50 ( int who, rusage* r_usage )
