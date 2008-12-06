;;; fuel-listener.el --- starting the fuel listener

;; Copyright (C) 2008  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Commentary:

;; Utilities to maintain and switch to a factor listener comint
;; buffer, with an accompanying major fuel-listener-mode.

;;; Code:

(require 'fuel-eval)
(require 'fuel-base)
(require 'comint)


;;; Customization:

(defgroup fuel-listener nil
  "Interacting with a Factor listener inside Emacs"
  :group 'fuel)

(defcustom fuel-listener-factor-binary "~/factor/factor"
  "Full path to the factor executable to use when starting a listener."
  :type '(file :must-match t)
  :group 'fuel-listener)

(defcustom fuel-listener-factor-image "~/factor/factor.image"
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


;;; Fuel listener buffer/process:

(defvar fuel-listener-buffer nil
  "The buffer in which the Factor listener is running.")

(defun fuel-listener--start-process ()
  (let ((factor (expand-file-name fuel-listener-factor-binary))
        (image (expand-file-name fuel-listener-factor-image)))
    (unless (file-executable-p factor)
      (error "Could not run factor: %s is not executable" factor))
    (unless (file-readable-p image)
      (error "Could not run factor: image file %s not readable" image))
    (setq fuel-listener-buffer
          (make-comint "fuel listener" factor nil "-run=fuel" (format "-i=%s" image)))
    (with-current-buffer fuel-listener-buffer
      (fuel-listener-mode))))

(defun fuel-listener--process (&optional start)
  (or (and (buffer-live-p fuel-listener-buffer)
           (get-buffer-process fuel-listener-buffer))
      (if (not start)
          (error "No running factor listener (try M-x run-factor)")
        (fuel-listener--start-process)
        (fuel-listener--process))))

(setq fuel-eval--default-proc-function 'fuel-listener--process)


;;; Interface: starting fuel listener

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


;;; Fuel listener mode:

(defconst fuel-listener--prompt-regex "( [^)]* ) ")

(defun fuel-listener--wait-for-prompt (&optional timeout)
  (let ((proc (fuel-listener--process)))
    (with-current-buffer fuel-listener-buffer
      (goto-char comint-last-input-end)
      (while (not (or (re-search-forward comint-prompt-regexp nil t)
                      (not (accept-process-output proc timeout))))
        (goto-char comint-last-input-end))
      (goto-char (point-max)))))

(defun fuel-listener--startup ()
  (fuel-listener--wait-for-prompt)
  (fuel-eval--send-string "USE: fuel")
  (message "FUEL listener up and running!"))

(define-derived-mode fuel-listener-mode comint-mode "Fuel Listener"
  "Major mode for interacting with an inferior Factor listener process.
\\{fuel-listener-mode-map}"
  (set (make-local-variable 'comint-prompt-regexp)
       fuel-listener--prompt-regex)
  (set (make-local-variable 'comint-prompt-read-only) t)
  (fuel-listener--startup))

;; (define-key fuel-listener-mode-map "\C-w" 'comint-kill-region)
;; (define-key fuel-listener-mode-map "\C-k" 'comint-kill-whole-line)


(provide 'fuel-listener)
;;; fuel-listener.el ends here
