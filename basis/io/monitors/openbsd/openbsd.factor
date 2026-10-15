! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.backend io.monitors io.monitors.bsd system ;
IN: io.monitors.openbsd

M: openbsd init-monitors init-bsd-monitors ;
M: openbsd dispose-monitors dispose-bsd-monitors ;
M: openbsd (monitor) <bsd-monitor> ;

openbsd set-io-backend
