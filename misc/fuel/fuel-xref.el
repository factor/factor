;;; fuel-xref.el -- showing cross-reference info -*- lexical-binding: t -*-

;; Copyright (C) 2008, 2009, 2010 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 20, 2008 22:00

;;; Comentary:

;; A mode and utilities for showing cross-reference information.

;;; Code:

(require 'fuel-edit)
(require 'fuel-completion)
(require 'fuel-help)
(require 'fuel-eval)
(require 'fuel-popup)
(require 'fuel-menu)
(require 'fuel-base)
(require 'factor-mode)
(require 'cl-seq)

(require 'button)


;;; Customization:

;;;###autoload
(defgroup fuel-xref nil
  "FUEL's cross-referencing engine."
  :group 'fuel)

(defcustom fuel-xref-follow-link-to-word-p t
  "Whether, when following a link to a caller, we position the
cursor at the first ocurrence of the used word."
  :group 'fuel-xref
  :type 'boolean)

(defcustom fuel-xref-follow-link-method nil
  "How new buffers are opened when following a crossref link."
  :group 'fuel-xref
  :type '(choice (const :tag "Other window" window)
                 (const :tag "Other frame" frame)
                 (const :tag "Current window" nil)))

(defface fuel-xref-link-face '((t (:inherit link)))
  "Highlighting links in cross-reference buffers."
  :group 'fuel-xref
  :group 'fuel-faces
  :group 'fuel)

(defvar-local fuel-xref--word nil)


;;; Buttons:

(define-button-type 'fuel-xref--button-type
  'action 'fuel-xref--follow-link
  'follow-link t
  'face 'fuel-xref-link-face)

(defun fuel-xref--follow-link (button)
  (let ((file (button-get button 'file))
        (line (button-get button 'line)))
    (when (not file)
      (error "No file for this ref (it's probably a primitive)"))
    (when (not (file-readable-p file))
      (error "File '%s' is not readable" file))
    (let ((word fuel-xref--word))
      (fuel-edit--visit-file file fuel-xref-follow-link-method)
      (when (numberp line)
        (goto-char (point-min))
        (forward-line (1- line)))
      (when (and word fuel-xref-follow-link-to-word-p)
        (and (re-search-forward (format "\\_<%s\\_>" word)
                                (factor-end-of-defun-pos)
                                t)
             (goto-char (match-beginning 0)))))))


;;; The xref buffer:

(defun fuel-xref--eval<x--y> (arg word context)
  "A helper for the very common task of calling an ( x -- y ) factor word."
  (let ((cmd (list :fuel* (list (list arg word)) context)))
    (fuel-eval--retort-result (fuel-eval--send/wait cmd))))

(defun fuel-xref--buffer ()
  (or (get-buffer "*fuel xref*")
      (with-current-buffer (get-buffer-create "*fuel xref*")
        (fuel-xref-mode)
        (fuel-popup-mode)
        (current-buffer))))

(defun fuel-xref--pluralize-count (count item)
  (let ((fmt (if (= count 1) "%d %s" "%d %ss")))
    (format fmt count item)))

(defun fuel-xref--insert-link (title file line-num)
  (insert-text-button title
                      :type 'fuel-xref--button-type
                      'help-echo (format "File: %s (%s)" file line-num)
                      'file file
                      'line line-num))

(defun fuel-xref--insert-word (word vocab file line-num)
  (insert "  ")
  (fuel-xref--insert-link word file line-num)
  (insert (if line-num (format " line %s" line-num)
            " primitive"))
  (newline))

(defun fuel-xref--insert-vocab-words (vocab-def xrefs)
  (cl-destructuring-bind (vocab file) vocab-def
    (insert "in ")
    (fuel-xref--insert-link (or vocab "unknown vocabs") file 1)
    (let ((count-str (fuel-xref--pluralize-count (length xrefs) "word")))
      (insert (format " %s:\n" count-str))))
  (dolist (xref xrefs)
    (apply 'fuel-xref--insert-word xref))
  (newline))

(defun fuel-xref--display-word-groups (search-str cc xref-groups)
  "Should be called in a with-current-buffer context"
  (let ((inhibit-read-only t)
        (title-str (format "Words %s %s:\n\n" cc search-str)))
    (erase-buffer)
    (insert (propertize title-str 'font-lock-face 'bold))
    (dolist (group xref-groups)
      (apply 'fuel-xref--insert-vocab-words group)))
  (goto-char (point-min))
  (message "")
  (fuel-popup--display (current-buffer)))

(defun fuel-xref--display-vocabs (search-str cc xrefs)
  "Should be called in a with-current-buffer context"
  (put-text-property 0 (length search-str) 'font-lock-face 'bold search-str)
  (let* ((inhibit-read-only t)
         (xrefs (cl-remove-if (lambda (el) (not (nth 2 el))) xrefs))
         (count-str (fuel-xref--pluralize-count (length xrefs) "vocab"))
         (title-str (format "%s %s %s:\n\n" count-str cc search-str)))
    (erase-buffer)
    (insert title-str)
    (cl-loop for (vocab _ file line-num) in xrefs do
          (insert "  ")
          (fuel-xref--insert-link vocab file line-num)
          (newline)))
  (goto-char (point-min))
  (message "")
  (fuel-popup--display (current-buffer)))

(defun fuel-xref--callers (word)
  (fuel-xref--eval<x--y>
   (list :quote word)
   'fuel-callers-xref
   (factor-current-vocab)))

(defun fuel-xref--show-callers (word)
  (let ((res (fuel-xref--callers word)))
    (with-current-buffer (fuel-xref--buffer)
      (setq fuel-xref--word word)
      (fuel-xref--display-word-groups word "calling" res))))

(defun fuel-xref--word-callers-files (word)
  (mapcar 'cadar (fuel-xref--callers word)))

(defun fuel-xref--show-callees (word)
  (let ((res (fuel-xref--eval<x--y>
              (list :quote word)
              'fuel-callees-xref
              (factor-current-vocab))))
    (with-current-buffer (fuel-xref--buffer)
      (setq fuel-xref--word nil)
      (fuel-xref--display-word-groups word "used by" res))))

(defun fuel-xref--apropos (str)
  (let ((res (fuel-xref--eval<x--y> str 'fuel-apropos-xref "")))
    (with-current-buffer (fuel-xref--buffer)
      (setq fuel-xref--word nil)
      (fuel-xref--display-word-groups str "containing" res))))

(defun fuel-xref--show-vocab-words (vocab)
  (let ((res (fuel-xref--eval<x--y> vocab 'fuel-vocab-xref vocab)))
    (with-current-buffer (fuel-xref--buffer)
      (setq fuel-xref--word nil)
      (fuel-xref--display-word-groups vocab "in vocabulary" res))))

(defun fuel-xref--show-vocab-usage (vocab)
  (let ((res (fuel-xref--eval<x--y> vocab 'fuel-vocab-usage-xref "")))
    (with-current-buffer (fuel-xref--buffer)
      (setq fuel-xref--word nil)
      (fuel-xref--display-vocabs vocab "using" res))))

(defun fuel-xref--show-vocab-uses (vocab)
  (let ((res (fuel-xref--eval<x--y> vocab 'fuel-vocab-uses-xref "")))
    (with-current-buffer (fuel-xref--buffer)
      (setq fuel-xref--word nil)
      (fuel-xref--display-vocabs vocab "used by" res))))


;;; User commands:

(defvar fuel-xref--word-history nil)

(defun fuel-show-callers (&optional arg)
  "Show a list of callers of word or vocabulary at point.
With prefix argument, ask for word."
  (interactive "P")
  (let ((word (if arg (fuel-completion--read-word "Find callers for: "
                                                  (factor-symbol-at-point)
                                                  fuel-xref--word-history)
                (factor-symbol-at-point))))
    (when word
      (message "Looking up %s's users ..." word)
      (if (and (not arg)
               (factor-on-vocab))
          (fuel-xref--show-vocab-usage word)
        (fuel-xref--show-callers word)))))

(defun fuel-show-callees (&optional arg)
  "Show a list of callers of word or vocabulary at point.
With prefix argument, ask for word."
  (interactive "P")
  (let ((word (if arg (fuel-completion--read-word "Find callees for: "
                                                  (factor-symbol-at-point)
                                                  fuel-xref--word-history)
                (factor-symbol-at-point))))
    (when word
      (message "Looking up %s's callees ..." word)
      (if (and (not arg)
               (factor-on-vocab))
          (fuel-xref--show-vocab-uses word)
        (fuel-xref--show-callees word)))))

(defvar fuel-xref--vocab-history nil)

(defun fuel-vocab-uses (&optional arg)
  "Show a list of vocabularies used by a given one.
With prefix argument, force reload of vocabulary list."
  (interactive "P")
  (let ((vocab (fuel-completion--read-vocab arg
                                            (factor-symbol-at-point)
                                            fuel-xref--vocab-history)))
    (fuel-xref--show-vocab-uses vocab)))

(defun fuel-vocab-usage (&optional arg)
  "Show a list of vocabularies that use a given one.
With prefix argument, force reload of vocabulary list."
  (interactive "P")
  (let ((vocab (fuel-completion--read-vocab arg
                                            (factor-symbol-at-point)
                                            fuel-xref--vocab-history)))
    (fuel-xref--show-vocab-usage vocab)))

(defun fuel-apropos (str)
  "Show a list of words containing the given substring."
  (interactive "MFind words containing: ")
  (message "Looking up %s's references ..." str)
  (fuel-xref--apropos str))

(defun fuel-show-file-words (&optional arg)
  "Show a list of words in current file.
With prefix argument, ask for the vocab."
  (interactive "P")
  (let ((vocab (or (and (not arg) (factor-current-vocab))
                   (fuel-completion--read-vocab nil))))
    (when vocab
      (fuel-xref--show-vocab-words vocab))))



;;; Xref mode:

(defun fuel-xref-show-help ()
  (interactive)
  (let ((fuel-help-always-ask nil))
    (fuel-help)))

;;;###autoload
(define-derived-mode fuel-xref-mode fundamental-mode "FUEL Xref"
  "Mode for displaying FUEL cross-reference information.
\\{fuel-xref-mode-map}"
  :syntax-table factor-mode-syntax-table
  (buffer-disable-undo)

  (suppress-keymap fuel-xref-mode-map)
  (set-keymap-parent fuel-xref-mode-map button-buffer-map)
  (define-key fuel-xref-mode-map "h" 'fuel-xref-show-help)

  (setq buffer-read-only t))


(provide 'fuel-xref)

;;; fuel-xref.el ends here
