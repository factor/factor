! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii editors.visual-studio-code
io.directories.search io.files.temp.windows io.pathnames kernel
system ;
IN: editors.visual-studio-code.windows

M: windows find-visual-studio-code-path
    get-appdata-directory 1array f
    [ file-name >lower "code.exe" = ] find-in-directories ;
