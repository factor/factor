;;; factor-smie.el --- Helper function for indenting factor code

;; Copyright (C) 2016  Björn Lindqvist
;; See https://factorcode.org/license.txt for BSD license.

;;; Commentary:

;; Factor indentation using the SMIE framework.

;;; Code:
(require 'smie)

(defcustom factor-block-offset 4
  "Indentation of Factor statements."
  :type 'integer
  :safe 'integerp
  :group 'factor)

;; These prefixes starts a definition and causes the indent-level to
;; increase.
(defconst factor-indent-def-starts
  '("" ":"
    "AFTER" "BEFORE"
    "COM-INTERFACE" "CONSULT"
    "ENUM" "ERROR"
    "FROM"
    "GLSL-PROGRAM"
    "IDENTITY-MEMO" "INTERSECTION"
    "M" "M:" "MACRO" "MACRO:"
    "MAIN-WINDOW" "MEMO" "MEMO:" "METHOD"
    "SYNTAX"
    "PREDICATE" "PROTOCOL"
    "SINGLETONS"
    "STRUCT" "SYMBOLS" "TAG" "TUPLE"
    "TYPED" "TYPED:"
    "UNIFORM-TUPLE"
    "UNION-STRUCT" "UNION"
    "VARIANT" "VERTEX-FORMAT"))

;; These prefixes starts a definition but does not cause the indent
;; level to increase.
(defconst factor-no-indent-def-starts
  '("ARTICLE"
    "FUNCTION" "FUNCTION-ALIAS"
    "HELP"
    "PRIMITIVE"
    "SPECIALIZED-ARRAYS"))

(defconst factor-indent-def-regex
  (format "^\\(%s:\\)$" (regexp-opt factor-indent-def-starts)))

(defconst factor-smie-grammar
  (smie-prec2->grammar
   (smie-bnf->prec2
    '(
      (exp (":" exp ";"))
      ))))

(defun factor-smie-rules (kind token)
  (pcase (cons kind token)
    (`(:before . ";") factor-block-offset)
    (`(:list-intro . ,_) t)
    ))

(defun factor-smie-token (dir)
  (pcase dir
    (`forward (forward-comment (point-max)))
    (`backward (forward-comment (- (point)))))
  (let ((tok (buffer-substring-no-properties
              (point)
              (let ((syntax "w_\\\""))
                (pcase dir
                  (`forward (skip-syntax-forward syntax))
                  (`backward (skip-syntax-backward syntax)))
                (point)))))
    ;; Token normalization. This way we only need one rule in
    ;; factor-smie-grammar.
    (cond ((string-match factor-indent-def-regex tok) ":")
          (t tok))))

(defun factor-smie-forward-token ()
  (factor-smie-token 'forward))

(defun factor-smie-backward-token ()
  (factor-smie-token 'backward))

(defun factor-smie-indent ()
  (unless (looking-at ";\\_>")
    (save-excursion
      (let ((x nil))
        (while (progn (setq x (smie-backward-sexp))
                      (null (car-safe x))))
        (when (string-match factor-indent-def-regex
                            (or (nth 2 x) ""))
          (goto-char (nth 1 x))
          (+ factor-block-offset (smie-indent-virtual)))))))

(provide 'factor-smie)

;;; factor-smie.el ends here
