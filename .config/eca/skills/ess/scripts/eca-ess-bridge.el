;;; eca-ess-bridge.el --- ESS R bridge for ECA -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)

(defun eca-ess-inferior-r-process (&optional buffer-name directory)
  "Return a live ESS R process.
If BUFFER-NAME is non-nil, prefer that exact buffer.
If DIRECTORY is non-nil, prefer a session whose `default-directory' matches.
Otherwise fall back to the most-recent iESS buffer.
Start one via (R) if none exists."
  (require 'ess-site nil t)
  (let* ((predicate (lambda (b)
                      (with-current-buffer b
                        (and (derived-mode-p 'inferior-ess-r-mode)
                             (get-buffer-process b)
                             (process-live-p (get-buffer-process b))))))
         (candidates (cl-remove-if-not predicate (buffer-list)))
         (buf (or
               ;; 1. Exact buffer name match
               (and buffer-name
                    (cl-find buffer-name candidates
                             :key #'buffer-name :test #'string=))
               ;; 2. Working directory match
               (and directory
                    (let ((dir (file-name-as-directory
                                (expand-file-name directory))))
                      (cl-find-if
                       (lambda (b)
                         (string-prefix-p
                          dir (with-current-buffer b default-directory)))
                       candidates)))
               ;; 3. MRU fallback
               (car candidates))))
    (if buf
        (get-buffer-process buf)
      ;; Start R if none found
      (when (fboundp 'R) (R))
      (or (get-buffer-process
           (cl-find-if predicate (buffer-list)))
          (error "No ESS R process found (and failed to start one)")))))

(defun eca-ess-send-and-capture (proc string &optional timeout)
  "Send STRING to PROC via ESS, wait, and return new output.
Output is captured from the process buffer."
  (let ((pbuf (process-buffer proc))
        (start (with-current-buffer (process-buffer proc) (point-max))))
    ;; Execute within the iESS buffer so ESS buffer-local variables
    ;; (ess-local-process-name, etc.) are available.
    (with-current-buffer pbuf
      (ess-send-string proc string 'nowait)
      (unless (ess-wait-for-process proc nil 0.01 nil timeout)
        (error "Timeout waiting for ESS process")))
    (with-current-buffer pbuf
      (string-trim-right
       (buffer-substring-no-properties start (point-max))))))

(defun eca-ess-source-file (file &optional timeout buffer-name directory)
  "Source FILE in an ESS R process and return appended output as a string.
Optional TIMEOUT is seconds to wait (default: ESS default).
Optional BUFFER-NAME or DIRECTORY narrow which iESS session to use."
  (let ((proc (eca-ess-inferior-r-process buffer-name directory))
        (cmd (format "source('%s', echo=TRUE, print.eval=TRUE)\n" file)))
    (eca-ess-send-and-capture proc cmd timeout)))

(defun eca-ess-eval (code &optional timeout buffer-name directory)
  "Evaluate CODE (string) in ESS R and return appended output.
Optional TIMEOUT is seconds to wait (default: ESS default).
Optional BUFFER-NAME or DIRECTORY narrow which iESS session to use."
  (let ((proc (eca-ess-inferior-r-process buffer-name directory)))
    (eca-ess-send-and-capture proc (concat code "\n") timeout)))

(provide 'eca-ess-bridge)
;; eca-ess-bridge.el ends here
