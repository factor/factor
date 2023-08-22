;;; fuel-tests.el -- unit tests for fuel -*- lexical-binding: t -*-

;; Copyright (C) 2014 Björn Lindqvist
;; See https://factorcode.org/license.txt for BSD license.

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
(require 'fuel-help)
(require 'fuel-markup)
(require 'fuel-xref)

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

;; fuel-help
(ert-deftest find-in-w/vocabulary ()
  (should (equal
           (with-temp-buffer
             (insert "Vocabulary: imap")
             (fuel-help--find-in))
           "imap")))

(ert-deftest find-in-w/buffer-link ()
  (should (equal
           (with-temp-buffer
             (setq fuel-help--buffer-link '("foob" "foob" vocab))
             (insert "Help page contents")
             (fuel-help--find-in))
           "foob")))

;; fuel-xref
(ert-deftest fuel-xref-name ()
  (should (equal (buffer-name (fuel-xref--buffer)) "*fuel xref*")))
