! Copyright (C) 2026 Doug Coleman.
USING: bootstrap.image.private kernel namespaces parser sequences ;
IN: bootstrap.assembler.hppa
big-endian on
<< "resource:basis/bootstrap/assembler/hppa.32.factor" parse-file suffix! >> call
