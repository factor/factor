;;; fuel-popup.el -- popup windows -*- lexical-binding: t -*-

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sun Dec 21, 2008 14:37

;;; Comentary:

;; A minor mode to pop up windows and restore configurations
;; afterwards.

;;; Code:

(defvar-local fuel-popup--created-window nil)

(defvar-local fuel-popup--selected-window nil)

(defun fuel-popup--display (&optional buffer display-only)
  (when buffer (set-buffer buffer))
  (let ((selected-window (selected-window))
        (buffer (current-buffer)))
    (unless (eq selected-window (get-buffer-window buffer))
      (let ((windows))
        (walk-windows (lambda (w) (push w windows)) nil t)
        (prog1 (if display-only
                   (display-buffer buffer)
                 (pop-to-buffer buffer))
          (setq-local fuel-popup--created-window
               (unless (memq (selected-window) windows) (selected-window)))
          (setq-local fuel-popup--selected-window selected-window))))))

(defun fuel-popup--quit ()
  (interactive)
  (let ((selected fuel-popup--selected-window)
        (created fuel-popup--created-window))
    (bury-buffer)
    (when (eq created (selected-window)) (delete-window created))
    (when (window-live-p selected) (select-window selected))))

;;;###autoload
(define-minor-mode fuel-popup-mode
  "Mode for displaying read only stuff"
  nil nil
  '(("q" . fuel-popup--quit))
  (setq buffer-read-only t))


(provide 'fuel-popup)

;;; fuel-popup.el ends here
