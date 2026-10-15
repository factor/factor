USING: alien bootstrap.ui.platform kernel namespaces sequences system vocabs ;
IN: bootstrap.ui

"bootstrap.math" require
"bootstrap.compiler" require
"bootstrap.threads" require

! GTK4 has a restricted architecture set; use GTK3 on the other Linux CPUs.
! Other Unix systems use their established GTK3 or GTK2 backend.
"ui-backend" get [
    "ui.backend." prepend
] [
    os cpu default-ui-backend
] if* require
