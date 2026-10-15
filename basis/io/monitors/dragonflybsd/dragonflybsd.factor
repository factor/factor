! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.backend io.monitors io.monitors.bsd system ;
IN: io.monitors.dragonflybsd

M: dragonflybsd init-monitors init-bsd-monitors ;
M: dragonflybsd dispose-monitors dispose-bsd-monitors ;
M: dragonflybsd (monitor) <bsd-monitor> ;

dragonflybsd set-io-backend
