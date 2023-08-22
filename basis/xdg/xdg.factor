! Copyright (C) 2015 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: environment sequences splitting ;

IN: xdg

! https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html

: xdg-data-home ( -- path )
    "XDG_DATA_HOME" os-env [ "~/.local/share" ] when-empty ;

: xdg-config-home ( -- path )
    "XDG_CONFIG_HOME" os-env [ "~/.config" ] when-empty ;

: xdg-cache-home ( -- path )
    "XDG_CACHE_HOME" os-env [ "~/.cache" ] when-empty ;

: xdg-data-dirs ( -- paths )
    "XDG_DATA_DIRS" os-env ":" split harvest
    [ { "/usr/local/share" "/usr/share" } ] when-empty ;

: xdg-config-dirs ( -- paths )
    "XDG_CONFIG_DIRS" os-env ":" split harvest
    [ { "/etc/xdg" } ] when-empty ;

: xdg-runtime-dir ( -- path/f )
    "XDG_RUNTIME_DIR" os-env ;
    ! TODO: check runtime secure permissions

: xdg-state-dir ( -- path )
    "XDG_STATE_HOME" os-env [ "~/.local/state" ] when-empty ;
