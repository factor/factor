USING: gtk2.ffi kernel tools.test vocabs.loader words ;
IN: gtk2.ffi.tests

! Callers compiled before reload must still refer to the corrected binding.
{ t } [
    \ gtk_im_context_get_preedit_string
    "gtk2.ffi" reload
    dup target-word eq?
] unit-test
