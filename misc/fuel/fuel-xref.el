;;; fuel-xref.el -- showing cross-reference info

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 20, 2008 22:00

;;; Comentary:

;; A mode and utilities for showing cross-reference information.

;;; Code:

(require 'fuel-eval)
(require 'fuel-syntax)
(require 'fuel-popup)
(require 'fuel-font-lock)
(require 'fuel-base)

(require 'button)


;;; Customization:

(defgroup fuel-xref nil
  "FUEL's cross-referencing engine."
  :group 'fuel)

(defcustom fuel-xref-follow-link-to-word-p t
  "Whether, when following a link to a caller, we position the
cursor at the first ocurrence of the used word."
  :group 'fuel-xref
  :type 'boolean)

(fuel-font-lock--defface fuel-font-lock-xref-link
  'link fuel-xref "highlighting links in cross-reference buffers")

(fuel-font-lock--defface fuel-font-lock-xref-vocab
  'italic fuel-xref "vocabulary names in cross-reference buffers")


;;; Buttons:

(define-button-type 'fuel-xref--button-type
  'action 'fuel-xref--follow-link
  'follow-link t
  'face 'fuel-font-lock-xref-link)

(defun fuel-xref--follow-link (button)
  (let ((file (button-get button 'file))
        (line (button-get button 'line)))
    (when (not file)
      (error "No file for this ref"))
    (when (not (file-readable-p file))
      (error "File '%s' is not readable" file))
    (let ((word fuel-xref--word))
      (find-file-other-window file)
      (when (numberp line) (goto-line line))
      (when (and word fuel-xref-follow-link-to-word-p)
        (and (search-forward word
                             (fuel-syntax--end-of-defun-pos)
                             t)
             (goto-char (match-beginning 0)))))))


;;; The xref buffer:

(fuel-popup--define fuel-xref--buffer
  "*fuel xref*" 'fuel-xref-mode)

(make-local-variable (defvar fuel-xref--word nil))

(defvar fuel-xref--help-string "(Press RET or click to follow crossrefs)")

(defun fuel-xref--title (word cc count)
  (let ((cc (if cc "using" "used by")))
    (put-text-property 0 (length word) 'font-lock-face 'bold word)
    (cond ((zerop count) (format "No known words %s %s" cc word))
          ((= 1 count) (format "1 word %s %s:" cc word))
          (t (format "%s words %s %s:" count cc word)))))

(defun fuel-xref--insert-ref (ref)
  (when (and (stringp (first ref))
             (stringp (third ref))
             (numberp (fourth ref)))
    (insert "  ")
    (insert-text-button (first ref)
                        :type 'fuel-xref--button-type
                        'help-echo (format "File: %s (%s)"
                                           (third ref)
                                           (fourth ref))
                        'file (third ref)
                        'line (fourth ref))
    (when (stringp (second ref))
      (insert (format " (in %s)" (second ref))))
    (newline)
    t))

(defun fuel-xref--fill-buffer (word cc refs)
  (let ((inhibit-read-only t)
        (count 0))
    (with-current-buffer (fuel-xref--buffer)
      (erase-buffer)
      (dolist (ref refs)
        (when (fuel-xref--insert-ref ref) (setq count (1+ count))))
      (goto-char (point-min))
      (insert (fuel-xref--title word cc count) "\n\n")
      (when (> count 0)
        (setq fuel-xref--word (and cc word))
        (goto-char (point-max))
        (insert "\n" fuel-xref--help-string "\n"))
      (goto-char (point-min))
      count)))

(defun fuel-xref--fill-and-display (word cc refs)
  (let ((count (fuel-xref--fill-buffer word cc refs)))
    (if (zerop count)
        (error (fuel-xref--title word cc 0))
      (message "")
      (fuel-popup--display (fuel-xref--buffer)))))

(defun fuel-xref--show-callers (word)
  (let* ((cmd `(:fuel* (((:quote ,word) fuel-callers-xref))))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd))))
    (fuel-xref--fill-and-display word t res)))

(defun fuel-xref--show-callees (word)
  (let* ((cmd `(:fuel* (((:quote ,word) fuel-callees-xref))))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd))))
    (fuel-xref--fill-and-display word nil res)))


;;; Xref mode:

(defvar fuel-xref-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (set-keymap-parent map button-buffer-map)
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
  (font-lock-add-keywords nil '(("(in \\(.+\\))" 1 'fuel-font-lock-xref-vocab)))
  (setq buffer-read-only t))


(provide 'fuel-xref)
;;; fuel-xref.el ends here
