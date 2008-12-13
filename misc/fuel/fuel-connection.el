;;; fuel-connection.el -- asynchronous comms with the fuel listener

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Thu Dec 11, 2008 03:10

;;; Comentary:

;; Handling communications via a comint buffer running a factor
;; listener.

;;; Code:


;;; Default connection:

(make-variable-buffer-local
 (defvar fuel-con--connection nil))

(defun fuel-con--get-connection (buffer/proc)
  (if (processp buffer/proc)
      (fuel-con--get-connection (process-buffer buffer/proc))
    (with-current-buffer buffer/proc
      (or fuel-con--connection
          (setq fuel-con--connection
                (fuel-con--setup-connection buffer/proc))))))


;;; Request and connection datatypes:

(defun fuel-con--connection-queue-request (c r)
  (let ((reqs (assoc :requests c)))
    (setcdr reqs (append (cdr reqs) (list r)))))

(defun fuel-con--make-request (str cont &optional sender-buffer)
  (list :fuel-connection-request
        (cons :id (random))
        (cons :string str)
        (cons :continuation cont)
        (cons :buffer (or sender-buffer (current-buffer)))))

(defsubst fuel-con--request-p (req)
  (and (listp req) (eq (car req) :fuel-connection-request)))

(defsubst fuel-con--request-id (req)
  (cdr (assoc :id req)))

(defsubst fuel-con--request-string (req)
  (cdr (assoc :string req)))

(defsubst fuel-con--request-continuation (req)
  (cdr (assoc :continuation req)))

(defsubst fuel-con--request-buffer (req)
  (cdr (assoc :buffer req)))

(defsubst fuel-con--request-deactivate (req)
  (setcdr (assoc :continuation req) nil))

(defsubst fuel-con--request-deactivated-p (req)
  (null (cdr (assoc :continuation req))))

(defsubst fuel-con--make-connection (buffer)
  (list :fuel-connection
        (list :requests)
        (list :current)
        (cons :completed (make-hash-table :weakness 'value))
        (cons :buffer buffer)))

(defsubst fuel-con--connection-p (c)
  (and (listp c) (eq (car c) :fuel-connection)))

(defsubst fuel-con--connection-requests (c)
  (cdr (assoc :requests c)))

(defsubst fuel-con--connection-current-request (c)
  (cdr (assoc :current c)))

(defun fuel-con--connection-clean-current-request (c)
  (let* ((cell (assoc :current c))
         (req (cdr cell)))
    (when req
      (puthash (fuel-con--request-id req) req (cdr (assoc :completed c)))
      (setcdr cell nil))))

(defsubst fuel-con--connection-completed-p (c id)
  (gethash id (cdr (assoc :completed c))))

(defsubst fuel-con--connection-buffer (c)
  (cdr (assoc :buffer c)))

(defun fuel-con--connection-pop-request (c)
  (let ((reqs (assoc :requests c))
        (current (assoc :current c)))
    (setcdr current (prog1 (cadr reqs) (setcdr reqs (cddr reqs))))
    (if (and current (fuel-con--request-deactivated-p current))
        (fuel-con--connection-pop-request c)
      current)))


;;; Connection setup:

(defun fuel-con--setup-connection (buffer)
  (set-buffer buffer)
  (let ((conn (fuel-con--make-connection buffer)))
    (fuel-con--setup-comint)
    (setq fuel-con--connection conn)))

(defun fuel-con--setup-comint ()
  (add-hook 'comint-redirect-filter-functions
            'fuel-con--comint-redirect-filter t t))


;;; Requests handling:

(defun fuel-con--process-next (con)
  (when (not (fuel-con--connection-current-request con))
    (let* ((buffer (fuel-con--connection-buffer con))
           (req (fuel-con--connection-pop-request con))
           (str (and req (fuel-con--request-string req))))
      (when (and buffer req str)
        (set-buffer buffer)
        (comint-redirect-send-command str
                                      (get-buffer-create "*factor messages*")
                                      nil
                                      t)))))

(defun fuel-con--comint-redirect-filter (str)
  (if (not fuel-con--connection)
      (format "\nERROR: No connection in buffer (%s)\n" str)
    (let ((req (fuel-con--connection-current-request fuel-con--connection)))
      (if (not req) (format "\nERROR: No current request (%s)\n" str)
        (let ((cont (fuel-con--request-continuation req))
              (id (fuel-con--request-id req))
              (rstr (fuel-con--request-string req))
              (buffer (fuel-con--request-buffer req)))
          (prog1
              (if (not cont)
                  (format "\nWARNING: Droping result for request %s:%S (%s)\n"
                          id rstr str)
                (condition-case cerr
                    (with-current-buffer (or buffer (current-buffer))
                      (funcall cont str)
                      (format "\nINFO: %s:%S processed\nINFO: %s\n" id rstr str))
                  (error (format "\nERROR: continuation failed %s:%S \nERROR: %s\n"
                                 id rstr cerr))))
            (fuel-con--connection-clean-current-request fuel-con--connection)))))))


;;; Message sending interface:

(defun fuel-con--send-string (buffer/proc str cont &optional sender-buffer)
  (save-current-buffer
    (let ((con (fuel-con--get-connection buffer/proc)))
      (unless con
        (error "FUEL: couldn't find connection"))
      (let ((req (fuel-con--make-request str cont sender-buffer)))
        (fuel-con--connection-queue-request con req)
        (fuel-con--process-next con)
        req))))

(defvar fuel-connection-timeout 30000
  "Time limit, in msecs, blocking on synchronous evaluation requests")

(defun fuel-con--send-string/wait (buffer/proc str cont &optional timeout sbuf)
  (save-current-buffer
    (let* ((con (fuel-con--get-connection buffer/proc))
         (req (fuel-con--send-string buffer/proc str cont sbuf))
         (id (and req (fuel-con--request-id req)))
         (time (or timeout fuel-connection-timeout))
         (step 2))
      (when id
        (while (and (> time 0)
                    (not (fuel-con--connection-completed-p con id)))
          (sleep-for 0 step)
          (setq time (- time step)))
        (or (> time 0)
            (fuel-con--request-deactivate req)
            nil)))))


(provide 'fuel-connection)
;;; fuel-connection.el ends here
