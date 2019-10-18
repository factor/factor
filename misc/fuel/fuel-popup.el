;;; fuel-popup.el -- popup windows

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sun Dec 21, 2008 14:37

;;; Comentary:

;; A minor mode to pop up windows and restore configurations
;; afterwards.

;;; Code:

(make-variable-buffer-local
 (defvar fuel-popup--created-window nil))

(make-variable-buffer-local
 (defvar fuel-popup--selected-window nil))

(defun fuel-popup--display (&optional buffer)
  (when buffer (set-buffer buffer))
  (let ((selected-window (selected-window))
        (buffer (current-buffer)))
    (unless (eq selected-window (get-buffer-window buffer))
      (let ((windows))
        (walk-windows (lambda (w) (push w windows)) nil t)
        (prog1 (pop-to-buffer buffer)
          (set (make-local-variable 'fuel-popup--created-window)
               (unless (memq (selected-window) windows) (selected-window)))
          (set (make-local-variable 'fuel-popup--selected-window)
               selected-window))))))

(defun fuel-popup--quit ()
  (interactive)
  (let ((selected fuel-popup--selected-window)
        (created fuel-popup--created-window))
    (bury-buffer)
    (when (eq created (selected-window)) (delete-window created))
    (when (window-live-p selected) (select-window selected))))

(define-minor-mode fuel-popup-mode
  "Mode for displaying read only stuff"
  nil nil
  '(("q" . fuel-popup--quit))
  (setq buffer-read-only t))

(defmacro fuel-popup--define (fun name mode)
  `(defun ,fun ()
     (or (get-buffer ,name)
         (with-current-buffer (get-buffer-create ,name)
           (funcall ,mode)
           (fuel-popup-mode)
           (current-buffer)))))

(put 'fuel-popup--define 'lisp-indent-function 1)

(defmacro fuel--with-popup (buffer &rest body)
  `(with-current-buffer ,buffer
     (let ((inhibit-read-only t))
       ,@body)))

(put 'fuel--with-popup 'lisp-indent-function 1)


(provide 'fuel-popup)
;;; fuel-popup.el ends here
