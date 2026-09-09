! Untimed memory snapshots; address-bearing installed code is not a portable hash.
USING: alien alien.data allocator-runtime-comparison arrays assocs
compiler-next.code-capture kernel locals math namespaces sequences words ;
IN: compiler-next.code-capture
:: capture-installed ( phase -- )
    captured-targets get [| target |
        target word-code :> ( start end )
        start <alien> end start - memory>byte-array >array :> bytes
        H{ { "kind" "installed-code" } { "phase" phase }
           { "word" target word-id } { "start-address" start }
           { "code-bytes" bytes } } emit
    ] each ;
