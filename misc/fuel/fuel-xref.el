;;; fuel-xref.el -- showing cross-reference info

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 20, 2008 22:00

;;; Comentary:

;; A mode and utilities for showing cross-reference information.

;;; Code:

(require 'fuel-base)

(require 'button)


;;; Customization:

(defgroup fuel-xref nil
  "FUEL's cross-referencing engine."
  :group 'fuel)


;;; Buttons:

(define-button-type 'fuel-xref--button-type
  'action 'fuel-xref--follow-link
  'follow-link t
  'face 'default)

(defun fuel-xref--follow-link (button)
  (let ((file (button-get button 'file))
        (line (button-get button 'line)))
    (when (not file)
      (error "No file for this ref"))
    (when (not (file-readable-p file))
      (error "File '%s' is not readable" file))
    (find-file-other-window file)
    (when (numberp line) (goto-line line))))


;;; The xref buffer:

(fuel-popup--define fuel-xref--buffer
  "*fuel xref*" 'fuel-xref-mode)

(defvar fuel-xref--help-string "(Press RET or click to follow crossrefs)")

(defun fuel-xref--fill-buffer (title refs)
  (let ((inhibit-read-only t))
    (with-current-buffer (fuel-xref--buffer)
      (erase-buffer)
      (insert title "\n\n")
      (dolist (ref refs)
        (when (and (first ref) (second ref) (numberp (third ref)))
          (insert "  ")
          (insert-text-button (first ref)
                              :type 'fuel-xref--button-type
                              'help-echo (format "File: %s (%s)"
                                                 (second ref)
                                                 (third ref))
                              'file (second ref)
                              'line (third ref))
          (newline)))
      (when refs
        (insert "\n\n" fuel-xref--help-string "\n"))
      (goto-char (point-min))
      (current-buffer))))

(defun fuel-xref--show-callers (word)
  (let* ((cmd `(:fuel* (((:quote ,word) fuel-callers-xref))))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd)))
         (title (format (if res "Callers of '%s':"
                          "No callers found for '%s'")
                        word)))
    (set-buffer (fuel-xref--fill-buffer title res))
    (fuel-popup--display)))

(defun fuel-xref--show-callees (word)
  (let* ((cmd `(:fuel* (((:quote ,word) fuel-callees-xref))))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd)))
         (title (format (if res "Words called by '%s':"
                          "No callees found for '%s'")
                        word)))
    (set-buffer (fuel-xref--fill-buffer title res))
    (fuel-popup--display)))


;;; Xref mode:

(defvar fuel-xref-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (set-keymap-parent map button-buffer-map)
    (define-key map "q" 'bury-buffer)
    map))

(defun fuel-xref-mode ()
  "Mode for displaying FUEL cross-reference information.
\\{fuel-xref-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (buffer-disable-undo)
  (use-local-map fuel-xref-mode-map)
  (setq mode-name "FUEL Xref")
  (setq major-mode 'fuel-xref-mode)
  (fuel-font-lock--font-lock-setup)
  (setq buffer-read-only t))


(provide 'fuel-xref)
;;; fuel-xref.el ends here
