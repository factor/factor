;;; fuel-refactor.el -- code refactoring support -*- lexical-binding: t -*-

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Thu Jan 08, 2009 00:57

;;; Comentary:

;; Utilities performing refactoring on factor code.

;;; Code:

(require 'fuel-base)
(require 'fuel-scaffold)
(require 'fuel-stack)
(require 'fuel-xref)
(require 'fuel-debug-uses)
(require 'factor-mode)

(require 'etags)


;;; Word definitions in buffer

(defconst fuel-refactor--next-defun-regex
  (format "^\\(:\\|MEMO:\\|MACRO:\\):? +\\(\\w+\\)\\(%s\\)\\([^;]+?\\) ;\\_>"
          factor-stack-effect-regex))

(defun fuel-refactor--previous-defun ()
  (let ((pos) (result))
    (while (and (not result)
                (setq pos (factor-beginning-of-defun)))
      (setq result (looking-at fuel-refactor--next-defun-regex)))
    (when (and result pos)
      (let ((name (match-string-no-properties 2))
            (body (match-string-no-properties 4))
            (end (match-end 0)))
        (list (split-string (or body "") nil t) name pos end)))))

(defun fuel-refactor--find (code to)
  (let ((candidate) (result))
    (while (and (not result)
                (setq candidate (fuel-refactor--previous-defun))
                (> (point) to))
      (when (equal (car candidate) code)
        (setq result (cdr candidate))))
    result))

(defun fuel-refactor--reuse-p (word)
  (save-excursion
    (mark-defun)
    (move-overlay fuel-stack--overlay (1+ (point)) (mark))
    (unwind-protect
        (and (y-or-n-p (format "Use existing word '%s'? " word)) word)
      (delete-overlay fuel-stack--overlay))))

(defun fuel-refactor--code-rx (code)
  (let ((words (split-string code nil t)))
    (mapconcat 'regexp-quote words "[ \n\f\r]+")))


;;; Extract word:

(defun fuel-refactor--reuse-existing (code)
  (save-excursion
    (mark-defun)
    (let ((code (split-string (substring-no-properties code) nil t))
          (down (mark))
          (found)
          (result))
      (while (and (not result)
                  (setq found (fuel-refactor--find code (point-min))))
        (when found (setq result (fuel-refactor--reuse-p (car found)))))
      (goto-char (point-max))
      (while (and (not result)
                  (setq found (fuel-refactor--find code down)))
        (when found (setq result (fuel-refactor--reuse-p (car found)))))
      (and result found))))

(defsubst fuel-refactor--insertion-point ()
  (max (save-excursion (factor-beginning-of-defun) (point))
       (save-excursion
         (re-search-backward factor-end-of-def-regex nil t)
         (forward-line 1)
         (skip-syntax-forward "-"))))

(defun fuel-refactor--insert-word (word stack-effect code)
  (let ((start (goto-char (fuel-refactor--insertion-point))))
    (open-line 1)
    (insert ": " word " " stack-effect "\n" (or code " ") " ;\n")
    (indent-region start (point))
    (move-overlay fuel-stack--overlay start (point))))

(defun fuel-refactor--extract-other (start end word code)
  (unwind-protect
      (when (y-or-n-p "Apply refactoring to rest of buffer? ")
        (save-excursion
          (let ((rx (fuel-refactor--code-rx code))
                (end (point)))
            (query-replace-regexp rx word t (point-min) start)
            (query-replace-regexp rx word t end (point-max)))))
    (delete-overlay fuel-stack--overlay)))

(defun fuel-refactor--extract (begin end)
  (let* ((rp (< begin end))
         (code (and rp (buffer-substring begin end)))
         (existing (and code (fuel-refactor--reuse-existing code)))
         (code-str (and code (or existing (fuel-region-to-string begin end))))
         (word (or (car existing) (read-string "New word name: ")))
         (stack-effect (or existing
                           (and code-str (fuel-stack--infer-effect code-str))
                           (read-string "Stack effect: "))))
    (when rp
      (goto-char begin)
      (delete-region begin end)
      (insert word)
      (indent-region begin (point)))
    (save-excursion
      (let ((start (or (cadr existing) (point))))
        (unless existing
          (fuel-refactor--insert-word word stack-effect code))
        (if rp
            (fuel-refactor--extract-other start
                                          (or (car (cddr existing)) (point))
                                          word code)
          (unwind-protect
              (sit-for fuel-stack-highlight-period)
            (delete-overlay fuel-stack--overlay)))))))

(defun fuel-refactor-extract-region (begin end)
  "Extracts current region as a separate word."
  (interactive "r")
  (if (= begin end)
      (fuel-refactor--extract begin end)
    (let ((begin (save-excursion
                   (goto-char begin)
                   (when (zerop (skip-syntax-backward "w"))
                     (skip-syntax-forward "-"))
                   (point)))
          (end (save-excursion
                 (goto-char end)
                 (skip-syntax-forward "w")
                 (point))))
      (fuel-refactor--extract begin end))))

(defun fuel-refactor-extract-sexp ()
  "Extracts current innermost sexp (up to point) as a separate
word."
  (interactive)
  (fuel-refactor-extract-region (1+ (factor-beginning-of-sexp-pos))
                                (if (looking-at-p ";")
                                    (point)
                                  (save-excursion
                                    (factor-end-of-symbol) (point)))))


;;; Convert word to generic + method:

(defun fuel-refactor-make-generic ()
  "Inserts a new generic definition with the current word's stack effect.
The word's body is put in a new method for the generic."
  (interactive)
  (let ((p (point)))
    (factor-beginning-of-defun)
    (unless (re-search-forward factor-word-signature-regex nil t)
      (goto-char p)
      (error "Cannot find a proper word definition here"))
    (let ((begin (match-beginning 0))
          (end (match-end 0))
          (name (match-string-no-properties 1))
          (cls (read-string "Method's class (object): " nil nil "object")))
      (goto-char begin)
      (insert "GENERIC")
      (goto-char (+ end 7))
      (newline 2)
      (insert "M: " cls " " name " "))))


;;; Inline word:

(defun fuel-refactor--word-def (word)
  (let ((def (fuel-eval--retort-result
              (fuel-eval--send/wait `(:fuel* (,word fuel-word-def) "fuel")))))
    (when def
      (substring (substring def 2) 0 -2))))

(defun fuel-refactor-inline-word ()
  "Inserts definition of word at point."
  (interactive)
  (let ((word (factor-symbol-at-point)))
    (unless word (error "No word at point"))
    (let ((code (fuel-refactor--word-def word)))
      (unless code (error "Word's definition not found"))
      (factor-beginning-of-symbol)
      (kill-sexp 1)
      (let ((start (point)))
        (insert code)
        (save-excursion (font-lock-fontify-region start (point)))
        (indent-region start (point))))))


;;; Rename word:

(defsubst fuel-refactor--rename-word (from to file)
  (let ((files (fuel-xref--word-callers-files from)))
    (tags-query-replace from to t `(cons ,file ',files))
    files))

(defun fuel-refactor--def-word ()
  (save-excursion
    (factor-beginning-of-defun)
    (or (and (looking-at factor-method-definition-regex)
             (match-string-no-properties 3))
        (and (looking-at factor-word-definition-regex)
             (match-string-no-properties 2)))))

(defun fuel-refactor-rename-word (&optional arg)
  "Rename globally the word whose definition point is at.
With prefix argument, use word at point instead."
  (interactive "P")
  (let* ((from (if arg (fuel-refactor--def-word) (factor-symbol-at-point)))
         (from (read-string "Rename word: " from))
         (to (read-string (format "Rename '%s' to: " from))))
    (fuel-refactor--rename-word from to (buffer-file-name))))


;;; Extract vocab:

(defun fuel-refactor--insert-using (vocab)
  (save-excursion
    (goto-char (point-min))
    (let ((usings (sort (cons vocab (factor-usings)) 'string<)))
      (fuel-debug--replace-usings (buffer-file-name) usings))))

(defun fuel-refactor--vocab-root (vocab)
  (let ((cmd `(:fuel* (,vocab fuel-scaffold-get-root) "fuel")))
    (fuel-eval--retort-result (fuel-eval--send/wait cmd))))

(defun fuel-update-usings (&optional arg)
  "Asks factor for the vocabularies needed by this file,
optionally updating the its USING: line.
With prefix argument, ask for the file name."
  (interactive "P")
  (let ((file (car (fuel-mode--read-file arg))))
    (when file (fuel-debug--uses-for-file file))))

(defun fuel-refactor--extract-vocab (begin end)
  (when (< begin end)
    (let* ((str (buffer-substring begin end))
           (buffer (current-buffer))
           (vocab (factor-current-vocab))
           (vocab-hint (and vocab (format "%s." vocab)))
           (root-hint (fuel-refactor--vocab-root vocab))
           (vocab (fuel-scaffold-vocab t vocab-hint root-hint)))
      (with-current-buffer buffer
        (delete-region begin end)
        (fuel-refactor--insert-using vocab))
      (newline)
      (insert str)
      (newline)
      (save-buffer)
      (fuel-update-usings))))

(defun fuel-refactor-extract-vocab (begin end)
  "Creates a new vocab with the words in current region.
The region is extended to the closest definition boundaries."
  (interactive "r")
  (fuel-refactor--extract-vocab (save-excursion (goto-char begin)
                                                (mark-defun)
                                                (point))
                                (save-excursion (goto-char end)
                                                (mark-defun)
                                                (mark))))

;;; Extract article:

(defun fuel-refactor-extract-article (begin end)
  "Extracts region as a new ARTICLE form."
  (interactive "r")
  (let ((topic (read-string "Article topic: "))
        (title (read-string "Article title: ")))
    (kill-region begin end)
    (insert (format "{ $subsection %s }\n" topic))
    (end-of-line 0)
    (save-excursion
      (goto-char (fuel-refactor--insertion-point))
      (open-line 1)
      (let ((start (point)))
        (insert (format "ARTICLE: %S %S\n" topic title))
        (yank)
        (when (looking-at "^ *$") (end-of-line 0))
        (insert " ;")
        (unwind-protect
            (progn
              (move-overlay fuel-stack--overlay start (point))
              (sit-for fuel-stack-highlight-period))
          (delete-overlay fuel-stack--overlay))))))


(provide 'fuel-refactor)

;;; fuel-refactor.el ends here
