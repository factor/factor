USING: kernel vocabs vocabs.loader sequences namespaces parser ;

{
    "bootstrap.image"
    "tools.annotations"
    "tools.crossref"
    "tools.deploy"
    "tools.memory"
    "tools.test"
    "tools.time"
    "tools.walker"
    "editors"
} dup [ require ] each

global [ add-use ] bind

"bootstrap.compiler" vocab [
    "tools.profiler" dup require use+
] when
