! Copyright (C) 2024 knottio.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax gobject-introspection system vocabs ;
IN: graphene.ffi

<< "pango.cairo.ffi" require >>

C-LIBRARY: graphene {
    { unix "libgraphene-1.0.so.0" }
}

LIBRARY: graphene

GIR: vocab:gir/Graphene-1.0.gir
