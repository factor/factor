! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
combinators.smart formatting io io.backend io.directories
io.encodings.binary io.files io.files.info io.files.types
io.pathnames kernel math math.parser math.statistics prettyprint
sequences sets sorting toml tools.memory.private tools.wc
unicode ;
IN: codebase-analyzer

: file-sizes ( paths -- assoc )
    [ dup file-info size>> ] map>alist ;

: binary-file? ( path -- ? )
    binary [ 1024 read ] with-file-reader [ 0 = ] any? ;

: binary-files ( paths -- ? ) [ binary-file? ] filter ;

: partition-binary ( paths -- binary text )
    [ binary-file? ] partition ;

: with-file-extensions ( paths -- paths' )
    [ has-file-extension? ] filter ;

: without-git-paths ( paths -- paths' )
    [ "/.git/" subseq-of? ] reject ;

: without-repo-paths ( paths -- paths' )
    [ "/.repo/" subseq-of? ] reject ;

: without-node-modules-paths ( paths -- paths' )
    [ "/node_modules/" subseq-of? ] reject ;

: regular-directory-files ( path -- seq )
    recursive-directory-files
    [ link-info type>> +regular-file+ = ] filter ;

: codebase-paths ( path -- seq )
    regular-directory-files
    without-git-paths
    without-repo-paths
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
    >lower file-extension { "c" } member? ;
: c-files ( paths -- paths' ) [ c-file? ] filter ;

: c-header-file? ( path -- ? )
    >lower file-extension { "h" } member? ;
: c-header-files ( paths -- paths' ) [ c-header-file? ] filter ;

: cpp-file? ( path -- ? )
    >lower file-extension { "cc" "cpp" } member? ;
: cpp-files ( paths -- paths' ) [ cpp-file? ] filter ;

: cpp-header-file? ( path -- ? )
    >lower file-extension { "h" "hh" "hpp" } member? ;
: cpp-header-files ( paths -- paths' ) [ cpp-header-file? ] filter ;

: python-file? ( path -- ? )
    >lower file-extension {
        "py" "py3" "pyc" "pyo" "pyw" "pyx" "pyd"
        "pxd" "pxi" "pyd" "pxi" "pyi" "pyz" "pwxz" "pth"
    } member? ;
: python-files ( paths -- paths' ) [ python-file? ] filter ;

: python-packaging-file? ( path -- ? )
    {
        [ file-stem "AUTHORS" = ]
        [ file-stem "COPYING" = ]
        [ file-stem "INSTALLER" = ]
        [ file-stem "LICENSE" = ]
        [ file-stem "METADATA" = ]
        [ file-stem "RECORD" = ]
        [ file-stem "REQUESTED" = ]
        [ file-stem "WHEEL" = ]
    } 1|| ;
: python-packaging-files ( paths -- paths' ) [ python-packaging-file? ] filter ;

: java-file? ( path -- ? )
    >lower file-extension {
        "java" "class" "jar" "war" "ear" "jmod" "jad" "ser"
        "jml" "mf" "properties" "jks" "keystore" "jceks"
        "jsa" "jhi" "jpage" "jsp" "jspx" "jte" "policy"
        "sf" "pack" "idx" "hsperfdata" "jfr" "jlink" "jmod"
        "bsh" "groovy" "gsp" "gradle" "pom" "jnlp" ".jpf"
    } member? ;
: java-files ( paths -- paths' ) [ java-file? ] filter ;

: javascript-file? ( path -- ? )
    >lower file-extension {
        "js" "json" "jsx" "mjs" "ts" "tsx" "vue" "cjs" "esm"
        "map"
    } member? ;
: javascript-files ( paths -- paths' ) [ javascript-file? ] filter ;

: rust-file? ( path -- ? )
    >lower file-extension {
        "rs" "rlib" "toml" "cargo" "lock"
    } member? ;
: rust-files ( paths -- paths' ) [ rust-file? ] filter ;

: css-file? ( path -- ? )
    >lower file-extension {
        "css" "scss" "less" "sass" "styl" "stylus" "pcss" "postcss"
        "acss"
    } member? ;
: css-files ( paths -- paths' ) [ css-file? ] filter ;

: html-file? ( path -- ? )
    >lower file-extension {
        "html" "htmx" "htm" "xhtml" "xml" "rss" "atom" "svg" "xsl" "xslt"
        "wsdl" "wadl" "xsd" "dtd" "wsdl" "raml" "openapi" "wsdl" "wadl"
    } member? ;
: html-files ( paths -- paths' ) [ html-file? ] filter ;

: factor-file? ( path -- ? )
    >lower file-extension {
        "factor"
    } member? ;
: factor-files ( paths -- paths' ) [ factor-file? ] filter ;

: erlang-file? ( path -- ? )
    >lower file-extension {
        "erl" "beam" "hrl" "app" "app.src" "escript" "rel" "yrl" "xrl"
    } member? ;
: erlang-files ( paths -- paths' ) [ erlang-file? ] filter ;

: markdown-file? ( path -- ? ) { [ ".md" tail? ] [ ".markdown" tail? ] } 1|| ;
: markdown-files ( paths -- paths' ) [ markdown-file? ] filter ;

: dot-file? ( path -- ? ) file-name "." head? ;
: dot-files ( paths -- paths' ) [ dot-file? ] filter ;

: citation-file? ( path -- ? )
    >lower file-extension {
        "cff" "bib" "enw" "ris" "rdf" "mods" "ref" ! "xml"
    } member? ;
: citation-files ( paths -- paths' ) [ citation-file? ] filter ;

: txt-file? ( path -- ? )
    {
        [ { [ ".txt" tail? ] [ ".TXT" tail? ] } 1|| ]
        [ "CMakeLists.txt" tail? not ]
    } 1&& ;
: txt-files ( paths -- paths' ) [ txt-file? ] filter ;

: license-file? ( path -- ? )
    >lower {
        [ file-stem "license" = ]
        [ file-stem "licenses" = ]
        [ "license-mit" tail? ]
        [ "license-apache" tail? ]
    } 1|| ;
: license-files ( paths -- paths' ) [ license-file? ] filter ;

: readme-file? ( path -- ? )
    >lower file-stem "readme" = ;
: readme-files ( paths -- paths' ) [ readme-file? ] filter ;

: owners-file? ( path -- ? )
    >lower file-stem "owners" = ;
: owners-files ( paths -- paths' ) [ owners-file? ] filter ;

: codenotify-file? ( path -- ? )
    >lower file-stem "codenotify" = ;
: codenotify-files ( paths -- paths' ) [ codenotify-file? ] filter ;

: contributing-file? ( path -- ? )
    >lower {
        [ file-stem "contributors" = ]
        [ file-stem "maintainers" = ]
        [ file-stem "code-of-conduct" = ]
        [ file-stem "code_of_conduct" = ]
    } 1|| ;
: contributing-files ( paths -- paths' ) [ contributing-file? ] filter ;

: authors-file? ( path -- ? )
    >lower file-stem "authors" = ;
: authors-files ( paths -- paths' ) [ authors-file? ] filter ;

: changelog-file? ( path -- ? )
    >lower {
        [ file-stem "changelog" = ]
        [ file-stem "changes" = ]
        [ file-stem "weekly_updates" = ]
    } 1|| ;
: changelog-files ( paths -- paths' ) [ changelog-file? ] filter ;

: release-file? ( path -- ? )
    >lower {
        [ file-stem "releases" = ]
        [ file-stem "release" = ]
    } 1|| ;
: release-files ( paths -- paths' ) [ release-file? ] filter ;

: ideas-file? ( path -- ? )
    >lower {
        [ file-stem "ideas" = ]
        [ file-stem "notes" = ]
        [ file-stem "design" = ]
    } 1|| ;
: ideas-files ( paths -- paths' ) [ ideas-file? ] filter ;

: testing-file? ( path -- ? )
    >lower {
        [ file-stem "testing" = ]
    } 1|| ;
: testing-files ( paths -- paths' ) [ testing-file? ] filter ;

: patents-file? ( path -- ? )
    >lower {
        [ file-stem "patents" = ]
    } 1|| ;
: patents-files ( paths -- paths' ) [ patents-file? ] filter ;

: copying-file? ( path -- ? )
    >lower {
        [ file-stem "copying" = ]
    } 1|| ;
: copying-files ( paths -- paths' ) [ copying-file? ] filter ;

: copyright-file? ( path -- ? )
    >lower {
        [ file-stem "copyright" = ]
    } 1|| ;
: copyright-files ( paths -- paths' ) [ copyright-file? ] filter ;

: install-file? ( path -- ? )
    >lower {
        [ file-stem "install" = ]
    } 1|| ;
: install-files ( paths -- paths' ) [ install-file? ] filter ;

: codeowners-file? ( path -- ? )
    >lower {
        [ file-stem "codeowners" = ]
    } 1|| ;
: codeowners-files ( paths -- paths' ) [ codeowners-file? ] filter ;

: contributors-file? ( path -- ? )
    >lower {
        [ file-stem "contributors" = ]
        [ file-stem "contributing" = ]
    } 1|| ;
: contributors-files ( paths -- paths' ) [ contributors-file? ] filter ;

: security-file? ( path -- ? )
    >lower file-stem "security" = ;
: security-files ( paths -- paths' ) [ security-file? ] filter ;

: notice-file? ( path -- ? )
    >lower file-stem "notice" = ;
: notice-files ( paths -- paths' ) [ notice-file? ] filter ;

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

: docker-file? ( path -- ? )
    [
        >lower file-extension {
            "docker"
        } member?
    ] [
        >lower file-name {
            "dockerfile" ".dockerignore" "docker-compose.yaml"
        } [ subseq-of? ] with any?
    ] bi or ;

: docker-files ( paths -- paths' )
    [ [ docker-file? ] filter ]
    [ [ >lower "dockerfile" subseq-of? ] filter ] bi
    append members ;
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

: meson-file? ( path -- ? ) >lower file-name "meson.build" = ;
: meson-files ( paths -- paths' ) [ meson-file? ] filter ;
: uses-meson? ( paths -- ? ) [ meson-file? ] any? ;

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

: print-rust-package ( assoc -- )
    {
        [ "name" of [ "  name: %s" sprintf print ] when* ]
        [ "version" of [ "  version: %s" sprintf print ] when* ]
        [ "license" of [ "  license: %s" sprintf print ] when* ]
        [ "edition" of [ "  rust edition: %s" sprintf print ] when* ]
    } cleave ;

: analyze-rust-cargo-toml ( assoc -- )
    [ print-rust-package ] keep
    [ "workspace" of "members" of length [ "  %d member projects" sprintf print ] unless-zero ]
    [
        [ [ "package" of ] [ "workspace" of "package" of ] bi assoc-union ] keep
        "workspace" of "members" of [
            "package: " write print print-rust-package
        ] with each
    ] bi ;

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

: doc-file? ( path -- ? ) >lower file-extension [
        "adoc" "txt" "rst" "doc" "docx" "pdf" "epub"
        "wiki" "odt" "tex" "md" "markdown"
    ] member? ;
: doc-files ( paths -- paths' ) [ doc-file? ] filter ;

: image-file? ( path -- ? ) >lower file-extension { "png" "jpg" "jpeg" "ico" } member? ;
: image-files ( paths -- paths' ) [ image-file? ] filter ;

: sql-file? ( path -- ? ) >lower file-extension {
        "sql" "mdf" "ldf" "ndf" "trn" "db"
        "frm" "myd" "myi" "idb" "accdb" "mdb"
        "sqlite" "sqlite3" "db3" "ora" "dbf" "sdf"
    } member? ;
: sql-files ( paths -- paths' ) [ sql-file? ] filter ;

! cassandra
: cql-file? ( path -- ? ) >lower file-extension { "cql" "db" } member? ;
: cql-files ( paths -- paths' ) [ cql-file? ] filter ;

: ignore-file? ( path -- ? ) >lower file-name { [ "." head? ] [ "ignore" tail? ] } 1&& ;
: ignore-files ( paths -- paths' ) [ ignore-file? ] filter ;

: has-package-json? ( path -- ? ) "package.json" append-path file-exists? ;
: uses-git? ( path -- ? ) ".git" append-path file-exists? ;
: uses-repo? ( path -- ? ) ".repo" append-path file-exists? ;

: diff-paths ( paths quot -- paths' )
    guard [ [ normalize-path ] map ] bi@ diff ; inline

: source-code-file? ( path -- ? )
    {
        [ c-file? ]
        [ c-header-file? ]
        [ cpp-file? ]
        [ cpp-header-file? ]
        [ erlang-file? ]
        [ factor-file? ]
        [ python-file? ]
        [ python-packaging-file? ]
        [ rust-file? ]
        [ java-file? ]
        [ javascript-file? ]
        [ css-file? ]
        [ html-file? ]
        [ shell-file? ]
        [ sql-file? ]
        [ cql-file? ]
    } 1|| ;
: source-code-files ( paths -- paths' ) [ source-code-file? ] filter ;

: meta-files ( paths -- paths' )
    [
        {
            [ github-files ]
            [ license-files ]
            [ readme-files ]
            [ owners-files ]
            [ codenotify-files ]
            [ contributing-files ]
            [ changelog-files ]
            [ authors-files ]
            [ ideas-files ]
            [ testing-files ]
            [ copying-files ]
            [ copyright-files ]
            [ codeowners-files ]
            [ contributors-files ]
            [ patents-files ]
            [ release-files ]
            [ install-files ]
            [ security-files ]
            [ notice-files ]
            [ version-files ]
            [ citation-files ]
            [ python-packaging-files ]
        } cleave
    ] { } append-outputs-as ;

: assoc. ( assoc -- )
    [ commas ] map-values simple-table. ;

: analyze-codebase-path ( path -- )
    {
        [ normalize-path "project at path `%s`" sprintf print ]
        [ uses-git? [ "uses git" print ] when ]
        [ uses-repo? [ "uses repo" print ] when ]
        [ has-package-json? [ "has a package.json file" print ] when ]
    } cleave ;

: file. ( path -- ) >pathname bl bl ... ;
: files. ( paths -- ) [ file. ] each ;

: file-counts. ( paths -- )
    [ file-extension ] collect-by
    [ length ] map-values
    inv-sort-values
    [ number>string ": " glue bl bl print ] assoc-each ;

: source-files-usage ( paths -- )
    {
        [ c-files [ sort "has c files" print file-counts. ] unless-empty ]
        [ c-header-files [ sort "has c header files" print file-counts. ] unless-empty ]
        [ cpp-files [ sort "has c++ files" print file-counts. ] unless-empty ]
        [ cpp-header-files [ sort "has c++ header files" print file-counts. ] unless-empty ]
        [ erlang-files [ sort "has erlang files" print file-counts. ] unless-empty ]
        [ factor-files [ sort "has factor files" print file-counts. ] unless-empty ]
        [ python-files [ sort "has python files" print file-counts. ] unless-empty ]
        [ python-packaging-files [ sort "has python packaging files" print file-counts. ] unless-empty ]
        [ rust-files [ sort "has rust files" print file-counts. ] unless-empty ]
        [ java-files [ sort "has java files" print file-counts. ] unless-empty ]
        [ javascript-files [ sort "has javascript files" print file-counts. ] unless-empty ]
        [ css-files [ sort "has css files" print file-counts. ] unless-empty ]
        [ html-files [ sort "has html files" print file-counts. ] unless-empty ]
        [ shell-files [ sort "has shell files" print file-counts. ] unless-empty ]
        [ doc-files [ sort "has doc files" print file-counts. ] unless-empty ]
        [ citation-files [ sort "has citation files" print file-counts. ] unless-empty ]
        [ sql-files [ sort "has sql files" print file-counts. ] unless-empty ]
        [ cql-files [ sort "has cassandra files" print file-counts. ] unless-empty ]
    } cleave ;

: analyze-codebase-paths ( paths -- )
    {
        [
            partition-binary
            [ length "%d binary files" sprintf print ]
            [ length "%d text files" sprintf print ] bi*
        ]
        [ github-files [ sort "has .github files" print files. ] unless-empty ]
        [ license-files [ sort [ length "has %d license files" sprintf print ] [ files. ] bi ] unless-empty ]
        [ readme-files [ sort "has readme files" print files. ] unless-empty ]
        [ owners-files [ sort "has owners files" print files. ] unless-empty ]
        [ codenotify-files [ sort "has codenotify files" print files. ] unless-empty ]
        [ contributing-files [ sort "has contributing files" print files. ] unless-empty ]
        [ changelog-files [ sort "has changelog files" print files. ] unless-empty ]
        [ release-files [ sort "has release files" print files. ] unless-empty ]
        [ authors-files [ sort "has authors files" print files. ] unless-empty ]
        [ contributors-files [ sort "has contributors files" print files. ] unless-empty ]
        [ patents-files [ sort "has patents files" print files. ] unless-empty ]
        [ ideas-files [ sort "has ideas files" print files. ] unless-empty ]
        [ testing-files [ sort "has testing files" print files. ] unless-empty ]
        [ copying-files [ sort "has copying files" print files. ] unless-empty ]
        [ copyright-files [ sort "has copyright files" print files. ] unless-empty ]
        [ citation-files [ sort "has citation files" print files. ] unless-empty ]
        [ security-files [ sort "has security files" print files. ] unless-empty ]
        [ notice-files [ sort "has notice files" print files. ] unless-empty ]
        [ version-files [ sort "has version files" print files. ] unless-empty ]
        [
            { [ dot-files ] [ rc-files diff ] [ ignore-files diff ] } cleave
            [ sort "has dot files" print files. ] unless-empty
        ]
        [ rc-files [ sort [ length "has %d rc files" sprintf print ] [ files. ] bi ] unless-empty ]
        [ configure-files [ sort "uses configure files" print files. ] unless-empty ]
        [ automake-files [ sort "uses automake" print files. ] unless-empty ]
        [ make-files [ sort "uses make" print files. ] unless-empty ]
        [ nmake-files [ sort "uses nmake" print files. ] unless-empty ]
        [ cmake-files [ sort "uses cmake" print files. ] unless-empty ]
        [ meson-files [ sort "uses meson" print files. ] unless-empty ]
        [ docker-files [ sort "uses docker" print files. ] unless-empty ]
        [ gradle-files [ sort "uses gradle" print files. ] unless-empty ]
        [ cargo-files [ sort "uses rust/cargo" print files. ] unless-empty ]
        [ julia-project-files [ sort "uses julia Project.toml" print files. ] unless-empty ]
        [ in-files [ sort "uses 'in' files" print files. ] unless-empty ]
        [ ignore-files [ sort [ length "has %d ignore files" sprintf print ] [ files. ] bi ] unless-empty ]
        [ [ rust-project-dir? ] filter [ [ "rust projects at " print files. ] [ [ analyze-rust-project ] each ] bi ] unless-empty ]
        [
            [ upper-files ] keep meta-files diff
            [ sort [ length "has %d UPPER files (minus meta files)" sprintf print ] [ files. ] bi ] unless-empty
        ]
        [ source-files-usage ]
        [ "Top 20 largest files" print file-sizes sort-values 20 index-or-length tail* [ normalize-path ] map-keys reverse assoc. ]
        [ "Top 10 file extension sizes" print sum-sizes-by-extension 10 index-or-length tail* reverse assoc. ]
        [ "Top 10 text file line counts" print sum-line-counts-by-extension 10 index-or-length tail* reverse assoc. ]
        [ "Top 10 file extension counts" print count-by-file-extension 10 index-or-length tail* reverse assoc. ]
        [ "All file extension sizes" print sum-sizes-by-extension reverse assoc. ]
        [ "All text file line counts" print sum-line-counts-by-extension reverse assoc. ]
        [ "All file extension counts" print count-by-file-extension reverse assoc. ]
    } cleave ;

: analyze-codebase ( path -- )
    [ analyze-codebase-path ]
    [ codebase-paths analyze-codebase-paths ] bi ;

: analyze-codebases ( path -- )
    [ directory-files ] keep [ prepend-path ] curry map
    [ file-info directory? ] filter
    [ analyze-codebase ] each ;
