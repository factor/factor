! Copyright (C) 2024 knottio.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax gobject-introspection
system ;
IN: freetype2.gobject.ffi

LIBRARY: freetype2

FOREIGN-ATOMIC-TYPE: freetype2.int32 int32_t

GIR: vocab:gir/freetype2-2.0.gir
