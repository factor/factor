;;; fuel-mode.el -- Minor mode enabling FUEL niceties

;; Copyright (C) 2008, 2009, 2010 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 06, 2008 00:52

;;; Comentary:

;; Enhancements to vanilla factor-mode (notably, listener interaction)
;; enabled by means of a minor mode.

;;; Code:

(require 'fuel-listener)
(require 'fuel-completion)
(require 'fuel-debug)
(require 'fuel-debug-uses)
(require 'fuel-eval)
(require 'fuel-help)
(require 'fuel-xref)
(require 'fuel-refactor)
(require 'fuel-stack)
(require 'fuel-autodoc)
(require 'fuel-font-lock)
(require 'fuel-edit)
(require 'fuel-syntax)
(require 'fuel-menu)
(require 'fuel-base)


;;; Customization:

(defgroup fuel-mode nil
  "Mode enabling FUEL's ultimate abilities."
  :group 'fuel)

(defcustom fuel-mode-autodoc-p t
  "Whether `fuel-autodoc-mode' gets enabled by default in factor buffers."
  :group 'fuel-mode
  :group 'fuel-autodoc
  :type 'boolean)

(defcustom fuel-mode-stack-p nil
  "Whether `fuel-stack-mode' gets enabled by default in factor buffers."
  :group 'fuel-mode
  :group 'fuel-stack
  :type 'boolean)


;;; User commands

(defun fuel-mode--read-file (arg)
  (let* ((file (or (and arg (read-file-name "File: " nil (buffer-file-name) t))
                   (buffer-file-name)))
         (file (expand-file-name file))
         (buffer (find-file-noselect file)))
    (when (and  buffer
                (buffer-modified-p buffer)
                (y-or-n-p "Save file? "))
      (save-buffer buffer))
    (cons file buffer)))

(defun fuel-run-file (&optional arg)
  "Sends the current file to Factor for compilation.
With prefix argument, ask for the file to run."
  (interactive "P")
  (let* ((f/b (fuel-mode--read-file arg))
         (file (car f/b))
         (buffer (cdr f/b)))
    (when buffer
      (with-current-buffer buffer
        (let ((msg (format "Compiling %s ..." file)))
          (fuel-debug--prepare-compilation file msg)
          (message msg)
          (fuel-eval--send `(:fuel (,file fuel-run-file))
                           `(lambda (r) (fuel--run-file-cont r ,file))))))))

(defun fuel--run-file-cont (ret file)
  (if (fuel-debug--display-retort ret (format "%s successfully compiled" file))
      (message "Compiling %s ... OK!" file)
    (message "")))

(defun fuel-eval-region (begin end &optional arg)
  "Sends region to Fuel's listener for evaluation.
Unless called with a prefix, switches to the compilation results
buffer in case of errors."
  (interactive "r\nP")
  (let* ((rstr (buffer-substring begin end))
         (lines (split-string (substring-no-properties rstr)
                              "[\f\n\r\v]+"
                              t))
         (cmd `(:fuel (,(mapcar (lambda (l) `(:factor ,l)) lines))))
         (cv (fuel-syntax--current-vocab)))
    (fuel-debug--prepare-compilation (buffer-file-name)
                                     (format "Evaluating:\n\n%s" rstr))
    (fuel-debug--display-retort
     (fuel-eval--send/wait cmd 10000)
     (format "%s%s"
             (if cv (format "IN: %s " cv) "")
             (fuel--shorten-region begin end 70))
     arg)))

(defun fuel-eval-extended-region (begin end &optional arg)
  "Sends region, extended outwards to nearest definition,
to Fuel's listener for evaluation.
Unless called with a prefix, switches to the compilation results
buffer in case of errors."
  (interactive "r\nP")
  (fuel-eval-region (save-excursion (goto-char begin) (mark-defun) (point))
                    (save-excursion (goto-char end) (mark-defun) (mark))
                    arg))

(defun fuel-eval-definition (&optional arg)
  "Sends definition around point to Fuel's listener for evaluation.
Unless called with a prefix, switches to the compilation results
buffer in case of errors."
  (interactive "P")
  (save-excursion
    (mark-defun)
    (let* ((begin (point))
           (end (mark)))
      (unless (< begin end) (error "No evaluable definition around point"))
      (fuel-eval-region begin end arg))))

(defun fuel-update-usings (&optional arg)
  "Asks factor for the vocabularies needed by this file,
optionally updating the its USING: line.
With prefix argument, ask for the file name."
  (interactive "P")
  (let ((file (car (fuel-mode--read-file arg))))
    (when file (fuel-debug--uses-for-file file))))

(defun fuel-load-usings ()
  "Loads all vocabularies in the current buffer's USING: from.
Useful to activate autodoc help messages in a vocabulary not yet
loaded. See documentation for `fuel-autodoc-eval-using-form-p'
for details."
  (interactive)
  (message "Loading all vocabularies in USING: form ...")
  (let ((err (fuel-eval--retort-error
              (fuel-eval--send/wait '(:fuel* (t .) t :usings) 120000))))
    (message (if err "Warning: some vocabularies failed to load"
               "All vocabularies loaded"))))


;;; Minor mode definition:

(make-variable-buffer-local
 (defvar fuel-mode-string " F"
   "Modeline indicator for fuel-mode"))

(defvar fuel-mode-map (make-sparse-keymap)
  "Key map for fuel-mode")

(define-minor-mode fuel-mode
  "Toggle Fuel's mode.
With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode.

When Fuel mode is enabled, a host of nice utilities for
interacting with a factor listener is at your disposal.
\\{fuel-mode-map}"
  :init-value nil
  :lighter fuel-mode-string
  :group 'fuel
  :keymap fuel-mode-map

  (setq fuel-autodoc-mode-string "/A")
  (when fuel-mode-autodoc-p (fuel-autodoc-mode fuel-mode))

  (setq fuel-stack-mode-string "/S")
  (when fuel-mode-stack-p (fuel-stack-mode fuel-mode))

  (let ((file-name (buffer-file-name)))
    (when (and fuel-mode
               file-name
               (not (file-exists-p file-name)))
      (fuel-scaffold--maybe-insert))))


;;; Keys and menu:

(fuel-menu--defmenu fuel fuel-mode-map
  ("Complete symbol" ((kbd "M-TAB"))
   fuel-completion--complete-symbol :enable (symbol-at-point))
  ("Update USING:" ("\C-c\C-e\C-u" "\C-c\C-eu") fuel-update-usings)
  --
  ("Eval definition" ("\C-\M-x" "\C-c\C-e\C-x" "\C-c\C-ex")
   fuel-eval-definition)
  ("Eval extended region" ("\C-\M-r" "\C-c\C-e\C-e" "\C-c\C-ee")
   fuel-eval-extended-region :enable mark-active)
  ("Eval region" ("\C-c\C-r" "\C-c\C-e\C-r" "\C-c\C-er")
   fuel-eval-region :enable mark-active)
  --
  ("Edit word at point" ("\M-." "\C-c\C-e\C-d" "\C-c\C-ed")
   fuel-edit-word-at-point :enable (symbol-at-point))
  ("Edit word..." ("\C-c\C-e\C-w" "\C-c\C-ew") fuel-edit-word)
  ("Edit vocab..." ("\C-c\C-e\C-v" "\C-c\C-ev") fuel-edit-vocabulary)
  ("Jump back" "\M-," fuel-edit-pop-edit-word-stack)
  --
  ("Help on word" ("\C-c\C-d\C-d" "\C-c\C-dd") fuel-help)
  ("Short help on word" ("\C-c\C-d\C-s" "\C-c\C-ds") fuel-help)
  ("Apropos..." ("\C-c\C-d\C-p" "\C-c\C-dp") fuel-apropos)
  ("Show stack effect" ("\C-c\C-d\C-e" "\C-c\C-de") fuel-stack-effect-sexp)
  --
  ("Show all words" ("\C-c\C-d\C-v" "\C-c\C-dv") fuel-show-file-words)
  ("Word callers" "\C-c\M-<" fuel-show-callers :enable (symbol-at-point))
  ("Word callees" "\C-c\M->" fuel-show-callees :enable (symbol-at-point))
  (mode "Autodoc mode" ("\C-c\C-d\C-a" "\C-c\C-da") fuel-autodoc-mode)
  --
  (menu "Refactor"
        ("Rename word" ("\C-c\C-x\C-w" "\C-c\C-xw") fuel-refactor-rename-word)
        ("Inline word" ("\C-c\C-x\C-i" "\C-c\C-xi") fuel-refactor-inline-word)
        ("Extract region" ("\C-c\C-x\C-r" "\C-c\C-xr")
         fuel-refactor-extract-region :enable mark-active)
        ("Extract subregion" ("\C-c\C-x\C-s" "\C-c\C-xs")
         fuel-refactor-extract-sexp)
        ("Extract vocab" ("\C-c\C-x\C-v" "\C-c\C-xv")
         fuel-refactor-extract-vocab)
        ("Make generic" ("\C-c\C-x\C-g" "\C-c\C-xg")
         fuel-refactor-make-generic)
        --
        ("Extract article" ("\C-c\C-x\C-a" "\C-c\C-xa")
         fuel-refactor-extract-article))
  --
  ("Load used vocabs" ("\C-c\C-e\C-l" "\C-c\C-el") fuel-load-usings)
  ("Run file" ("\C-c\C-k" "\C-c\C-l" "\C-c\C-e\C-k") fuel-run-file)
  ("Run unit tests" "\C-c\C-t" fuel-test-vocab)
  ("Refresh vocabs" "\C-c\C-r" fuel-refresh-all)
  --
  (menu "Switch to"
        ("Listener" "\C-c\C-z" run-factor)
        ("Related Factor file" "\C-c\C-o" factor-mode-visit-other-file)
        ("Other Factor buffer" "\C-c\C-s" fuel-switch-to-buffer)
        ("Other Factor buffer other window" "\C-x4s"
         fuel-switch-to-buffer-other-window)
        ("Other Factor buffer other frame" "\C-x5s"
         fuel-switch-to-buffer-other-frame)))


(provide 'fuel-mode)
;;; fuel-mode.el ends here
