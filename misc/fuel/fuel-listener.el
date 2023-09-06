;;; fuel-listener.el --- starting the fuel listener -*- lexical-binding: t -*-

;; Copyright (C) 2008, 2009, 2010  Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Commentary:

;; Utilities to maintain and switch to a factor listener comint
;; buffer, with an accompanying major fuel-listener-mode.

;;; Code:

(require 'fuel-stack)
(require 'fuel-completion)
(require 'fuel-eval)
(require 'fuel-connection)
(require 'fuel-menu)
(require 'fuel-base)

(require 'comint)

;;; Customization:

;;;###autoload
(defgroup fuel-listener nil
  "Interacting with a Factor listener inside Emacs."
  :group 'fuel)

(defcustom fuel-factor-root-dir nil
  "Full path to the factor root directory when starting a listener."
  :type 'directory
  :group 'fuel-listener)

;;; Is factor.com still valid on Windows...?
(defcustom fuel-listener-factor-binary nil
  "Full path to the factor executable to use when starting a listener."
  :type '(file :must-match t)
  :group 'fuel-listener)

(defcustom fuel-listener-factor-image nil
  "Full path to the factor image to use when starting a listener."
  :type '(file :must-match t)
  :group 'fuel-listener)

(defcustom fuel-listener-use-other-window t
  "Use a window other than the current buffer's when switching to
the factor-listener buffer."
  :type 'boolean
  :group 'fuel-listener)

(defcustom fuel-listener-history-filename
  (expand-file-name "~/.fuel_history.eld")
  "File where listener input history is saved, so that it persists between
sessions."
  :type 'filename
  :group 'fuel-listener)

(defcustom fuel-listener-history-size comint-input-ring-size
  "Maximum size of the saved listener input history."
  :type 'integer
  :group 'fuel-listener)

(defcustom fuel-listener-prompt-read-only-p t
  "Whether listener's prompt should be read-only."
  :type 'boolean
  :group 'fuel-listener)


;;; Factor paths:

(defun fuel-listener-factor-binary ()
  "Full path to the factor executable to use when starting a listener."
  (or fuel-listener-factor-binary
      (expand-file-name (cond ((eq system-type 'windows-nt)
                               "factor.com")
                              ((eq system-type 'darwin)
                               "Factor.app/Contents/MacOS/factor")
                              (t "factor"))
                        fuel-factor-root-dir)))

(defun fuel-listener-factor-image ()
  "Full path to the factor image to use when starting a listener."
  (or fuel-listener-factor-image
      (expand-file-name "factor.image" fuel-factor-root-dir)))


;;; Listener history:

(defun fuel-listener--sentinel (proc event)
  (when (string= event "finished\n")
    (with-current-buffer (process-buffer proc)
      (let ((comint-input-ring-file-name fuel-listener-history-filename))
        (comint-write-input-ring)
        (when (buffer-name (current-buffer))
          (insert "\nBye bye. It's been nice listening to you!\n")
          (insert "Press C-c C-z to bring me back.\n" ))))))

(defun fuel-listener--history-setup ()
  (setq-local comint-input-ring-file-name fuel-listener-history-filename)
  (setq-local comint-input-ring-size fuel-listener-history-size)
  (add-hook 'kill-buffer-hook 'comint-write-input-ring nil t)
  (comint-read-input-ring t)
  (set-process-sentinel (get-buffer-process (current-buffer))
                        'fuel-listener--sentinel))


;;; Fuel listener buffer/process:

(defvar fuel-listener--buffer nil
  "The buffer in which the Factor listener is running.")

(defun fuel-listener--buffer ()
  (if (buffer-live-p fuel-listener--buffer)
      fuel-listener--buffer
    (with-current-buffer (get-buffer-create "*fuel listener*")
      (fuel-listener-mode)
      (setq fuel-listener--buffer (current-buffer)))))

(defun fuel-listener--start-process ()
  (let ((factor (expand-file-name (fuel-listener-factor-binary)))
        (image (expand-file-name (fuel-listener-factor-image)))
        (comint-redirect-perform-sanity-check nil))
    (unless (file-executable-p factor)
      (error "Could not run factor: %s is not executable" factor))
    (unless (file-readable-p image)
      (error "Could not run factor: image file %s not readable" image))
    (message "Starting FUEL listener (this may take a while) ...")
    (pop-to-buffer (fuel-listener--buffer))
    (make-comint-in-buffer "fuel listener" (current-buffer) factor nil
                           "-run=fuel.listener" (format "-i=%s" image))
    (fuel-listener--wait-for-prompt 60000)
    (fuel-listener--history-setup)
    (fuel-con--setup-connection (current-buffer))))

;;; TODO Add the ability to debug to non-localhost
(defun fuel-listener--connect-process (port)
  (message "Connecting to remote listener ...")
  (pop-to-buffer (fuel-listener--buffer))
  (let ((process (get-buffer-process (current-buffer))))
    (when (or (not process)
              (y-or-n-p "Kill current listener? "))
      (make-comint-in-buffer "fuel listener" (current-buffer)
                             (cons "localhost" port))
      (fuel-listener--wait-for-prompt 10000)
      (fuel-con--setup-connection (current-buffer)))))

(defun fuel-listener--process (&optional start)
  (or (and (buffer-live-p (fuel-listener--buffer))
           (get-buffer-process (fuel-listener--buffer)))
      (if (not start)
          (error "No running factor listener (try M-x run-factor)")
        (fuel-listener--start-process)
        (fuel-listener--process))))

(setq fuel-eval--default-proc-function 'fuel-listener--process)

(defun fuel-listener--wait-for-prompt (timeout)
  (let ((p (point)) (seen))
    (while (and (not seen) (> timeout 0))
      (sleep-for 0.1)
      (setq timeout (- timeout 100))
      (goto-char p)
      (setq seen (re-search-forward comint-prompt-regexp nil t)))
    (goto-char (point-max))
    (unless seen (error "No prompt found!"))))


;;; Interface: starting and interacting with fuel listener:

;;;###autoload
(defun run-factor (&optional arg)
  "Show the fuel-listener buffer, starting the process if needed."
  (interactive)
  (let ((buf (process-buffer (fuel-listener--process t))))
    (if fuel-listener-use-other-window
        (pop-to-buffer buf)
      (switch-to-buffer buf))
    (add-hook 'factor-mode-hook 'fuel-mode)))

;;;###autoload
(defun connect-to-factor (&optional arg)
  "Connects to a remote listener running in the same host.
Without prefix argument, the default port, 9000, is used.
Otherwise, you'll be prompted for it. To make this work, in the
remote listener you need to issue the words
'fuel-start-remote-listener*' or 'port
fuel-start-remote-listener', from the fuel vocabulary."
  (interactive "P")
  (let ((port (if (not arg) 9000 (read-number "Port: "))))
    (fuel-listener--connect-process port)
    (add-hook 'factor-mode-hook 'fuel-mode))
  (other-window 1)
  (delete-other-windows))

(defun fuel-listener-nuke ()
  "Try this command if the listener becomes unresponsive."
  (interactive)
  (goto-char (point-max))
  (comint-kill-region comint-last-input-start (point))
  (comint-redirect-cleanup)
  (fuel-con--setup-connection fuel-listener--buffer))

(defun fuel-refresh-all (&optional arg)
  "Switch to the listener buffer and invokes Factor's refresh-all.
With prefix, you're teletransported to the listener's buffer."
  (interactive "P")
  (let ((buf (process-buffer (fuel-listener--process))))
    (with-current-buffer buf
      (comint-send-string nil "\"Refreshing loaded vocabs...\" write nl flush")
      (comint-send-string nil " refresh-all \"Done!\" write nl flush\n"))
    (when arg (pop-to-buffer buf))))

(defun fuel-refresh-and-test-all (&optional arg)
  "Switch to the listener buffer and invokes Factor's refresh-and-test-all.
With prefix, you're teletransporteded to the listener's buffer."
  (interactive "P")
  (let ((buf (process-buffer (fuel-listener--process))))
    (with-current-buffer buf
      (comint-send-string nil "\"Refreshing loaded vocabs and running tests...\" write nl flush")
      (comint-send-string nil " refresh-and-test-all \"Done!\" write nl flush\n"))
    (when arg (pop-to-buffer buf))))

(defun fuel-test-vocab (&optional arg)
  "Run the unit tests for the current vocabulary. With prefix argument, ask for
the vocabulary name."
  (interactive "P")
  (let* ((vocab (or (and (not arg) (factor-current-vocab))
                    (fuel-completion--read-vocab nil))))
    (comint-send-string (fuel-listener--process)
                        (concat "\"" vocab "\" reload nl flush\n"
                                "\"" vocab "\" test nl flush\n"))))


;;; Completion support:

(defsubst fuel-listener--current-vocab () nil)
(defsubst fuel-listener--usings () nil)

(defun fuel-listener--setup-completion ()
  (setq factor-current-vocab-function 'fuel-listener--current-vocab)
  (setq factor-usings-function 'fuel-listener--usings))


;;; Stack mode support:

(defun fuel-listener--stack-region ()
  (fuel-region-to-string
   (if (zerop (factor-brackets-depth))
       (comint-line-beginning-position)
     (1+ (factor-brackets-start)))))

(defun fuel-listener--setup-stack-mode ()
  (setq fuel-stack--region-function 'fuel-listener--stack-region))


;;; Fuel listener mode:

(defun fuel-listener--bol ()
  (interactive)
  (when (= (point) (comint-bol)) (beginning-of-line)))

;;;###autoload
(define-derived-mode fuel-listener-mode comint-mode "FUEL Listener"
  "Major mode for interacting with an inferior Factor listener process.
\\{fuel-listener-mode-map}"
  (setq-local comint-prompt-regexp fuel-con--prompt-regex)
  (setq-local comint-use-prompt-regexp nil)
  (setq-local comint-prompt-read-only fuel-listener-prompt-read-only-p)
  (fuel-listener--setup-completion)
  (fuel-listener--setup-stack-mode)
  (set-syntax-table (fuel-syntax-table)))

(define-key fuel-listener-mode-map "\C-a" 'fuel-listener--bol)

(fuel-menu--defmenu listener fuel-listener-mode-map
  ("Complete symbol" ((kbd "TAB") (kbd "M-TAB"))
   fuel-completion--complete-symbol :enable (symbol-at-point))
  --
  ("Edit word or vocab at point" "\M-." fuel-edit-word-at-point)
  ("Edit vocabulary" "\C-c\C-v" fuel-edit-vocabulary)
  --
  ("Help on word" "\C-c\C-w" fuel-help)
  ("Apropos..." "\C-c\C-p" fuel-apropos)
  (mode "Show stack mode" "\C-c\C-s" fuel-stack-mode)
  --
  (menu "Crossref"
        ("Word callers" "\C-c\M-<"
         fuel-show-callers :enable (symbol-at-point))
        ("Word callees" "\C-c\M->"
         fuel-show-callees :enable (symbol-at-point))
        (mode "Autodoc mode" "\C-c\C-a" fuel-autodoc-mode))
  ("Run file" "\C-c\C-k" fuel-run-file)
  ("Refresh vocabs" "\C-c\C-r" fuel-refresh-all)
  ("Refresh vocabs and test" "\C-c\M-r" fuel-refresh-and-test-all))

(define-key fuel-listener-mode-map [menu-bar completion] 'undefined)


(provide 'fuel-listener)

;;; fuel-listener.el ends here
