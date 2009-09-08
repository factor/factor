;;; fuel-log.el -- logging utilities

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sun Dec 14, 2008 01:00

;;; Comentary:

;; Some utilities for maintaining a simple log buffer, mainly for
;; debugging purposes.

;;; Code:

(require 'fuel-base)


;;; Customization:

(defvar fuel-log--buffer-name "*fuel messages*"
  "Name of the log buffer")

(defvar fuel-log--max-buffer-size 32000
  "Maximum size of the Factor messages log")

(defvar fuel-log--max-message-size 512
  "Maximum size of individual log messages")

(defvar fuel-log--verbose-p t
  "Log level for Factor messages")

(defvar fuel-log--inhibit-p nil
  "Set this to t to inhibit all log messages")

(defvar fuel-log--debug-p nil
  "If t, all messages are logged no matter what")

(define-derived-mode factor-messages-mode fundamental-mode "FUEL Messages"
  "Simple mode to log interactions with the factor listener"
  (kill-all-local-variables)
  (buffer-disable-undo)
  (set (make-local-variable 'comint-redirect-subvert-readonly) t)
  (add-hook 'after-change-functions
            '(lambda (b e len)
               (let ((inhibit-read-only t))
                 (when (> b fuel-log--max-buffer-size)
                   (delete-region (point-min) b))))
            nil t)
  (setq buffer-read-only t))

(defun fuel-log--buffer ()
  (or (get-buffer fuel-log--buffer-name)
      (save-current-buffer
        (set-buffer (get-buffer-create fuel-log--buffer-name))
        (factor-messages-mode)
        (current-buffer))))

(defun fuel-log--msg (type &rest args)
  (when (or fuel-log--debug-p (not fuel-log--inhibit-p))
    (with-current-buffer (fuel-log--buffer)
      (let ((inhibit-read-only t))
        (insert
         (fuel--shorten-str (format "\n%s: %s\n" type (apply 'format args))
                            fuel-log--max-message-size))))))

(defsubst fuel-log--warn (&rest args)
  (apply 'fuel-log--msg 'WARNING args))

(defsubst fuel-log--error (&rest args)
  (apply 'fuel-log--msg 'ERROR args))

(defsubst fuel-log--info (&rest args)
  (when fuel-log--verbose-p
    (apply 'fuel-log--msg 'INFO args) ""))


(provide 'fuel-log)
;;; fuel-log.el ends here
