;;; fuel-refactor.el -- code refactoring support

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Thu Jan 08, 2009 00:57

;;; Comentary:

;; Utilities performing refactoring on factor code.

;;; Code:

(require 'fuel-stack)
(require 'fuel-syntax)
(require 'fuel-base)


;;; Extract word:

(defun fuel-refactor--extract (begin end)
  (let* ((word (read-string "New word name: "))
         (code (buffer-substring begin end))
         (code-str (fuel--region-to-string begin end))
         (stack-effect (or (fuel-stack--infer-effect code-str)
                           (read-string "Stack effect: "))))
    (unless (< begin end) (error "No proper region to extract"))
    (goto-char begin)
    (delete-region begin end)
    (insert word)
    (indent-region begin (point))
    (set-mark (point))
    (let ((beg (save-excursion (fuel-syntax--beginning-of-defun) (point)))
          (end (save-excursion
                 (re-search-backward fuel-syntax--end-of-def-regex nil t)
                 (forward-line 1)
                 (skip-syntax-forward "-")
                 (point))))
      (goto-char (max beg end)))
    (open-line 1)
    (let ((start (point)))
      (insert ": " word " " stack-effect "\n" code " ;\n")
      (indent-region start (point))
      (move-overlay fuel-stack--overlay start (point))
      (goto-char (mark))
      (sit-for fuel-stack-highlight-period)
      (delete-overlay fuel-stack--overlay))))

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



(provide 'fuel-refactor)
;;; fuel-refactor.el ends here
