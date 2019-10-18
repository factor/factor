;;; fuel-syntax.el --- auxiliar definitions for factor code navigation.

;; Copyright (C) 2008, 2009  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Commentary:

;; Auxiliar constants and functions to parse factor code.

;;; Code:

(require 'thingatpt)


;;; Thing-at-point support for factor symbols:

(defun fuel-syntax--beginning-of-symbol ()
  "Move point to the beginning of the current symbol."
  (skip-syntax-backward "w_()"))

(defsubst fuel-syntax--beginning-of-symbol-pos ()
  (save-excursion (fuel-syntax--beginning-of-symbol) (point)))

(defun fuel-syntax--end-of-symbol ()
  "Move point to the end of the current symbol."
  (skip-syntax-forward "w_()"))

(defsubst fuel-syntax--end-of-symbol-pos ()
  (save-excursion (fuel-syntax--end-of-symbol) (point)))

(put 'factor-symbol 'end-op 'fuel-syntax--end-of-symbol)
(put 'factor-symbol 'beginning-op 'fuel-syntax--beginning-of-symbol)

(defsubst fuel-syntax-symbol-at-point ()
  (let ((s (substring-no-properties (thing-at-point 'factor-symbol))))
    (and (> (length s) 0) s)))



;;; Regexps galore:

(defconst fuel-syntax--parsing-words
  '(":" "::" ";" "&:" "<<" "<PRIVATE" ">>"
    "ABOUT:" "ALIAS:" "ALIEN:" "ARTICLE:"
    "B" "BIN:"
    "C:" "CALLBACK:" "C-ENUM:" "C-STRUCT:" "C-TYPE:" "C-UNION:" "CHAR:" "CONSTANT:" "call-next-method"
    "DEFER:"
    "EBNF:" ";EBNF" "ERROR:" "EXCLUDE:"
    "f" "FORGET:" "FROM:" "FUNCTION:"
    "GAME:" "GENERIC#" "GENERIC:"
    "GLSL-SHADER:" "GLSL-PROGRAM:"
    "HELP:" "HEX:" "HOOK:"
    "IN:" "initial:" "INSTANCE:" "INTERSECTION:"
    "LIBRARY:"
    "M:" "M::" "MACRO:" "MACRO::" "MAIN:" "MATH:"
    "MEMO:" "MEMO:" "METHOD:" "MIXIN:"
    "OCT:"
    "POSTPONE:" "PREDICATE:" "PRIMITIVE:" "PRIVATE>" "PROVIDE:"
    "QUALIFIED-WITH:" "QUALIFIED:"
    "read-only" "RENAME:" "REQUIRE:"  "REQUIRES:"
    "SINGLETON:" "SINGLETONS:" "SLOT:" "SPECIALIZED-ARRAY:" "SPECIALIZED-ARRAYS:" "STRING:" "STRUCT:" "SYMBOL:" "SYMBOLS:" "SYNTAX:"
    "TUPLE:" "t" "t?" "TYPEDEF:" "TYPED:" "TYPED::"
    "UNIFORM-TUPLE:" "UNION:" "USE:" "USING:"
    "VARS:" "VERTEX-FORMAT:"))

(defconst fuel-syntax--parsing-words-regex
  (regexp-opt fuel-syntax--parsing-words 'words))

(defconst fuel-syntax--bracers
  '("B" "BV" "C" "CS" "H" "T" "V" "W"))

(defconst fuel-syntax--brace-words-regex
  (format "%s{" (regexp-opt fuel-syntax--bracers t)))

(defconst fuel-syntax--declaration-words
  '("flushable" "foldable" "inline" "parsing" "recursive" "delimiter"))

(defconst fuel-syntax--declaration-words-regex
  (regexp-opt fuel-syntax--declaration-words 'words))

(defsubst fuel-syntax--second-word-regex (prefixes)
  (format "%s +\\([^ \r\n]+\\)" (regexp-opt prefixes t)))

(defconst fuel-syntax--method-definition-regex
  "^M::? +\\([^ ]+\\) +\\([^ ]+\\)")

(defconst fuel-syntax--integer-regex
  "\\_<-?[0-9]+\\_>")

(defconst fuel-syntax--raw-float-regex
  "[0-9]*\\.[0-9]*\\([eE][+-]?[0-9]+\\)?")

(defconst fuel-syntax--float-regex
  (format "\\_<-?%s\\_>" fuel-syntax--raw-float-regex))

(defconst fuel-syntax--number-regex
  (format "\\([0-9]+\\|%s\\)" fuel-syntax--raw-float-regex))

(defconst fuel-syntax--ratio-regex
  (format "\\_<[+-]?%s/-?%s\\_>"
          fuel-syntax--number-regex
          fuel-syntax--number-regex))

(defconst fuel-syntax--bad-string-regex
  "\\_<\"[^>]\\([^\"\n]\\|\\\\\"\\)*\n")

(defconst fuel-syntax--word-definition-regex
  (format "\\_<\\(%s\\)?: +\\_<\\(\\w+\\)\\_>"
          (regexp-opt
           '(":" "GENERIC" "DEFER" "HOOK" "MAIN" "MATH" "POSTPONE"
             "SYMBOL" "SYNTAX" "TYPED" "RENAME"))))

(defconst fuel-syntax--alias-definition-regex
  "^ALIAS: +\\(\\_<.+?\\_>\\) +\\(\\_<.+?\\_>\\)")

(defconst fuel-syntax--vocab-ref-regexp
  (fuel-syntax--second-word-regex
   '("IN:" "USE:" "FROM:" "EXCLUDE:" "QUALIFIED:" "QUALIFIED-WITH:")))

(defconst fuel-syntax--int-constant-def-regex
  (fuel-syntax--second-word-regex '("ALIEN:" "CHAR:" "BIN:" "HEX:" "OCT:")))

(defconst fuel-syntax--type-definition-regex
  (fuel-syntax--second-word-regex
   '("C-STRUCT:" "C-UNION:" "MIXIN:" "TUPLE:" "SINGLETON:" "SPECIALIZED-ARRAY:" "STRUCT:" "UNION:")))

(defconst fuel-syntax--tuple-decl-regex
  "^TUPLE: +\\([^ \n]+\\) +< +\\([^ \n]+\\)\\_>")

(defconst fuel-syntax--constructor-regex "<[^ >]+>")

(defconst fuel-syntax--getter-regex "\\(^\\|\\_<\\)[^ ]+?>>\\_>")
(defconst fuel-syntax--setter-regex "\\_<>>.+?\\_>")

(defconst fuel-syntax--symbol-definition-regex
  (fuel-syntax--second-word-regex '("&:" "SYMBOL:" "VAR:")))

(defconst fuel-syntax--stack-effect-regex
  "\\( ( [^\n]* )\\)\\|\\( (( [^\n]* ))\\)")

(defconst fuel-syntax--using-lines-regex "^USING: +\\([^;]+\\);")

(defconst fuel-syntax--use-line-regex "^USE: +\\(.*\\)$")

(defconst fuel-syntax--current-vocab-regex "^IN: +\\([^ \r\n\f]+\\)")

(defconst fuel-syntax--sub-vocab-regex "^<\\([^ \n]+\\) *$")

(defconst fuel-syntax--alien-function-regex
  "\\_<FUNCTION: \\(\\w+\\) \\(\\w+\\)")

(defconst fuel-syntax--alien-callback-regex
  "\\_<CALLBACK: \\(\\w+\\) \\(\\w+\\)")

(defconst fuel-syntax--indent-def-starts '("" ":"
                                           "C-ENUM" "C-STRUCT" "C-UNION"
                                           "FROM" "FUNCTION:"
                                           "INTERSECTION:"
                                           "M" "M:" "MACRO" "MACRO:"
                                           "MEMO" "MEMO:" "METHOD"
                                           "SYNTAX"
                                           "PREDICATE" "PRIMITIVE"
                                           "STRUCT" "TAG" "TUPLE"
                                           "TYPED" "TYPED:"
                                           "UNIFORM-TUPLE"
                                           "UNION-STRUCT" "UNION"
                                           "VERTEX-FORMAT"))

(defconst fuel-syntax--no-indent-def-starts '("ARTICLE"
                                              "HELP"
                                              "SINGLETONS"
                                              "SPECIALIZED-ARRAYS"
                                              "SYMBOLS"
                                              "VARS"))

(defconst fuel-syntax--indent-def-start-regex
  (format "^\\(%s:\\)\\( \\|\n\\)" (regexp-opt fuel-syntax--indent-def-starts)))

(defconst fuel-syntax--definition-start-regex
  (format "^\\(%s:\\) " (regexp-opt (append fuel-syntax--no-indent-def-starts
                                            fuel-syntax--indent-def-starts))))

(defconst fuel-syntax--definition-end-regex
  (format "\\(\\(^\\| +\\);\\( *%s\\)*\\($\\| +\\)\\)"
          fuel-syntax--declaration-words-regex))

(defconst fuel-syntax--single-liner-regex
  (regexp-opt '("ABOUT:"
                "ALIAS:"
                "CONSTANT:" "C:" "C-TYPE:"
                "DEFER:"
                "FORGET:"
                "GAME:" "GENERIC:" "GENERIC#" "GLSL-PROGRAM:" 
                "HEX:" "HOOK:"
                "IN:" "INSTANCE:"
                "LIBRARY:"
                "MAIN:" "MATH:" "MIXIN:"
                "OCT:"
                "POSTPONE:" "PRIVATE>" "<PRIVATE"
                "QUALIFIED-WITH:" "QUALIFIED:"
                "RENAME:"
                "SINGLETON:" "SLOT:" "SPECIALIZED-ARRAY:" "SYMBOL:"
                "TYPEDEF:"
                "USE:"
                "VAR:")))

(defconst fuel-syntax--begin-of-def-regex
  (format "^USING: \\|\\(%s\\)\\|\\(^%s .*\\)"
          fuel-syntax--definition-start-regex
          fuel-syntax--single-liner-regex))

(defconst fuel-syntax--end-of-def-line-regex
  (format "^.*%s" fuel-syntax--definition-end-regex))

(defconst fuel-syntax--end-of-def-regex
  (format "\\(%s\\)\\|\\(^%s .*\\)"
          fuel-syntax--end-of-def-line-regex
          fuel-syntax--single-liner-regex))

(defconst fuel-syntax--word-signature-regex
  (format ":[^ ]* \\([^ ]+\\)\\(%s\\)*" fuel-syntax--stack-effect-regex))

(defconst fuel-syntax--defun-signature-regex
  (format "\\(%s\\|%s\\)"
          fuel-syntax--word-signature-regex
          "M[^:]*: [^ ]+ [^ ]+"))

(defconst fuel-syntax--constructor-decl-regex
  "\\_<C: +\\(\\w+\\) +\\(\\w+\\)\\( .*\\)?$")

(defconst fuel-syntax--typedef-regex
  "\\_<TYPEDEF: +\\(\\w+\\) +\\(\\w+\\)\\( .*\\)?$")

(defconst fuel-syntax--rename-regex
  "\\_<RENAME: +\\(\\w+\\) +\\(\\w+\\) +=> +\\(\\w+\\)\\( .*\\)?$")


;;; Factor syntax table

(setq fuel-syntax--syntax-table
  (let ((table (make-syntax-table)))
    ;; Default is word constituent
    (dotimes (i 256)
      (modify-syntax-entry i "w" table))
    ;; Whitespace (TAB is not whitespace)
    (modify-syntax-entry ?\f " " table)
    (modify-syntax-entry ?\r " " table)
    (modify-syntax-entry ?\  " " table)
    (modify-syntax-entry ?\n " " table)
    table))

(defconst fuel-syntax--syntactic-keywords
  `(;; Strings and chars
    ("\\_<<\\(\"\\)\\_>" (1 "<b"))
    ("\\_<\\(\"\\)>\\_>" (1 ">b"))
    ("\\( \\|^\\)\\(DLL\\|P\\|SBUF\\)?\\(\"\\)\\(\\([^\n\r\f\"\\]\\|\\\\.\\)*\\)\\(\"\\)"
     (3 "\"") (6 "\""))
    ("CHAR: \\(\"\\) [^\\\"]*?\\(\"\\)\\([^\\\"]\\|\\\\.\\)*?\\(\"\\)"
     (1 "w") (2 "<b") (4 ">b"))
    ("\\(CHAR:\\|\\\\\\) \\(\\w\\|!\\)\\( \\|$\\)" (2 "w"))
    ;; Comments
    ("\\_<\\(#?!\\) .*\\(\n\\|$\\)" (1 "<") (2 ">"))
    ("\\_<\\(#?!\\)\\(\n\\|$\\)" (1 "<") (2 ">"))
    ;; postpone
    ("\\_<POSTPONE:\\( \\).*\\(\n\\)" (1 "<b") (2 ">b"))
    ;; Multiline constructs
    ("\\_<\\(E\\)BNF:\\( \\|\n\\)" (1 "<b"))
    ("\\_<;EBN\\(F\\)\\_>" (1 ">b"))
    ("\\_<\\(U\\)SING: \\(;\\)" (1 "<b") (2 ">b"))
    ("\\_<USING:\\( \\)" (1 "<b"))
    ("\\_<\\(C\\)-ENUM: \\(;\\)" (1 "<b") (2 ">b"))
    ("\\_<C-ENUM:\\( \\|\n\\)" (1 "<b"))
    ("\\_<TUPLE: +\\w+? +< +\\w+? *\\( \\|\n\\)\\([^;]\\|$\\)" (1 "<b"))
    ("\\_<TUPLE: +\\w+? *\\( \\|\n\\)\\([^;<\n]\\|\\_>\\)" (1 "<b"))
    ("\\_<\\(SYMBOLS\\|VARS\\|SPECIALIZED-ARRAYS\\|SINGLETONS\\): *?\\( \\|\n\\)\\([^;\n]\\|\\_>\\)"
     (2 "<b"))
    ("\\(\n\\| \\);\\_>" (1 ">b"))
    ;; Let and lambda:
    ("\\_<\\(!(\\) .* \\()\\)" (1 "<") (2 ">"))
    ("\\(\\[\\)\\(let\\|let\\*\\)\\( \\|$\\)" (1 "(]"))
    ("\\(\\[\\)\\(|\\) +[^|]* \\(|\\)" (1 "(]") (2 "(|") (3 ")|"))
    (" \\(|\\) " (1 "(|"))
    (" \\(|\\)$" (1 ")"))
    ;; Opening brace words:
    ("\\_<\\w*\\({\\)\\_>" (1 "(}"))
    ("\\_<\\(}\\)\\_>" (1 "){"))
    ;; Parenthesis:
    ("\\_<\\((\\)\\_>" (1 "()"))
    ("\\_<\\w*\\((\\)\\_>" (1 "()"))
    ("\\_<\\()\\)\\_>" (1 ")("))
    ("\\_<(\\((\\)\\_>" (1 "()"))
    ("\\_<\\()\\))\\_>" (1 ")("))
    ;; Quotations:
    ("\\_<'\\(\\[\\)\\_>" (1 "(]"))      ; fried
    ("\\_<$\\(\\[\\)\\_>" (1 "(]"))      ; parse-time
    ("\\_<\\(\\[\\)\\_>" (1 "(]"))
    ("\\_<\\(\\]\\)\\_>" (1 ")["))))


;;; Source code analysis:

(defsubst fuel-syntax--brackets-depth ()
  (nth 0 (syntax-ppss)))

(defsubst fuel-syntax--brackets-start ()
  (nth 1 (syntax-ppss)))

(defun fuel-syntax--brackets-end ()
  (save-excursion
    (goto-char (fuel-syntax--brackets-start))
    (condition-case nil
        (progn (forward-sexp)
               (1- (point)))
      (error -1))))

(defsubst fuel-syntax--indentation-at (pos)
  (save-excursion (goto-char pos) (current-indentation)))

(defsubst fuel-syntax--increased-indentation (&optional i)
  (+ (or i (current-indentation)) factor-indent-width))
(defsubst fuel-syntax--decreased-indentation (&optional i)
  (- (or i (current-indentation)) factor-indent-width))

(defsubst fuel-syntax--at-begin-of-def ()
  (looking-at fuel-syntax--begin-of-def-regex))

(defsubst fuel-syntax--at-begin-of-indent-def ()
  (looking-at fuel-syntax--indent-def-start-regex))

(defsubst fuel-syntax--at-end-of-def ()
  (looking-at fuel-syntax--end-of-def-regex))

(defsubst fuel-syntax--looking-at-emptiness ()
  (looking-at "^[ ]*$\\|$"))

(defsubst fuel-syntax--is-last-char (pos)
  (save-excursion
    (goto-char (1+ pos))
    (looking-at-p "[ ]*$")))

(defsubst fuel-syntax--line-offset (pos)
  (- pos (save-excursion
           (goto-char pos)
           (beginning-of-line)
           (point))))

(defun fuel-syntax--previous-non-blank ()
  (forward-line -1)
  (while (and (not (bobp)) (fuel-syntax--looking-at-emptiness))
    (forward-line -1)))

(defun fuel-syntax--beginning-of-block-pos ()
  (save-excursion
    (if (> (fuel-syntax--brackets-depth) 0)
        (fuel-syntax--brackets-start)
      (fuel-syntax--beginning-of-defun)
      (point))))

(defun fuel-syntax--at-setter-line ()
  (save-excursion
    (beginning-of-line)
    (when (re-search-forward fuel-syntax--setter-regex
                             (line-end-position)
                             t)
      (let* ((to (match-beginning 0))
             (from (fuel-syntax--beginning-of-block-pos)))
        (goto-char from)
        (let ((depth (fuel-syntax--brackets-depth)))
          (and (or (re-search-forward fuel-syntax--constructor-regex to t)
                   (re-search-forward fuel-syntax--setter-regex to t))
               (= depth (fuel-syntax--brackets-depth))))))))

(defun fuel-syntax--at-constructor-line ()
  (save-excursion
    (beginning-of-line)
    (re-search-forward fuel-syntax--constructor-regex (line-end-position) t)))

(defsubst fuel-syntax--at-using ()
  (looking-at fuel-syntax--using-lines-regex))

(defun fuel-syntax--in-using ()
  (let ((p (point)))
    (save-excursion
      (and (re-search-backward "^USING: " nil t)
           (re-search-forward " ;" nil t)
           (< p (match-end 0))))))

(defsubst fuel-syntax--beginning-of-defun (&optional times)
  (re-search-backward fuel-syntax--begin-of-def-regex nil t times))

(defsubst fuel-syntax--end-of-defun ()
  (re-search-forward fuel-syntax--end-of-def-regex nil t))

(defsubst fuel-syntax--end-of-defun-pos ()
  (save-excursion
    (re-search-forward fuel-syntax--end-of-def-regex nil t)
    (point)))

(defun fuel-syntax--beginning-of-body ()
  (let ((p (point)))
    (and (fuel-syntax--beginning-of-defun)
         (re-search-forward fuel-syntax--defun-signature-regex p t)
         (not (re-search-forward fuel-syntax--end-of-def-regex p t)))))

(defun fuel-syntax--beginning-of-sexp ()
  (if (> (fuel-syntax--brackets-depth) 0)
      (goto-char (fuel-syntax--brackets-start))
    (fuel-syntax--beginning-of-body)))

(defsubst fuel-syntax--beginning-of-sexp-pos ()
  (save-excursion (fuel-syntax--beginning-of-sexp) (point)))


;;; USING/IN:

(make-variable-buffer-local
 (defvar fuel-syntax--current-vocab-function 'fuel-syntax--find-in))

(defsubst fuel-syntax--current-vocab ()
  (funcall fuel-syntax--current-vocab-function))

(defun fuel-syntax--find-in ()
  (save-excursion
    (when (re-search-backward fuel-syntax--current-vocab-regex nil t)
      (match-string-no-properties 1))))

(make-variable-buffer-local
 (defvar fuel-syntax--usings-function 'fuel-syntax--find-usings))

(defsubst fuel-syntax--usings ()
  (funcall fuel-syntax--usings-function))

(defun fuel-syntax--file-has-private ()
  (save-excursion
    (goto-char (point-min))
    (and (re-search-forward "\\_<<PRIVATE\\_>" nil t)
         (re-search-forward "\\_<PRIVATE>\\_>" nil t))))

(defun fuel-syntax--find-usings (&optional no-private)
  (save-excursion
    (let ((usings))
      (goto-char (point-max))
      (while (re-search-backward fuel-syntax--using-lines-regex nil t)
        (dolist (u (split-string (match-string-no-properties 1) nil t))
          (push u usings)))
      (when (and (not no-private) (fuel-syntax--file-has-private))
        (goto-char (point-max))
        (push (concat (fuel-syntax--find-in) ".private") usings))
      usings)))


(provide 'fuel-syntax)
;;; fuel-syntax.el ends here
