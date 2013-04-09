! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors.sublime io.directories.search.windows sequences
system ;
IN: editors.sublime.windows

M: windows find-sublime-path
    "Sublime Text 2"
    [ "sublime_text.exe" tail? ] find-in-program-files ;
