;; Optional reproducible Guix environment:
;; guix time-machine -C channels.scm -- shell -m manifest.scm
(list (channel
       (name 'guix)
       (url "https://git.guix.gnu.org/guix.git")
       (commit "d58da8a56b75af73a7b5466f7ef8a81679713aa3")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D E643 A2A0 6DF2 A33A 54FA")))))
