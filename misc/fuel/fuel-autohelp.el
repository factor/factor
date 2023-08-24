;;; fuel-autohelp.el -- help pages in another window -*- lexical-binding: t -*-

;; Copyright (C) 2013 Erik Charlebois
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Erik Charlebois <erikcharlebois@gmail.com>
;; Keywords: languages, fuel, factor
;; Start date: Mon Mar 25, 2012, 11:46

;;; Commentary:

;; Utilities for displaying help in a side window.

;;; Code:

(require 'fuel-base)
(require 'fuel-help)
(require 'factor-mode)


;;; Customization:

;;;###autoload
(defgroup fuel-autohelp nil
  "Options controlling FUEL's autohelp system."
  :group 'fuel)

(defcustom fuel-autohelp-idle-delay 0.7
  "Number of seconds of idle time to wait before printing.
If user input arrives before this interval of time has elapsed after the
last input, no documentation will be printed.

If this variable is set to 0, no idle time is required."
  :type 'number
  :group 'fuel-autohelp)


;;; Helper function:
(defvar fuel-autohelp-timer nil "Autohelp's timer object.")

(defvar fuel-autohelp-current-idle-delay fuel-autohelp-idle-delay
  "Idle time delay currently in use by timer.
This is used to determine if `fuel-autohelp-idle-delay' is changed by the
user.")

(defun fuel-autohelp-show-current-symbol-help ()
  (condition-case err
      (when (and (boundp 'fuel-autohelp-mode) fuel-autohelp-mode)
        (let ((word (factor-symbol-at-point))
              (fuel-log--inhibit-p t))
          (when word
            (fuel-help--word-help word t))))
    (error (message "FUEL Autohelp error: %s" err))))

(defun fuel-autohelp-schedule-timer ()
  (or (and fuel-autohelp-timer
           (memq fuel-autohelp-timer timer-idle-list))
      (setq fuel-autohelp-timer
            (run-with-idle-timer fuel-autohelp-idle-delay t
                                 'fuel-autohelp-show-current-symbol-help)))

  ;; If user has changed the idle delay, update the timer.
  (cond ((not (= fuel-autohelp-idle-delay fuel-autohelp-current-idle-delay))
         (setq fuel-autohelp-current-idle-delay fuel-autohelp-idle-delay)
         (timer-set-idle-time fuel-autohelp-timer fuel-autohelp-idle-delay t))))


;;; Autohelp mode:

(defvar-local fuel-autohelp-mode-string " H"
  "Modeline indicator for fuel-autohelp-mode")

;;;###autoload
(define-minor-mode fuel-autohelp-mode
  "Toggle Fuel's Autohelp mode.
With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode.

When Autohelp mode is enabled, the help for the word is displayed
in another window."
  :init-value nil
  :lighter fuel-autohelp-mode-string
  :group 'fuel-autohelp

  (if fuel-autohelp-mode
      (add-hook 'post-command-hook 'fuel-autohelp-schedule-timer nil t)
    (remove-hook 'post-command-hook 'fuel-autohelp-schedule-timer)))

;;;###autoload
(defun turn-on-fuel-autohelp-mode ()
  "Unequivocally turn on FUEL's Autohelp mode (see command
`fuel-autohelp-mode')."
  (interactive)
  (fuel-autohelp-mode 1))


(provide 'fuel-autohelp)

;;; fuel-autohelp.el ends here
