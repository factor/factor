;; Per-directory local variables for GNU Emacs 23 and later.
((c++-mode . ((c-basic-offset . 2)
              (show-trailing-whitespace . t)
              (indicate-empty-lines . t)
              (indent-tabs-mode . nil)
              (eval . (progn
                        (c-set-offset 'innamespace 0)
                        (c-set-offset 'topmost-intro 0)
                        (c-set-offset 'cpp-macro-cont '++)
                        (c-set-offset 'case-label '+)
                        (c-set-offset 'member-init-intro '++)
                        (c-set-offset 'statement-cont '++)
                        (c-set-offset 'arglist-intro '++)))))
 (factor-mode . ((factor-block-offset . 4))))
