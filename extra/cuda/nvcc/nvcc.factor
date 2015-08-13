! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.smart io.backend io.directories
io.launcher io.pathnames kernel locals math sequences splitting
system ;
IN: cuda.nvcc

HOOK: nvcc-path os ( -- path )

M: object nvcc-path "nvcc" ;

M: macosx nvcc-path "/usr/local/cuda/bin/nvcc" ;

: cu>ptx ( path -- path' )
    ".cu" ?tail drop ".ptx" append ;

: nvcc-command ( path -- seq )
    [
        [ nvcc-path "--ptx" "-o" ] dip
        [ cu>ptx ] [ file-name ] bi
    ] output>array ;

ERROR: nvcc-failed n path ;

:: compile-cu ( path -- path' )
    path normalize-path :> path2
    path2 parent-directory [
        path2 nvcc-command
        run-process wait-for-process [ path2 nvcc-failed ] unless-zero
        path2 cu>ptx
    ] with-directory ;
