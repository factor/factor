USING: layouts combinators vocabs.loader alien.syntax ;
IN: unix.stat

cell-bits {
    { 32 [ "unix.stat.netbsd.32" require ] }
    { 64 [ "unix.stat.netbsd.64" require ] }
} case

CONSTANT: _VFS_NAMELEN    32  
CONSTANT: _VFS_MNAMELEN   1024

C-STRUCT: statvfs
    { "ulong"   "f_flag" }   
    { "ulong"   "f_bsize" }
    { "ulong"   "f_frsize" }  
    { "ulong"   "f_iosize" }  
    { "fsblkcnt_t" "f_blocks" }       
    { "fsblkcnt_t" "f_bfree" } 
    { "fsblkcnt_t" "f_bavail" }       
    { "fsblkcnt_t" "f_bresvd" }       
    { "fsfilcnt_t" "f_files" }
    { "fsfilcnt_t" "f_ffree" }
    { "fsfilcnt_t" "f_favail" }       
    { "fsfilcnt_t" "f_fresvd" }       
    { "uint64_t"   "f_syncreads" }    
    { "uint64_t"   "f_syncwrites" }   
    { "uint64_t"   "f_asyncreads" }   
    { "uint64_t"   "f_asyncwrites" }  
    { "fsid_t"    "f_fsidx" }
    { "ulong"   "f_fsid" }
    { "ulong"   "f_namemax" }      
    { "uid_t"   "f_owner" }
    { { "uint32_t" 4 } "f_spare" }     
    { { "char" _VFS_NAMELEN } "f_fstypename" }
    { { "char" _VFS_NAMELEN } "f_mntonname" }
    { { "char" _VFS_NAMELEN } "f_mntfromname" } ;

FUNCTION: int statvfs ( char* path, statvfs* buf ) ;
