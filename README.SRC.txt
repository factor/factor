FACTOR

This source archive contains sources for two distinct
bodies of code -- a Factor interpreter written in Java,
and a Factor interpreter written in C. The C interpreter
is a more recent development than the Java interpreter.
They both share a large body of library code written in
Factor.

Java interpreter
----------------

The Java interpreter includes a slick GUI with hyperlinked
inspection of source code, as well as stack effect checking.

build.xml - Ant buildfile for Java interpreter.
factor/ - source code for Factor interpreter written in Java.
org/objectweb/asm/ - helper library for Java interpreter.
Factor.jar - compiled, stand-alone Java interpreter
library/platform/jvm - JVM-specific Factor code

C interpreter
-------------

The C interpreter is a minimal implementation, with the goal
of achieving the highest possible flexibility/lines of code
ratio. It runs faster than the Java interpreter, and uses
far less memory.

native/ - source code for Factor interpreter written in C.
native/build.sh - build script for C interpreter.
native/f - compiled C interpreter - needs image to run
native/factor.image - cross-compiler output
library/platform/native - C interpreter-specific code

Notes on the C interpreter
--------------------------

At the moment it assumes little endian byte order, 32-bit
words. This pretty much means x86.

Very soon I will add image input and output in both byte
orders - this will allow Factor to run on powerpc and
sparc.

Moving to 64-bits would require a few changes in the image
cross-compiler, namely in the way it packs strings.

Not everything has been implemented yet. However, a lot
already works. Compare the output of this in the C and
Java interpreters to see how they differ:

"vocabularies" get describe
