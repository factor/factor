;;; fuel-listener.el --- starting the fuel listener

;; Copyright (C) 2008, 2009  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Commentary:

;; Utilities to maintain and switch to a factor listener comint
;; buffer, with an accompanying major fuel-listener-mode.

;;; Code:

(require 'fuel-stack)
(require 'fuel-completion)
(require 'fuel-xref)
(require 'fuel-eval)
(require 'fuel-connection)
(require 'fuel-syntax)
(require 'fuel-base)

(require 'comint)


;;; Customization:

(defgroup fuel-listener nil
  "Interacting with a Factor listener inside Emacs."
  :group 'fuel)

(defcustom fuel-listener-factor-binary
  (expand-file-name (cond ((eq system-type 'windows-nt)
                           "factor.com")
                          ((eq system-type 'darwin)
                           "Factor.app/Contents/MacOS/factor")
                          (t "factor"))
                    fuel-factor-root-dir)
  "Full path to the factor executable to use when starting a listener."
  :type '(file :must-match t)
  :group 'fuel-listener)

(defcustom fuel-listener-factor-image
  (expand-file-name "factor.image" fuel-factor-root-dir)
  "Full path to the factor image to use when starting a listener."
  :type '(file :must-match t)
  :group 'fuel-listener)

(defcustom fuel-listener-use-other-window t
  "Use a window other than the current buffer's when switching to
the factor-listener buffer."
  :type 'boolean
  :group 'fuel-listener)

(defcustom fuel-listener-window-allow-split t
  "Allow window splitting when switching to the fuel listener
buffer."
  :type 'boolean
  :group 'fuel-listener)

(defcustom fuel-listener-history-filename (expand-file-name "~/.fuel_history")
  "File where listener input history is saved, so that it persists between sessions."
  :type 'filename
  :group 'fuel-listener)

(defcustom fuel-listener-history-size comint-input-ring-size
  "Maximum size of the saved listener input history."
  :type 'integer
  :group 'fuel-listener)


;;; Listener history:

(defun fuel-listener--sentinel (proc event)
  (when (string= event "finished\n")
    (with-current-buffer (process-buffer proc)
      (let ((comint-input-ring-file-name fuel-listener-history-filename))
        (comint-write-input-ring)
        (when (buffer-name (current-buffer))
          (insert "\nBye bye. It's been nice listening to you!\n")
          (insert "Press C-cz to bring me back.\n" ))))))

(defun fuel-listener--history-setup ()
  (set (make-local-variable 'comint-input-ring-file-name) fuel-listener-history-filename)
  (set (make-local-variable 'comint-input-ring-size) fuel-listener-history-size)
  (add-hook 'kill-buffer-hook 'comint-write-input-ring nil t)
  (comint-read-input-ring t)
  (set-process-sentinel (get-buffer-process (current-buffer)) 'fuel-listener--sentinel))


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
  (let ((factor (expand-file-name fuel-listener-factor-binary))
        (image (expand-file-name fuel-listener-factor-image))
        (comint-redirect-perform-sanity-check nil))
    (unless (file-executable-p factor)
      (error "Could not run factor: %s is not executable" factor))
    (unless (file-readable-p image)
      (error "Could not run factor: image file %s not readable" image))
    (message "Starting FUEL listener (this may take a while) ...")
    (pop-to-buffer (fuel-listener--buffer))
    (make-comint-in-buffer "fuel listener" (current-buffer) factor nil
                           "-run=listener" (format "-i=%s" image))
    (fuel-listener--wait-for-prompt 60000)
    (fuel-listener--history-setup)
    (fuel-con--setup-connection (current-buffer))))

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

(defalias 'switch-to-factor 'run-factor)
(defalias 'switch-to-fuel-listener 'run-factor)
;;;###autoload
(defun run-factor (&optional arg)
  "Show the fuel-listener buffer, starting the process if needed."
  (interactive)
  (let ((buf (process-buffer (fuel-listener--process t)))
        (pop-up-windows fuel-listener-window-allow-split))
    (if fuel-listener-use-other-window
        (pop-to-buffer buf)
      (switch-to-buffer buf))))

(defun connect-to-factor (&optional arg)
  "Connects to a remote listener running in the same host.
Without prefix argument, the default port, 9000, is used.
Otherwise, you'll be prompted for it. To make this work, in the
remote listener you need to issue the words
'fuel-start-remote-listener*' or 'port
fuel-start-remote-listener', from the fuel vocabulary."
  (interactive "P")
  (let ((port (if (not arg) 9000 (read-number "Port: "))))
    (fuel-listener--connect-process port)))

(defun fuel-listener-nuke ()
  "Try this command if the listener becomes unresponsive."
  (interactive)
  (goto-char (point-max))
  (comint-kill-region comint-last-input-start (point))
  (comint-redirect-cleanup)
  (fuel-con--setup-connection fuel-listener--buffer))

(defun fuel-refresh-all ()
  "Switch to the listener buffer and invokes Factor's refresh-all.
With prefix, you're teletransported to the listener's buffer."
  (interactive)
  (let ((buf (process-buffer (fuel-listener--process))))
    (pop-to-buffer buf)
    (comint-send-string nil "\"Refreshing loaded vocabs...\" write nl flush")
    (comint-send-string nil " refresh-all \"Done!\" write nl flush\n")))

(defun fuel-test-vocab (vocab)
  "Run the unit tests for the specified vocabulary."
  (interactive (list (fuel-completion--read-vocab nil (fuel-syntax--current-vocab))))
  (comint-send-string (fuel-listener--process)
                      (concat "\"" vocab "\" reload nl flush\n"
                              "\"" vocab "\" test nl flush\n")))


;;; Completion support

(defsubst fuel-listener--current-vocab () nil)
(defsubst fuel-listener--usings () nil)

(defun fuel-listener--setup-completion ()
  (setq fuel-syntax--current-vocab-function 'fuel-listener--current-vocab)
  (setq fuel-syntax--usings-function 'fuel-listener--usings))


;;; Stack mode support

(defun fuel-listener--stack-region ()
  (fuel--region-to-string (if (zerop (fuel-syntax--brackets-depth))
                              (comint-line-beginning-position)
                            (1+ (fuel-syntax--brackets-start)))))

(defun fuel-listener--setup-stack-mode ()
  (setq fuel-stack--region-function 'fuel-listener--stack-region))


;;; Fuel listener mode:

(defun fuel-listener--bol ()
  (interactive)
  (when (= (point) (comint-bol)) (beginning-of-line)))

;;;###autoload
(define-derived-mode fuel-listener-mode comint-mode "Fuel Listener"
  "Major mode for interacting with an inferior Factor listener process.
\\{fuel-listener-mode-map}"
  (set (make-local-variable 'comint-prompt-regexp) fuel-con--prompt-regex)
  (set (make-local-variable 'comint-use-prompt-regexp) t)
  (set (make-local-variable 'comint-prompt-read-only) t)
  (fuel-listener--setup-completion)
  (fuel-listener--setup-stack-mode))

(define-key fuel-listener-mode-map "\C-cz" 'run-factor)
(define-key fuel-listener-mode-map "\C-c\C-z" 'run-factor)
(define-key fuel-listener-mode-map "\C-a" 'fuel-listener--bol)
(define-key fuel-listener-mode-map "\C-ca" 'fuel-autodoc-mode)
(define-key fuel-listener-mode-map "\C-ch" 'fuel-help)
(define-key fuel-listener-mode-map "\C-cr" 'fuel-refresh-all)
(define-key fuel-listener-mode-map "\C-cs" 'fuel-stack-mode)
(define-key fuel-listener-mode-map "\C-cp" 'fuel-apropos)
(define-key fuel-listener-mode-map "\M-." 'fuel-edit-word-at-point)
(define-key fuel-listener-mode-map "\C-cv" 'fuel-edit-vocabulary)
(define-key fuel-listener-mode-map "\C-c\C-v" 'fuel-edit-vocabulary)
(define-key fuel-listener-mode-map "\C-ck" 'fuel-run-file)
(define-key fuel-listener-mode-map (kbd "TAB") 'fuel-completion--complete-symbol)


(provide 'fuel-listener)
;;; fuel-listener.el ends here
