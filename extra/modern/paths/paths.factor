! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.smart io.files sequences sets
vocabs.files vocabs.hierarchy vocabs.loader ;
IN: modern.paths

ERROR: not-a-source-path path ;

: vocabs-from ( root -- vocabs )
    "" disk-vocabs-in-root/prefix
    no-prefixes [ name>> ] map ;

CONSTANT: core-broken-vocabs
    {
        "vocabs.loader.test.a"
        "vocabs.loader.test.b"
        "vocabs.loader.test.c"
        "vocabs.loader.test.d"
        "vocabs.loader.test.e"
        "vocabs.loader.test.f"
        "vocabs.loader.test.g"
        "vocabs.loader.test.h"
        "vocabs.loader.test.i"
        "vocabs.loader.test.j"
        "vocabs.loader.test.k"
        "vocabs.loader.test.l"
        "vocabs.loader.test.m"
        "vocabs.loader.test.n"
        "vocabs.loader.test.o"
        "vocabs.loader.test.p"
    }

: core-vocabs ( -- seq )
    "resource:core" vocabs-from core-broken-vocabs diff ;

: basis-vocabs ( -- seq ) "resource:basis" vocabs-from ;
: extra-vocabs ( -- seq ) "resource:extra" vocabs-from ;
: all-vocabs ( -- seq )
    [
        core-vocabs
        basis-vocabs
        extra-vocabs
    ] { } append-outputs-as ;

: filter-exists ( seq -- seq' ) [ file-exists? ] filter ;

! These paths have syntax errors on purpose...
: reject-some-paths ( seq -- seq' )
    {
        "resource:core/vocabs/loader/test/a/a.factor"
        "resource:core/vocabs/loader/test/b/b.factor"
        "resource:core/vocabs/loader/test/c/c.factor"
        ! Here down have parse errors
        "resource:core/vocabs/loader/test/d/d.factor"
        "resource:core/vocabs/loader/test/e/e.factor"
        "resource:core/vocabs/loader/test/f/f.factor"
        "resource:core/vocabs/loader/test/g/g.factor"
        "resource:core/vocabs/loader/test/h/h.factor"
        "resource:core/vocabs/loader/test/i/i.factor"
        "resource:core/vocabs/loader/test/j/j.factor"
        "resource:core/vocabs/loader/test/k/k.factor"
        "resource:core/vocabs/loader/test/l/l.factor"
        "resource:core/vocabs/loader/test/m/m.factor"
        "resource:core/vocabs/loader/test/n/n.factor"
        "resource:core/vocabs/loader/test/o/o.factor"
        "resource:core/vocabs/loader/test/p/p.factor"
    } diff
    ! Don't parse .modern files yet
    [ ".modern" tail? ] reject ;

: modern-source-paths ( names -- paths )
    [ vocab-source-path ] map filter-exists reject-some-paths ;
: modern-docs-paths ( names -- paths )
    [ vocab-docs-path ] map filter-exists reject-some-paths ;
: modern-tests-paths ( names -- paths )
    [ vocab-tests ] map concat filter-exists reject-some-paths ;

: all-source-paths ( -- seq )
    all-vocabs modern-source-paths ;

: core-docs-paths ( -- seq ) core-vocabs modern-docs-paths ;
: basis-docs-paths ( -- seq ) basis-vocabs modern-docs-paths ;
: extra-docs-paths ( -- seq ) extra-vocabs modern-docs-paths ;

: core-test-paths ( -- seq ) core-vocabs modern-tests-paths ;
: basis-test-paths ( -- seq ) basis-vocabs modern-tests-paths ;
: extra-test-paths ( -- seq ) extra-vocabs modern-tests-paths ;


: all-docs-paths ( -- seq ) all-vocabs modern-docs-paths ;
: all-tests-paths ( -- seq ) all-vocabs modern-tests-paths ;

: all-paths ( -- seq )
    [
        all-source-paths all-docs-paths all-tests-paths
    ] { } append-outputs-as ;

: core-source-paths ( -- seq )
    core-vocabs modern-source-paths reject-some-paths ;
: basis-source-paths ( -- seq )
    basis-vocabs
    modern-source-paths reject-some-paths ;
: extra-source-paths ( -- seq )
    extra-vocabs
    modern-source-paths reject-some-paths ;
