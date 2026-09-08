! Copyright (C) 2011 Alex Vondrak, 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel namespaces ;
QUALIFIED: compiler.cfg.value-numbering
IN: compiler.cfg.gvn

! Compatibility entry point, using the shared production rewrite rules.
: value-numbering ( cfg -- )
    t compiler.cfg.value-numbering:global-value-numbering? [
        compiler.cfg.value-numbering:value-numbering
    ] with-variable ;
