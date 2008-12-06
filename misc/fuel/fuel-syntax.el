;;; fuel-syntax.el --- auxiliar definitions for factor code navigation.

;; Copyright (C) 2008  Jose Antonio Ortega Ruiz
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
  (while (eq (char-before) ?:) (backward-char))
  (skip-syntax-backward "w_"))

(defun fuel-syntax--end-of-symbol ()
  "Move point to the end of the current symbol."
  (skip-syntax-forward "w_")
  (while (looking-at ":") (forward-char)))

(put 'factor-symbol 'end-op 'fuel-syntax--end-of-symbol)
(put 'factor-symbol 'beginning-op 'fuel-syntax--beginning-of-symbol)

(defsubst fuel-syntax-symbol-at-point ()
  (let ((s (substring-no-properties (thing-at-point 'factor-symbol))))
    (and (> (length s) 0) s)))


;;; Regexps galore:

(defconst fuel-syntax--parsing-words
  '("{" "}" "^:" "^::" ";" "<<" "<PRIVATE" ">>"
    "BIN:" "BV{" "B{" "C:" "C-STRUCT:" "C-UNION:" "CHAR:" "CS{" "C{"
    "DEFER:" "ERROR:" "EXCLUDE:" "FORGET:"
    "GENERIC#" "GENERIC:" "HEX:" "HOOK:" "H{"
    "IN:" "INSTANCE:" "INTERSECTION:"
    "M:" "MACRO:" "MACRO::" "MAIN:" "MATH:" "METHOD:" "MIXIN:"
    "OCT:" "POSTPONE:" "PREDICATE:" "PRIMITIVE:" "PRIVATE>" "PROVIDE:"
    "REQUIRE:"  "REQUIRES:" "SINGLETON:" "SLOT:" "SYMBOL:" "SYMBOLS:"
    "TUPLE:" "T{" "t\\??" "TYPEDEF:"
    "UNION:" "USE:" "USING:" "V{" "VARS:" "W{"))

(defconst fuel-syntax--parsing-words-ext-regex
  (regexp-opt '("B" "call-next-method" "delimiter" "f" "initial:" "read-only")
              'words))

(defconst fuel-syntax--declaration-words
  '("flushable" "foldable" "inline" "parsing" "recursive"))

(defconst fuel-syntax--declaration-words-regex
  (regexp-opt fuel-syntax--declaration-words 'words))

(defsubst fuel-syntax--second-word-regex (prefixes)
  (format "^%s +\\([^ \r\n]+\\)" (regexp-opt prefixes t)))

(defconst fuel-syntax--method-definition-regex
  "^M: +\\([^ ]+\\) +\\([^ ]+\\)")

(defconst fuel-syntax--word-definition-regex
  (fuel-syntax--second-word-regex '(":" "::" "GENERIC:")))

(defconst fuel-syntax--type-definition-regex
  (fuel-syntax--second-word-regex '("TUPLE:" "SINGLETON:")))

(defconst fuel-syntax--parent-type-regex "^TUPLE: +[^ ]+ +< +\\([^ ]+\\)")

(defconst fuel-syntax--constructor-regex "<[^ >]+>")

(defconst fuel-syntax--setter-regex "\\W>>[^ ]+\\b")

(defconst fuel-syntax--symbol-definition-regex
  (fuel-syntax--second-word-regex '("SYMBOL:" "VAR:")))

(defconst fuel-syntax--stack-effect-regex " ( .* )")

(defconst fuel-syntax--using-lines-regex "^USING: +\\([^;]+\\);")

(defconst fuel-syntax--use-line-regex "^USE: +\\(.*\\)$")

(defconst fuel-syntax--current-vocab-regex "^IN: +\\([^ \r\n\f]+\\)")

(defconst fuel-syntax--sub-vocab-regex "^<\\([^ \n]+\\) *$")

(defconst fuel-syntax--definition-starters-regex
  (regexp-opt '("VARS" "TUPLE" "MACRO" "MACRO:" "M" ":" "")))

(defconst fuel-syntax--definition-start-regex
  (format "^\\(%s:\\) " fuel-syntax--definition-starters-regex))

(defconst fuel-syntax--definition-end-regex
  (format "\\(\\(^\\| +\\);\\( +%s\\)*\\($\\| +\\)\\)"
          fuel-syntax--declaration-words-regex))

(defconst fuel-syntax--single-liner-regex
  (format "^%s" (regexp-opt '("DEFER:" "GENERIC:" "IN:"
                              "PRIVATE>" "<PRIVATE"
                              "SINGLETON:" "SYMBOL:" "USE:" "VAR:"))))

(defconst fuel-syntax--begin-of-def-regex
  (format "^USING: \\|\\(%s\\)\\|\\(%s .*\\)"
          fuel-syntax--definition-start-regex
          fuel-syntax--single-liner-regex))

(defconst fuel-syntax--end-of-def-line-regex
  (format "^.*%s" fuel-syntax--definition-end-regex))

(defconst fuel-syntax--end-of-def-regex
  (format "\\(%s\\)\\|\\(%s .*\\)"
          fuel-syntax--end-of-def-line-regex
          fuel-syntax--single-liner-regex))

;;; Factor syntax table

(defvar fuel-syntax--syntax-table
  (let ((i 0)
        (table (make-syntax-table)))
    ;; Default is atom-constituent
    (while (< i 256)
      (modify-syntax-entry i "_   " table)
      (setq i (1+ i)))

    ;; Word components.
    (setq i ?0)
    (while (<= i ?9)
      (modify-syntax-entry i "w   " table)
      (setq i (1+ i)))
    (setq i ?A)
    (while (<= i ?Z)
      (modify-syntax-entry i "w   " table)
      (setq i (1+ i)))
    (setq i ?a)
    (while (<= i ?z)
      (modify-syntax-entry i "w   " table)
      (setq i (1+ i)))

    ;; Whitespace
    (modify-syntax-entry ?\t " " table)
    (modify-syntax-entry ?\f " " table)
    (modify-syntax-entry ?\r " " table)
    (modify-syntax-entry ?  " " table)

    ;; (end of) Comments
    (modify-syntax-entry ?\n ">" table)

    ;; Parenthesis
    (modify-syntax-entry ?\[ "(]  " table)
    (modify-syntax-entry ?\] ")[  " table)
    (modify-syntax-entry ?{ "(}  " table)
    (modify-syntax-entry ?} "){  " table)

    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)

    ;; Strings
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "/" table)
    table)
  "Syntax table used while in Factor mode.")

(defconst fuel-syntax--syntactic-keywords
  `(("\\(#!\\)" (1 "<"))
    (" \\(!\\)" (1 "<"))
    ("^\\(!\\)" (1 "<"))
    ("\\(!(\\) .* \\()\\)" (1 "<") (2 ">"))
    ("\\([[({]\\)\\([^ \"\n]\\)" (1 "_") (2 "_"))
    ("\\([^ \"\n]\\)\\([])}]\\)" (1 "_") (2 "_"))))


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

(defsubst fuel-syntax--at-end-of-def ()
  (looking-at fuel-syntax--end-of-def-regex))

(defsubst fuel-syntax--looking-at-emptiness ()
  (looking-at "^[ \t]*$"))

(defun fuel-syntax--at-setter-line ()
  (save-excursion
    (beginning-of-line)
    (if (not (fuel-syntax--looking-at-emptiness))
        (re-search-forward fuel-syntax--setter-regex (line-end-position) t)
      (forward-line -1)
      (or (fuel-syntax--at-constructor-line)
          (fuel-syntax--at-setter-line)))))

(defun fuel-syntax--at-constructor-line ()
  (save-excursion
    (beginning-of-line)
    (re-search-forward fuel-syntax--constructor-regex (line-end-position) t)))

(defsubst fuel-syntax--at-using ()
  (looking-at fuel-syntax--using-lines-regex))

(defsubst fuel-syntax--beginning-of-defun (&optional times)
  (re-search-backward fuel-syntax--begin-of-def-regex nil t times))

(defsubst fuel-syntax--end-of-defun ()
  (re-search-forward fuel-syntax--end-of-def-regex nil t))


;;; USING/IN:

(make-variable-buffer-local
 (defvar fuel-syntax--current-vocab nil))

(make-variable-buffer-local
 (defvar fuel-syntax--usings nil))

(defun fuel-syntax--current-vocab ()
  (let ((ip
         (save-excursion
           (when (re-search-backward fuel-syntax--current-vocab-regex nil t)
             (setq fuel-syntax--current-vocab (match-string-no-properties 1))
             (point)))))
    (when ip
      (let ((pp (save-excursion
                  (when (re-search-backward fuel-syntax--sub-vocab-regex ip t)
                    (point)))))
        (when (and pp (> pp ip))
          (let ((sub (match-string-no-properties 1)))
            (unless (save-excursion (search-backward (format "%s>" sub) pp t))
              (setq fuel-syntax--current-vocab
                    (format "%s.%s" fuel-syntax--current-vocab (downcase sub)))))))))
  fuel-syntax--current-vocab)

(defun fuel-syntax--usings-update ()
  (save-excursion
    (setq fuel-syntax--usings (list (fuel-syntax--current-vocab)))
    (while (re-search-backward fuel-syntax--using-lines-regex nil t)
      (dolist (u (split-string (match-string-no-properties 1) nil t))
        (push u fuel-syntax--usings)))
    fuel-syntax--usings))

(defsubst fuel-syntax--usings-update-hook ()
  (fuel-syntax--usings-update)
  nil)

(defun fuel-syntax--enable-usings ()
  (add-hook 'before-save-hook 'fuel-syntax--usings-update-hook nil t)
  (fuel-syntax--usings-update))

(defsubst fuel-syntax--usings ()
  (or fuel-syntax--usings (fuel-syntax--usings-update)))


(provide 'fuel-syntax)
;;; fuel-syntax.el ends here
