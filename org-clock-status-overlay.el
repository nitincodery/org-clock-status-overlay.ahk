(require 'org)

(defvar org-clock-status-overlay-timer nil
  "Timer for periodically writing Org clock status.")

(defvar org-clock-status-overlay-file "F:/home/org/org-clock-status.txt"
  "File to use to write status string.")

(defun org-get-valid-clock-string ()
  "Return the current org clock string, or nil if unavailable or invalid."
  (condition-case nil
      (let ((s (org-clock-get-clock-string)))
        (when (and s (not (string-empty-p s)))
          s))
    (error nil)))

(defun write-org-clock-status ()
  "Write current org-clock string to file, overwriting contents."
  (let ((clock-string (org-get-valid-clock-string)))
    (with-temp-file org-clock-status-overlay-file
      (when clock-string
        (insert (substring-no-properties clock-string))))))

(defun start-org-clock-status-timer ()
  "Start a timer to periodically write Org clock status,
only if clock string is available and valid."
  (interactive)
  (if-let ((clock-string (org-get-valid-clock-string)))
      (progn
        (setq org-clock-status-timer
              (run-at-time "0 sec" 30 #'write-org-clock-status))
        (write-org-clock-status)
        (message "Org clock status timer started."))
    (message "No active clock. Timer not started.")))

(defun stop-org-clock-status-timer ()
  "Stop the org-clock status timer and clear the file."
  (interactive)
  (if (timerp org-clock-status-timer)
      (progn
        (cancel-timer org-clock-status-timer)
        (setq org-clock-status-timer nil)
        (with-temp-file org-clock-status-overlay-file)
        (message "Org clock status timer stopped and file cleared."))
    (message "No org clock status timer is currently running.")))

(advice-add 'org-clock-in :after #'start-org-clock-status-timer)
(advice-add 'org-clock-out :after #'stop-org-clock-status-timer)
