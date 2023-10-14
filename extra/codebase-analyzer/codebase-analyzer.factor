! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs assocs.extras combinators
combinators.short-circuit formatting io io.backend
io.directories io.encodings.binary io.files io.files.info
io.files.types io.pathnames kernel math math.statistics prettyprint
sequences sets sorting splitting toml tools.memory.private
tools.wc unicode ;
IN: codebase-analyzer

: file-sizes ( paths -- assoc )
    [ dup file-info size>> ] { } map>assoc ;

: binary-file? ( path -- ? )
    binary [ 1024 read ] with-file-reader [ 0 = ] any? ;

: binary-files ( paths -- ? ) [ binary-file? ] filter ;

: partition-binary ( paths -- binary text )
    [ binary-file? ] partition ;

: with-file-extensions ( paths -- paths' )
    [ has-file-extension? ] filter ;

: without-git-paths ( paths -- paths' )
    [ "/.git/" subseq-of? ] reject ;

: without-node-modules-paths ( paths -- paths' )
    [ "/node_modules/" subseq-of? ] reject ;

: regular-directory-files ( path -- seq )
    recursive-directory-files
    [ link-info type>> +regular-file+ = ] filter ;

: codebase-paths ( path -- seq )
    regular-directory-files
    without-git-paths
    without-node-modules-paths ;

: count-by-file-extension ( paths -- assoc )
    with-file-extensions
    [ file-extension ] histogram-by
    sort-values ;

: collect-extensions-by-line-count ( paths -- assoc )
    with-file-extensions
    [ wc ] collect-by
    sort-values ;

: collect-by-file-extension ( paths -- assoc )
    with-file-extensions
    [ file-extension ] collect-by ;

: sum-line-counts-by-extension ( paths -- assoc )
    [ binary-file? ] reject
    collect-by-file-extension
    [ [ wc ] map-sum ] assoc-map
    sort-values ;

: sum-sizes-by-extension ( paths -- assoc )
    collect-by-file-extension
    [ [ file-info size>> ] map-sum ] assoc-map
    sort-values ;

: upper-file? ( path -- ? )
    {
        [ { [ file-stem length 4 > ] [ file-extension length 3 <= ] } 1&& ]
        [ file-stem upper? ]
        [ file-stem [ { [ digit? ] [ "-." member? ] } 1|| ] all? not ]
    } 1&& ;
: upper-files ( paths -- seq ) [ upper-file? ] filter ;

: configure-file? ( path -- ? ) file-name >lower { [ "configure" = ] [ "configure." head? ] } 1|| ;
: configure-files ( paths -- paths' ) [ configure-file? ] filter ;

: cmake-file? ( path -- ? ) { [ "CMakeLists.txt" tail? ] [ ".cmake" tail? ] } 1|| ;
: cmake-files ( paths -- paths' ) [ cmake-file? ] filter ;
: uses-cmake? ( paths -- ? ) [ cmake-file? ] any? ;

: in-file? ( paths -- ? ) ".in" tail? ;
: in-files ( paths -- seq ) [ in-file? ] filter ;
: uses-in-files? ( paths -- ? ) [ in-file? ] any? ;

: shell-file? ( path -- ? ) >lower file-extension { "sh" "zsh" } member? ;
: shell-files ( paths -- paths' ) [ shell-file? ] filter ;
: uses-shell? ( paths -- ? ) [ shell-file? ] any? ;

: swift-files ( paths -- paths' ) [ ".swift" tail? ] filter ;

: c-file? ( path -- ? )
    >lower file-extension { "h" "c" } member? ;
: c-files ( paths -- paths' ) [ c-file? ] filter ;

: cpp-file? ( path -- ? )
    >lower file-extension { "h" "hh" "hpp" "cc" "cpp" } member? ;
: cpp-files ( paths -- paths' ) [ cpp-file? ] filter ;

: python-file? ( path -- ? )
    >lower file-extension {
        "py" "py3" "pyc" "pyo" "pyw" "pyx" "pyd"
        "pxd" "pxi" "pyd" "pxi" "pyi" "pyz" "pwxz" "pth"
    } member? ;
: python-files ( paths -- paths' ) [ python-file? ] filter ;

: markdown-file? ( path -- ? ) { [ ".md" tail? ] [ ".markdown" tail? ] } 1|| ;
: markdown-files ( paths -- paths' ) [ markdown-file? ] filter ;

: dot-file? ( path -- ? ) file-name "." head? ;
: dot-files ( paths -- paths' ) [ dot-file? ] filter ;

: txt-file? ( path -- ? )
    {
        [ { [ ".txt" tail? ] [ ".TXT" tail? ] } 1|| ]
        [ "CMakeLists.txt" tail? not ]
    } 1&& ;
: txt-files ( paths -- paths' ) [ txt-file? ] filter ;

: license-file? ( path -- ? )
    >lower { [ file-stem "license" = ] [ "license-mit" tail? ] } 1|| ;
: license-files ( paths -- paths' ) [ license-file? ] filter ;

: readme-file? ( path -- ? )
    >lower file-stem "readme" = ;
: readme-files ( paths -- paths' ) [ readme-file? ] filter ;

: owners-file? ( path -- ? )
    >lower file-stem "owners" = ;
: owners-files ( paths -- paths' ) [ owners-file? ] filter ;

: version-file? ( path -- ? )
    >lower file-stem "version" = ;
: version-files ( paths -- paths' ) [ version-file? ] filter ;

: json-file? ( path -- ? )
    >lower file-extension
    { "json" "jsonc" } member? ;

: json-files ( paths -- paths' ) [ json-file? ] filter ;

: yaml-file? ( path -- ? ) { [ ".yaml" tail? ] [ ".yml" tail? ] } 1|| ;
: yaml-files ( paths -- paths' ) [ yaml-file? ] filter ;
: uses-yaml? ( paths -- ? ) [ yaml-file? ] any? ;

: docker-file? ( path -- ? ) >lower file-name { "dockerfile" ".dockerignore" "docker-compose.yaml" } member? ;
: docker-files ( paths -- paths' ) [ docker-file? ] filter ;
: uses-docker? ( paths -- ? ) [ docker-file? ] any? ;

: automake-file? ( path -- ? )
    >lower file-name
    {
        [ "makefile.am" tail? ]
        [ "makefile.am.inc" tail? ]
    } 1|| ;
: automake-files ( paths -- paths' ) [ automake-file? ] filter ;
: uses-automake? ( paths -- ? ) [ automake-file? ] any? ;

: make-file? ( path -- ? )
    >lower file-name { "gnumakefile" "makefile" } member? ;
: make-files ( paths -- paths' ) [ make-file? ] filter ;
: uses-make? ( paths -- ? ) [ make-file? ] any? ;

: nmake-file? ( path -- ? ) >lower file-name "nmakefile" = ;
: nmake-files ( paths -- paths' ) [ nmake-file? ] filter ;
: uses-nmake? ( paths -- ? ) [ nmake-file? ] any? ;

: gradle-file? ( path -- ? ) >lower { [ "gradle" head? ] [ ".gradle" tail? ] } 1|| ;
: gradle-files ( paths -- paths' ) [ gradle-file? ] filter ;
: uses-gradle? ( paths -- ? ) [ gradle-file? ] any? ;

: github-file? ( path -- ? ) >lower ".github" swap subseq? ;
: github-files ( paths -- paths' ) [ github-file? ] filter ;
: has-github-files? ( paths -- ? ) [ github-file? ] any? ;

: cargo-file? ( path -- ? ) file-name { "Cargo.toml" "Cargo.lock" } member? ;
: cargo-files ( paths -- paths' ) [ cargo-file? ] filter ;
: has-cargo-files? ( paths -- ? ) [ cargo-file? ] any? ;

: julia-project-file? ( path -- ? ) file-name { "Project.toml" } member? ;
: julia-project-files ( paths -- paths' ) [ julia-project-file? ] filter ;
: has-julia-project-files? ( paths -- ? ) [ julia-project-file? ] any? ;

: rust-project-dir? ( path -- ? ) file-name "Cargo.toml" = ;

: rust-source-file? ( path -- ? )
    {
        [ ".rs" tail? ]
    } 1|| ;

: rust-source-files ( path -- paths ) [ rust-source-file? ] filter ;

: rust-build-system-files ( path -- ? )
    {
        [ "Carg.toml" tail? ]
        [ "Carg.lock" tail? ]
    } 1|| ;

: rust-intermediate-build-files ( path -- ? )
    {
        [ ".rlib" tail? ]
        [ ".rmeta" tail? ]
        [ ".o" tail? ]
    } 1|| ;

: rust-output-files ( path -- ? )
    {
        [ ".dll" tail? ]
        [ ".dylib" tail? ]
        [ ".a" tail? ]
        [ ".so" tail? ]
    } 1|| ;

: analyze-rust-cargo-toml ( assoc -- )
    {
        [ "workspace" of "members" of length [ "  %d member projects" sprintf print ] unless-zero ]
        [ "package" of "name" of [ "  name: %s" sprintf print ] when* ]
        [ "package" of "version" of [ "  version: %s" sprintf print ] when* ]
        [ "package" of "license" of [ "  license: %s" sprintf print ] when* ]
        [ "package" of "edition" of [ "  rust edition: %s" sprintf print ] when* ]
    } cleave ;

: analyze-rust-project ( path -- )
    [ "Analyzing rust project at %s" sprintf print ]
    [ path>toml analyze-rust-cargo-toml ]
    [ containing-directory recursive-directory-files ] tri
    {
        [ rust-source-files length "  %d rust source files" sprintf print ]
    } cleave ;

: web-file? ( path -- ? )
    >lower file-extension
    {
        "css" "scss" "js" "jsx" "ejs" "mjs" "ts" "tsx" "json" "html"
        "less" "mustache" "snap" "wasm"
    } member? ;
: web-files ( paths -- paths' ) [ web-file? ] filter ;

: rc-file? ( path -- ? ) >lower file-name { [ "." head? ] [ "rc" tail? ] } 1&& ;
: rc-files ( paths -- paths' ) [ rc-file? ] filter ;

: env-file? ( path -- ? ) >lower ".env" tail? ;
: env-files ( paths -- paths' ) [ env-file? ] filter ;

: image-file? ( path -- ? ) >lower file-extension { "png" "jpg" "jpeg" "ico" } member? ;
: image-files ( paths -- paths' ) [ image-file? ] filter ;

: ignore-file? ( path -- ? ) >lower file-name { [ "." head? ] [ "ignore" tail? ] } 1&& ;
: ignore-files ( paths -- paths' ) [ ignore-file? ] filter ;

: has-package-json? ( path -- ? ) "package.json" append-path file-exists? ;
: uses-git? ( path -- ? ) ".git" append-path file-exists? ;

: diff-paths ( paths quot -- paths' )
    keep swap [ [ normalize-path ] map ] bi@ diff ; inline

: assoc. ( assoc -- )
    [ commas ] map-values simple-table. ;

: analyze-codebase-path ( path -- )
    {
        [ normalize-path "project at path `%s`" sprintf print nl ]
        [ uses-git? [ "uses git" print ] when ]
        [ has-package-json? [ "has a package.json file" print ] when ]
    } cleave ;

: analyze-codebase-paths ( paths -- )
    {
        [
            partition-binary
            [ length "%d binary files" sprintf print ]
            [ length "%d text files" sprintf print ] bi*
        ]
        [ github-files [ "has .github files" print ... ] unless-empty ]
        [ license-files [ [ length "has %d license files" sprintf print ] [ ... ] bi ] unless-empty ]
        [ readme-files [ "has readme files" print ... ] unless-empty ]
        [ owners-files [ "has owners files" print ... ] unless-empty ]
        [ version-files [ "has version files" print ... ] unless-empty ]
        [
            { [ dot-files ] [ rc-files diff ] [ ignore-files diff ] } cleave
            [ "has dot files" print ... ] unless-empty
        ]
        [ rc-files [ [ length "has %d rc files" sprintf print ] [ ... ] bi ] unless-empty ]
        [ configure-files [ "uses configure files" print ... ] unless-empty ]
        [ automake-files [ "uses automake" print ... ] unless-empty ]
        [ make-files [ "uses make" print ... ] unless-empty ]
        [ nmake-files [ "uses nmake" print ... ] unless-empty ]
        [ cmake-files [ "uses cmake" print ... ] unless-empty ]
        [ gradle-files [ "uses gradle" print ... ] unless-empty ]
        [ cargo-files [ "uses rust/cargo" print ... ] unless-empty ]
        [ julia-project-files [ "uses julia Project.toml" print ... ] unless-empty ]
        [ in-files [ "uses 'in' files" print ... ] unless-empty ]
        [ ignore-files [ [ length "has %d ignore files" sprintf print ] [ ... ] bi ] unless-empty nl ]
        [ [ rust-project-dir? ] filter [ [ "rust projects at " print . ] [ [ analyze-rust-project ] each ] bi ] unless-empty nl ]
        [
            [ upper-files ] keep
            {
                [ license-files diff ]
                [ readme-files diff ]
                [ owners-files diff ]
                [ version-files diff ]
            } cleave
            [ [ length "has %d UPPER files (minus license,readme,owner,version)" sprintf print ] [ ... ] bi ] unless-empty nl
        ]
        [ "Top 20 largest files" print file-sizes sort-values 20 index-or-length tail* [ normalize-path ] map-keys reverse assoc. nl ]
        [ "Top 10 file extension sizes" print sum-sizes-by-extension 10 index-or-length tail* reverse assoc. nl ]
        [ "Top 10 text file line counts" print sum-line-counts-by-extension 10 index-or-length tail* reverse assoc. nl ]
        [ "Top 10 file extension counts" print count-by-file-extension 10 index-or-length tail* reverse assoc. nl ]
    } cleave ;

: analyze-codebase ( path -- )
    [ analyze-codebase-path ]
    [ codebase-paths analyze-codebase-paths ] bi ;

: analyze-codebases ( path -- )
    [ directory-files ] keep [ prepend-path ] curry map
    [ file-info directory? ] filter
    [ analyze-codebase ] each ;
