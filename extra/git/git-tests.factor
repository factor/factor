! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors git io io.directories io.launcher
io.streams.string kernel sequences tools.test ;
IN: git.tests

: with-empty-test-git-repo ( quot -- )
    '[
        { "git" "init" } try-process
        @
    ] with-test-directory ; inline

: with-zero-byte-file-repo ( quot -- )
    '[
        "empty-file" touch-file
        { "git" "add" "empty-file" } try-process
        { "git" "commit" "-m" "initial commit of empty file" } try-process
        @
    ] with-empty-test-git-repo ; inline

{ t } [
    [ git-head-ref ] with-empty-test-git-repo
    { "refs/heads/master" "refs/heads/main" } member?
] unit-test


{ } [
    [
        ! "." t recursive-directory-files
        git-log [ commit. ] each
    ] with-zero-byte-file-repo
] unit-test

{ } [
    [
        { "git" "log" } process-contents print
    ] with-zero-byte-file-repo
] unit-test


{
    T{ commit
        { tree "517e33595c3238dbffb4ce494390eb0a36de9604" }
        { parents "1b744404f3a19be816dc36334d070488e1f2b20e" }
        { author
            "Doug Coleman <doug.coleman@gmail.com> 1612484963 -0600"
        }
        { committer
            "Doug Coleman <doug.coleman@gmail.com> 1612485414 -0600"
        }
        { message
            "git: Fix parsing of gpgsig and clean up code.\n\nThey don't tell you that gpgsigs exist, take up many lines, and that you\nneed to keep reading while lines begin with a space."
        }
    }
} [
"tree 517e33595c3238dbffb4ce494390eb0a36de9604
parent 1b744404f3a19be816dc36334d070488e1f2b20e
author Doug Coleman <doug.coleman@gmail.com> 1612484963 -0600
committer Doug Coleman <doug.coleman@gmail.com> 1612485414 -0600

git: Fix parsing of gpgsig and clean up code.

They don't tell you that gpgsigs exist, take up many lines, and that you
need to keep reading while lines begin with a space."
    commit parse-new-git-object
] unit-test

{
    T{ commit
        { tree "6622ae8805e7278666a932015e93f143cbb4caf8" }
        { parents "71ad025aaf2b888119d4ac080cf5ac4c8c3a0b52" }
        { author
            "Doug Coleman <doug.coleman@gmail.com> 1573952316 -0600"
        }
        { committer "GitHub <noreply@github.com> 1573952316 -0600" }
        { gpgsig
            "-----BEGIN PGP SIGNATURE-----\n\nwsBcBAABCAAQBQJd0Js8CRBK7hj4Ov3rIwAAdHIIAK+7IlWjQF9NBXEMYiciO8DO\nAWgAaGu3ZOh+mXQtvBWqU7OInrcVUQwmo/W1eN/h7ZZS2+dGgAAO4/RxflZ0PaOo\nZnvPAVshNYL03KZSaruXtTs6z1ypoimy1Z89087OGwgTTY2AFDBoUeCEwmm7sTJ6\njWPhq6VlMszisdgqQrk5IiErDHtnm3mteiERTrIKTAeeT/bZuU0BF7eYVvgVLyLu\n/NFSmuEp9619c70KSM4NBG3KjepTW5T6wV/CwaMeoE2gNlj7ehgxZ0zkQg2m4Tpp\nVFiT4niYSekChldDoMJs9A5LZGwoU1QjzCknbfia24747q6qYW5EBK7Df5OhH08=\n=f5p9\n-----END PGP SIGNATURE-----\n"
        }
        { message
            "Add description of '-help' switch to documentation. (#2221)"
        }
    }
} [
"tree 6622ae8805e7278666a932015e93f143cbb4caf8
parent 71ad025aaf2b888119d4ac080cf5ac4c8c3a0b52
author Doug Coleman <doug.coleman@gmail.com> 1573952316 -0600
committer GitHub <noreply@github.com> 1573952316 -0600
gpgsig -----BEGIN PGP SIGNATURE-----
 
 wsBcBAABCAAQBQJd0Js8CRBK7hj4Ov3rIwAAdHIIAK+7IlWjQF9NBXEMYiciO8DO
 AWgAaGu3ZOh+mXQtvBWqU7OInrcVUQwmo/W1eN/h7ZZS2+dGgAAO4/RxflZ0PaOo
 ZnvPAVshNYL03KZSaruXtTs6z1ypoimy1Z89087OGwgTTY2AFDBoUeCEwmm7sTJ6
 jWPhq6VlMszisdgqQrk5IiErDHtnm3mteiERTrIKTAeeT/bZuU0BF7eYVvgVLyLu
 /NFSmuEp9619c70KSM4NBG3KjepTW5T6wV/CwaMeoE2gNlj7ehgxZ0zkQg2m4Tpp
 VFiT4niYSekChldDoMJs9A5LZGwoU1QjzCknbfia24747q6qYW5EBK7Df5OhH08=
 =f5p9
 -----END PGP SIGNATURE-----
 

Add description of '-help' switch to documentation. (#2221)"
    commit parse-new-git-object
] unit-test
