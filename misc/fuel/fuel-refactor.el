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

(defun fuel-refactor-extract-word (begin end)
  "Extracts current region as a separate word."
  (interactive "r")
  (let* ((word (read-string "New word name: "))
         (code (buffer-substring begin end))
         (code-str (fuel--region-to-string begin end))
         (stack-effect (or (fuel-stack--infer-effect code-str)
                           (read-string "Stack effect: "))))
    (goto-char begin)
    (delete-region begin end)
    (insert word)
    (indent-region begin (point))
    (set-mark (point))
    (fuel-syntax--beginning-of-defun)
    (open-line 1)
    (let ((start (point)))
      (insert ": " word " " stack-effect "\n" code " ;\n")
      (indent-region start (point))
      (move-overlay fuel-stack--overlay start (point))
      (goto-char (mark))
      (sit-for fuel-stack-highlight-period)
      (delete-overlay fuel-stack--overlay))))


(provide 'fuel-refactor)
;;; fuel-refactor.el ends here
