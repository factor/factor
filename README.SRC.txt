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
library/platform/jvm - JVM-specific Factor code
Factor.jar - compiled, stand-alone Java interpreter

C interpreter
-------------

The C interpreter is a minimal implementation, with the goal
of achieving the highest possible flexibility/lines of code
ratio. It runs faster than the Java interpreter, and uses
far less memory.

Makefile - Makefile for building C interpreter.
native/ - source code for Factor interpreter written in C.
library/platform/native - C interpreter-specific code
f - compiled C interpreter - needs image to run
boot.image.le - image for x86
boot.image.be - image for 32-bit SPARC and 32-bit PowerPC

Notes on the C interpreter
--------------------------

When you run the interpreter with a boot image, it loads a
bunch of files and saves a 'factor.image'. Run the
interpreter again with this image.

At the moment it assumes a 32-bit architecture. Your C
compiler's types must be as follows:

short - signed 16 bits
long - signed 32 bits
long long - signed 64 bits
double -IEEE double precision 64-bit float

Moving to 64-bits would require a few changes in the image
cross-compiler, namely in the way it packs strings.

Not everything has been implemented yet. However, a lot
already works. Compare the output of this in the C and
Java interpreters to see how they differ:

"vocabularies" get describe
