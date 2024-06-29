! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs build-from-source cli.git formatting io
io.launcher kernel multiline namespaces prettyprint sequences
sorting.human ;
IN: build-from-source.macos

! brew install pkg-config openssl@1.1 xz gdbm tcl-tk
: build-python3-lib ( -- )
    "python" "cpython" latest-python3 [
        H{ } clone
        { "brew" "--prefix" "gdbm" } process-contents
        { "brew" "--prefix" "xz" } process-contents
        { "brew" "--prefix" "tcl-tk" } process-contents
        [ drop "-I%s/include -I%s/include" sprintf "CFLAGS" pick set-at ]
        [ drop "-L%s/lib -L%s/lib" sprintf "LDFLAGS" pick set-at ]
        [ 2nip "%s/lib/pkgconfig" sprintf "PKG_CONFIG_PATH" pick set-at ] 3tri
        <process>
            swap >>environment
        { "./configure" "--build=aarch64-apple-darwin" "--target=aarch64-apple-darwin" "--host=aarch64-apple-darwin" "--with-pydebug" } 
            { "brew" "--prefix" "openssl@3" } process-contents
            "--with-openssl=%s" sprintf suffix
        >>command try-process
        { "make" "-j" } try-process
    ] with-github-worktree-tag ;
