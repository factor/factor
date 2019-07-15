USING: compiler.tree.builder compiler.tree.locals compiler.tree.optimizer kernel
kernel.private locals math namespaces prettyprint ;

IN: compiler.tree.locals.tests

! Running this should be able to infer output interval
: test1. ( -- )
t track-local-infos [
        [let 45 :> x! [ { fixnum } declare x + dup x! ] ] build-tree optimize-tree ...
        local-infos get . ] with-variable ;

! Running this should show empty return type
: test2. ( -- )
    t track-local-infos [
        [let t :> x! [ { fixnum } declare x + dup x! ] ] build-tree optimize-tree ...
        local-infos get . ] with-variable ;

: test3. ( -- )
t track-local-infos [
        [let t :> x! [ 42 x! x { fixnum fixnum } declare + dup x! ] ] build-tree optimize-tree ...
        local-infos get . ] with-variable ;
