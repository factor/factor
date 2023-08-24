;;; fuel-menu.el -- menu utilities -*- lexical-binding: t -*-

;; Copyright (c) 2010 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Jun 12, 2010 03:01


(require 'fuel-base)


;;; Top-level menu

(defmacro fuel-menu--add-item (keymap map kd)
  (cond ((or (eq '-- kd) (eq 'line kd)) `(fuel-menu--add-line ,map))
        ((stringp (car kd)) `(fuel-menu--add-basic-item ,keymap ,map ,kd))
        ((eq 'menu (car kd)) `(fuel-menu--add-submenu ,(cadr kd)
                                ,keymap ,map ,(cddr kd)))
        ((eq 'custom (car kd)) `(fuel-menu--add-custom ,(nth 1 kd)
                                                         ,(nth 2 kd)
                                                         ,keymap
                                                         ,map))
        ((eq 'mode (car kd)) `(fuel-menu--mode-toggle ,(nth 1 kd)
                                                        ,(nth 2 kd)
                                                        ,(nth 3 kd)
                                                        ,keymap
                                                        ,map))
        (t (error "Bad item form: %s" kd))))

(defmacro fuel-menu--add-basic-item (keymap map kd)
  (let* ((title (nth 0 kd))
         (binding (nth 1 kd))
         (cmd (nth 2 kd))
         (hlp (nth 3 kd))
         (item (make-symbol title))
         (hlp (and (stringp hlp) (list :help hlp)))
         (rest (or (and hlp (nthcdr 4 kd))
                   (nthcdr 3 kd)))
         (binding (if (listp binding)
                      binding
                    (list binding))))
    `(progn (define-key ,map [,item]
              '(menu-item ,title ,cmd ,@hlp ,@rest))
            ,@(and (car binding)
                   `((put ',cmd
                          :advertised-binding
                          ,(car binding))))
            ,@(mapcar (lambda (b)
                        `(define-key ,keymap ,b ',cmd))
                      binding))))

(defmacro fuel-menu--add-items (keymap map keys)
  `(progn ,@(mapcar (lambda (k) (list 'fuel-menu--add-item keymap map k))
                    (reverse keys))))

(defmacro fuel-menu--add-submenu (name keymap map keys)
  (let ((ev (make-symbol name))
        (map2 (make-symbol "map2")))
    `(progn
       (let ((,map2 (make-sparse-keymap ,name)))
         (define-key ,map [,ev] (cons ,name ,map2))
         (fuel-menu--add-items ,keymap ,map2 ,keys)))))

(defvar fuel-menu--line-counter 0)

(defun fuel-menu--add-line (&optional map)
  (let ((line (make-symbol (format "line%s"
                                   (setq fuel-menu--line-counter
                                         (1+ fuel-menu--line-counter))))))
    (define-key (or map global-map) `[,line]
      `(menu-item "--single-line"))))

(defmacro fuel-menu--add-custom (title group keymap map)
  `(fuel-menu--add-item ,keymap ,map
     (,title nil (lambda () (interactive) (customize-group ',group)))))

(defmacro fuel-menu--mode-toggle (title bindings mode keymap map)
  `(fuel-menu--add-item ,keymap ,map
     (,title ,bindings ,mode
             :button (:toggle . (and (boundp ',mode) ,mode)))))

(defmacro fuel-menu--defmenu (name keymap &rest keys)
  (declare (indent 2))
  (let ((mmap (make-symbol "mmap")))
    `(progn
       (let ((,mmap (make-sparse-keymap "FUEL")))
         (define-key ,keymap [menu-bar ,name] (cons "FUEL" ,mmap))
         (define-key ,mmap [customize]
           (cons "Customize FUEL"
                 `(lambda () (interactive) (customize-group 'fuel))))
         (fuel-menu--add-line ,mmap)
         (fuel-menu--add-items ,keymap ,mmap ,keys)
         ,mmap))))


(provide 'fuel-menu)

;;; fuel-menu.el ends here
