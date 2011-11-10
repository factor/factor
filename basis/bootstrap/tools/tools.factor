USING: vocabs sequences system combinators ;
IN: bootstrap.tools

{
    "editors"
    "inspector"
    "bootstrap.image"
    "see"
    "tools.annotations"
    "tools.crossref"
    "tools.errors"
    "tools.deploy"
    "tools.destructors"
    "tools.disassembler"
    "tools.dispatch"
    "tools.memory"
    "tools.profiler.sampling"
    "tools.test"
    "tools.time"
    "tools.threads"
    "tools.deprecation"
    "vocabs.hierarchy"
    "vocabs.refresh"
    "vocabs.refresh.monitor"
} [ require ] each

{
    { [ os windows? ] [ "debugger.windows" require ] }
    { [ os unix? ] [ "debugger.unix" require ] }
} cond
