! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs assocs.extras combinators
combinators.short-circuit formatting io io.backend
io.directories io.encodings.binary io.files io.files.info
io.files.types io.pathnames kernel math math.statistics
prettyprint sequences sets sorting specialized-arrays
tools.memory.private tools.wc unicode ;
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
    [ "/.git/" swap subseq? ] reject ;

: without-node-modules-paths ( paths -- paths' )
    [ "/node_modules/" swap subseq? ] reject ;

: regular-directory-files ( path -- seq )
    recursive-directory-files
    [ link-info type>> +regular-file+ = ] filter ;

: codebase-paths ( path -- seq )
    regular-directory-files
    without-git-paths ;

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


: cmake-file? ( path -- ? ) { [ "CMakeLists.txt" tail? ] [ ".cmake" tail? ] } 1|| ;
: cmake-files ( paths -- paths' ) [ cmake-file? ] filter ;
: uses-cmake? ( paths -- ? ) [ cmake-file? ] any? ;

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

: txt-file? ( path -- ? )
    {
        [ { [ ".txt" tail? ] [ ".TXT" tail? ] } 1|| ]
        [ "CMakeLists.txt" tail? not ]
    } 1&& ;
: txt-files ( paths -- paths' ) [ txt-file? ] filter ;

: license-file? ( path -- ? )
    >lower { [ file-stem "license" = ] [ "license-mit" tail? ] } 1|| ;

: license-files ( paths -- paths' ) [ license-file? ] filter ;

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

: make-file? ( path -- ? ) >lower file-name { "gnumakefile" "makefile" "nmakefile" } member? ;
: make-files ( paths -- paths' ) [ make-file? ] filter ;
: uses-make? ( paths -- ? ) [ make-file? ] any? ;

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
        [ normalize-path "project at path `%s`" sprintf print ]
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
        [ uses-cmake? [ "uses cmake" print ] when ]
        [ uses-make? [ "uses make" print ] when ]
        [ rc-files [ length "has %d rc files" sprintf print ] unless-empty ]
        [ ignore-files [ length "has %d ignore files" sprintf print ] unless-empty ]
        [ "Top 20 largest files" print file-sizes sort-values 20 sequences:short tail* [ normalize-path ] map-keys assoc. nl ]
        [ "Top 10 file extention sizes" print sum-sizes-by-extension 10 sequences:short tail* assoc. nl ]
        [ "Top 10 text file line counts" print sum-line-counts-by-extension 10 sequences:short tail* assoc. nl ]
        [ "Top 10 file extention counts" print count-by-file-extension 10 sequences:short tail* assoc. nl ]
    } cleave ;

: analyze-codebase ( path -- )
    [ analyze-codebase-path ]
    [ codebase-paths analyze-codebase-paths ] bi ;

: analyze-codebases ( path -- )
    [ directory-files ] keep [ prepend-path ] curry map
    [ analyze-codebase ] each ;