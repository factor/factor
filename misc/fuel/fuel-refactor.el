;;; fuel-refactor.el -- code refactoring support

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Thu Jan 08, 2009 00:57

;;; Comentary:

;; Utilities performing refactoring on factor code.

;;; Code:

(require 'fuel-scaffold)
(require 'fuel-stack)
(require 'fuel-syntax)
(require 'fuel-base)


;;; Word definitions in buffer

(defconst fuel-refactor--next-defun-regex
  (format "^\\(:\\|MEMO:\\|MACRO:\\):? +\\(\\w+\\)\\(%s\\)\\([^;]+?\\) ;\\_>"
          fuel-syntax--stack-effect-regex))

(defun fuel-refactor--previous-defun ()
  (let ((pos) (result))
    (while (and (not result)
                (setq pos (fuel-syntax--beginning-of-defun)))
      (setq result (looking-at fuel-refactor--next-defun-regex)))
    (when (and result pos)
      (let ((name (match-string-no-properties 2))
            (body (match-string-no-properties 4))
            (end (match-end 0)))
        (list (split-string body nil t) name pos end)))))

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

(defun fuel-refactor--insert-word (word stack-effect code)
  (let ((beg (save-excursion (fuel-syntax--beginning-of-defun) (point)))
        (end (save-excursion
               (re-search-backward fuel-syntax--end-of-def-regex nil t)
               (forward-line 1)
               (skip-syntax-forward "-"))))
    (let ((start (goto-char (max beg end))))
      (open-line 1)
      (insert ": " word " " stack-effect "\n" code " ;\n")
      (indent-region start (point))
      (move-overlay fuel-stack--overlay start (point)))))

(defun fuel-refactor--extract-other (start end code)
  (unwind-protect
      (when (y-or-n-p "Apply refactoring to rest of buffer? ")
        (save-excursion
          (let ((rx (fuel-refactor--code-rx code))
                (end (point)))
            (query-replace-regexp rx word t (point-min) start)
            (query-replace-regexp rx word t end (point-max)))))
    (delete-overlay fuel-stack--overlay)))

(defun fuel-refactor--extract (begin end)
  (unless (< begin end) (error "No proper region to extract"))
  (let* ((code (buffer-substring begin end))
         (existing (fuel-refactor--reuse-existing code))
         (code-str (or existing (fuel--region-to-string begin end)))
         (stack-effect (or existing
                           (fuel-stack--infer-effect code-str)
                           (read-string "Stack effect: ")))
         (word (or (car existing) (read-string "New word name: "))))
    (goto-char begin)
    (delete-region begin end)
    (insert word)
    (indent-region begin (point))
    (save-excursion
      (let ((start (or (cadr existing) (point))))
        (unless existing
          (fuel-refactor--insert-word word stack-effect code))
        (fuel-refactor--extract-other start
                                      (or (car (cddr existing)) (point))
                                      code)))))

(defun fuel-refactor-extract-region (begin end)
  "Extracts current region as a separate word."
  (interactive "r")
  (let ((begin (save-excursion
                 (goto-char begin)
                 (when (zerop (skip-syntax-backward "w"))
                   (skip-syntax-forward "-"))
                 (point)))
        (end (save-excursion
               (goto-char end)
               (skip-syntax-forward "w")
               (point))))
    (fuel-refactor--extract begin end)))

(defun fuel-refactor-extract-sexp ()
  "Extracts current innermost sexp (up to point) as a separate
word."
  (interactive)
  (fuel-refactor-extract-region (1+ (fuel-syntax--beginning-of-sexp-pos))
                                (if (looking-at-p ";") (point)
                                  (fuel-syntax--end-of-symbol-pos))))


;;; Inline word:

(defun fuel-refactor--word-def (word)
  (let ((def (fuel-eval--retort-result
              (fuel-eval--send/wait `(:fuel* (,word fuel-word-def) "fuel")))))
    (when def
      (substring (substring def 2) 0 -2))))

(defun fuel-refactor-inline-word ()
  "Inserts definition of word at point."
  (interactive)
  (let ((word (fuel-syntax-symbol-at-point)))
    (unless word (error "No word at point"))
    (let ((code (fuel-refactor--word-def word)))
      (unless code (error "Word's definition not found"))
      (fuel-syntax--beginning-of-symbol)
      (kill-word 1)
      (let ((start (point)))
        (insert code)
        (save-excursion (font-lock-fontify-region start (point)))
        (indent-region start (point))))))


;;; Extract vocab:

(defun fuel-refactor--insert-using (vocab)
  (save-excursion
    (goto-char (point-min))
    (let ((usings (sort (cons vocab (fuel-syntax--usings)) 'string<)))
      (fuel-debug--replace-usings (buffer-file-name) usings))))

(defun fuel-refactor--vocab-root (vocab)
  (let ((cmd `(:fuel* (,vocab fuel-scaffold-get-root) "fuel")))
    (fuel-eval--retort-result (fuel-eval--send/wait cmd))))

(defun fuel-refactor--extract-vocab (begin end)
  (when (< begin end)
    (let* ((str (buffer-substring begin end))
           (buffer (current-buffer))
           (vocab (fuel-syntax--current-vocab))
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

(provide 'fuel-refactor)
;;; fuel-refactor.el ends here
