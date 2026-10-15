! Repair pre-cbec8c668e s390x checkpoints without rebuilding a cold image.
! Build s390x_context_upgrade.c as libcontext-upgrade.so in the current directory.
USING: alien.libraries.unix arrays compiler.units namespaces parser.notes ;
<< f parser-quiet? set-global \ (dlerror) 1array compile >>
USING: accessors alien alien.c-types alien.libraries alien.syntax
combinators grouping io io.pathnames kernel math memory prettyprint
sequences sequences.generalizations system threads.private words ;
IN: s390x.context.upgrade

<< "s390x-context-upgrade" "./libcontext-upgrade.so" absolute-path
   cdecl add-library >>
LIBRARY: s390x-context-upgrade
FUNCTION: size_t patch_context_code ( void* address, size_t length )

cpu name>> "s390x" = [
    0 { (set-context) (set-context-and-delete) } [
        sub-primitive>> third second dup length patch_context_code +
    ] each "Context templates repaired: " write .
    "(code-blocks)" "tools.memory.private" lookup-word execute
    6 <groups> 0 swap [
        [ 5 swap nth 4 shift <alien> ] [ 4 swap nth 32 - ] bi patch_context_code +
    ] each "Generated context sequences repaired: " write .
] when
