! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: environment memoize sequences splitting ;

IN: xdg

! http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html

MEMO: xdg-data-home ( -- path )
    "XDG_DATA_HOME" os-env [ "~/.local/share" ] when-empty ;

MEMO: xdg-config-home ( -- path )
    "XDG_CONFIG_HOME" os-env [ "~/.config" ] when-empty ;

MEMO: xdg-cache-home ( -- path )
    "XDG_CACHE_HOME" os-env [ "~/.cache" ] when-empty ;

MEMO: xdg-data-dirs ( -- paths )
    "XDG_DATA_DIRS" os-env ":" split harvest
    [ { "/usr/local/share" "/usr/share" } ] when-empty ;

MEMO: xdg-config-dirs ( -- paths )
    "XDG_CONFIG_DIRS" os-env ":" split harvest
    [ { "/etc/xdg" } ] when-empty ;

MEMO: xdg-runtime-dir ( -- path/f )
    "XDG_RUNTIME_DIR" os-env ;
    ! TODO: check runtime secure permissions
