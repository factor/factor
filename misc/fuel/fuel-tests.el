;;; fuel-tests.el -- unit tests for fuel

;; Copyright (C) 2014 Björn Lindqvist
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Björn Lindqvist <bjourne@gmail.com>
;; Keywords: languages, fuel, factor
;; Start date: Sat Nov 01, 2014

;;; Commentary:

;; Run the test suite using M-x ert RET t RET or:
;;
;;     emacs -batch -l ert -l misc/fuel/fuel-tests.el \
;;         -f ert-run-tests-batch-and-exit

;;; Code:

;; Load fuel from the same directory the tests are in.
(add-to-list 'load-path (file-name-directory load-file-name))

(require 'ert)
(require 'fuel-markup)

;; fuel-markup
(ert-deftest print-str ()
  (should (equal (fuel-markup--print-str "hello") "hello")))

(ert-deftest quotation ()
  (let ((quot '($quotation (effect ("args" "kw") ("ret") nil nil nil))))
    (should (equal
             (with-temp-buffer
               (fuel-markup--quotation quot)
               (buffer-string))
             "a quotation with stack effect ( args kw -- ret )"))))
