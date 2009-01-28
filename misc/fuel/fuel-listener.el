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
    (setq fuel-listener-buffer (get-buffer-create "*fuel listener*"))
    (with-current-buffer fuel-listener-buffer
      (fuel-listener-mode)
      (message "Starting FUEL listener ...")
      (comint-exec fuel-listener-buffer "factor"
                   factor nil `("-run=fuel" ,(format "-i=%s" image)))
      (fuel-listener--wait-for-prompt 20)
      (fuel-eval--send/wait "USE: fuel")
      (message "FUEL listener up and running!"))))

(defun fuel-listener--process (&optional start)
  (or (and (buffer-live-p fuel-listener-buffer)
           (get-buffer-process fuel-listener-buffer))
      (if (not start)
          (error "No running factor listener (try M-x run-factor)")
        (fuel-listener--start-process)
        (fuel-listener--process))))

(setq fuel-eval--default-proc-function 'fuel-listener--process)


;;; Prompt chasing

(defun fuel-listener--wait-for-prompt (&optional timeout)
  (let ((proc (get-buffer-process fuel-listener-buffer)))
    (with-current-buffer fuel-listener-buffer
      (goto-char (or comint-last-input-end (point-min)))
      (let ((seen (re-search-forward comint-prompt-regexp nil t)))
        (while (and (not seen)
                    (accept-process-output proc (or timeout 10) nil t))
          (sleep-for 0 1)
          (goto-char comint-last-input-end)
          (setq seen (re-search-forward comint-prompt-regexp nil t)))
        (pop-to-buffer fuel-listener-buffer)
        (goto-char (point-max))
        (unless seen (error "No prompt found!"))))))


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

(define-derived-mode fuel-listener-mode comint-mode "Fuel Listener"
  "Major mode for interacting with an inferior Factor listener process.
\\{fuel-listener-mode-map}"
  (set (make-local-variable 'comint-prompt-regexp)
       fuel-listener--prompt-regex)
  (set (make-local-variable 'comint-prompt-read-only) t)
  (setq fuel-listener--compilation-begin nil))

(define-key fuel-listener-mode-map "\C-cz" 'run-factor)
(define-key fuel-listener-mode-map "\C-c\C-z" 'run-factor)
(define-key fuel-listener-mode-map "\C-ch" 'fuel-help)
(define-key fuel-listener-mode-map "\M-." 'fuel-edit-word-at-point)
(define-key fuel-listener-mode-map "\C-ck" 'fuel-run-file)


(provide 'fuel-listener)
;;; fuel-listener.el ends here
