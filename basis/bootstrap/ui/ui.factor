USING: alien namespaces system combinators kernel sequences
vocabs ;
IN: bootstrap.ui

"bootstrap.math" require
"bootstrap.compiler" require
"bootstrap.threads" require

! Use GTK3 on 32-bit x86 and RISC-V Linux.
"ui-backend" get [
    "ui.backend." prepend
] [
    {
        { [ os macos? ] [ "ui.backend.cocoa" ] }
        { [ os windows? ] [ "ui.backend.windows" ] }
        { [ os unix? ] [ os linux? cpu x86.32? cpu riscv.32? or and "ui.backend.gtk3" "ui.backend.gtk4" ? ] }
    } cond
] if* require
