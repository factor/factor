! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.smart io.files kernel sequences
splitting vocabs.files vocabs.hierarchy vocabs.loader
vocabs.metadata sets ;
IN: modern.paths

: modern-if-available ( path -- path' )
    dup ".factor" ?tail [
        ".modern" append
        dup exists? [ nip ] [ drop ] if
    ] [
        drop
    ] if ;

ERROR: not-a-source-path path ;
: force-modern-path ( path -- path' )
    ".factor" ?tail [ ".modern" append ] [ not-a-source-path ] if ;
: modern-docs-path ( path -- path' )
    vocab-docs-path modern-if-available ;
: modern-tests-path ( path -- path' )
    vocab-tests-path modern-if-available ;
: modern-source-path ( path -- path' )
    vocab-source-path modern-if-available ;
: modern-syntax-path ( path -- path' )
    vocab-source-path ".factor" ?tail drop "-syntax.modern" append ;

: force-modern-docs-path ( path -- path' )
    vocab-docs-path force-modern-path ;
: force-modern-tests-path ( path -- path' )
    vocab-tests-path force-modern-path ;
: force-modern-source-path ( path -- path' )
    vocab-source-path force-modern-path ;

: vocabs-from ( root -- vocabs )
    "" disk-vocabs-in-root/prefix
    no-prefixes [ name>> ] map ;

: core-vocabs ( -- seq ) "resource:core" vocabs-from ;
: less-core-test-vocabs ( seq -- seq' )
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
    } diff ;

: core-bootstrap-vocabs ( -- seq )
    core-vocabs less-core-test-vocabs ;

: basis-vocabs ( -- seq ) "resource:basis" vocabs-from ;
: extra-vocabs ( -- seq ) "resource:extra" vocabs-from ;
: all-vocabs ( -- seq )
    [
        core-vocabs
        basis-vocabs
        extra-vocabs
    ] { } append-outputs-as ;

: filter-exists ( seq -- seq' ) [ exists? ] filter ;

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
        "resource:extra/math/blas/vectors/vectors.factor" ! need .modern file
        "resource:extra/math/blas/matrices/matrices.factor" ! need .modern file
    } diff
    ! Don't parse .modern files yet
    [ ".modern" tail? ] reject ;

: modern-source-paths ( names -- paths )
    [ modern-source-path ] map filter-exists reject-some-paths ;
: modern-docs-paths ( names -- paths )
    [ modern-docs-path ] map filter-exists reject-some-paths ;
: modern-tests-paths ( names -- paths )
    [ vocab-tests ] map concat
    [ modern-if-available ] map filter-exists reject-some-paths ;

: all-source-paths ( -- seq )
    all-vocabs modern-source-paths ;

: all-docs-paths ( -- seq )
    all-vocabs modern-docs-paths ;

: all-tests-paths ( -- seq )
    all-vocabs modern-tests-paths ;

: all-syntax-paths ( -- seq )
    all-vocabs [ modern-syntax-path ] map filter-exists reject-some-paths ;

: all-factor-paths ( -- seq )
    [
        all-syntax-paths all-source-paths all-docs-paths all-tests-paths
    ] { } append-outputs-as ;

: vocab-names>syntax ( strings -- seq )
    [ modern-syntax-path ] map [ exists? ] filter ;

: core-syntax-paths ( -- seq ) core-vocabs vocab-names>syntax reject-some-paths ;
: basis-syntax-paths ( -- seq ) basis-vocabs vocab-names>syntax reject-some-paths ;
: extra-syntax-paths ( -- seq ) extra-vocabs vocab-names>syntax reject-some-paths ;

: core-source-paths ( -- seq ) core-vocabs modern-source-paths reject-some-paths ;
: basis-source-paths ( -- seq ) basis-vocabs modern-source-paths reject-some-paths ;
: extra-source-paths ( -- seq ) extra-vocabs modern-source-paths reject-some-paths ;
