;;; eca-elpy-bridge.el --- Elpy Python bridge for ECA -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'python)
(require 'subr-x)

(defvar elpy-shell-starting-directory)

(declare-function elpy-shell-get-or-create-process "elpy-shell" (&optional sit))
(declare-function elpy-shell-send-file "elpy-shell"
                  (file-name &optional process temp-file-name delete msg))

(defun eca-elpy--require-elpy ()
  "Ensure the Elpy bridge dependencies are available."
  (unless (or (featurep 'elpy)
              (require 'elpy nil t))
    (error "Elpy is not available in this Emacs session"))
  (unless (or (featurep 'elpy-shell)
              (require 'elpy-shell nil t))
    (error "Elpy shell support is not available in this Emacs session")))

(defun eca-elpy--shell-buffer-name (name)
  "Normalize NAME into an inferior Python buffer name."
  (when name
    (if (string-match-p "\\`\\*.*\\*\\'" name)
        name
      (format "*%s*" name))))

(defun eca-elpy--shell-process-name (name)
  "Normalize NAME into the process name used by `python-shell-buffer-name'."
  (when name
    (if (string-match "\\`\\*\\(.*\\)\\*\\'" name)
        (match-string 1 name)
      name)))

(defun eca-elpy--live-python-shell-buffer-p (buffer)
  "Return non-nil when BUFFER is a live inferior Python shell buffer."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (let ((proc (get-buffer-process buffer)))
        (and (derived-mode-p 'inferior-python-mode)
             proc
             (process-live-p proc))))))

(defun eca-elpy--live-python-shell-buffers ()
  "Return live inferior Python shell buffers in MRU order."
  (cl-remove-if-not #'eca-elpy--live-python-shell-buffer-p (buffer-list)))

(defun eca-elpy--directory-matches-buffer-p (directory buffer)
  "Return non-nil when DIRECTORY matches BUFFER's `default-directory'."
  (let ((dir (file-name-as-directory (expand-file-name directory))))
    (with-current-buffer buffer
      (let ((bufdir (file-name-as-directory (expand-file-name default-directory))))
        (string-prefix-p dir bufdir)))))

(defun eca-elpy--process-ready-p (proc)
  "Return non-nil when PROC's shell buffer is currently at a prompt."
  (let ((pbuf (process-buffer proc)))
    (and (buffer-live-p pbuf)
         (with-current-buffer pbuf
           (save-excursion
             (goto-char (point-max))
             (let ((inhibit-field-text-motion t))
               (python-shell-comint-end-of-output-p
                (buffer-substring-no-properties
                 (line-beginning-position)
                 (line-end-position)))))))))

(defun eca-elpy--wait-for-prompt (proc &optional timeout)
  "Wait until PROC is idle and displaying a prompt.

TIMEOUT is the maximum number of seconds to wait."
  (let* ((timeout (or timeout 30))
         (deadline (time-add (current-time)
                             (seconds-to-time timeout))))
    (while (and (process-live-p proc)
                (not (eca-elpy--process-ready-p proc))
                (time-less-p (current-time) deadline))
      (python-shell-accept-process-output proc 0.05))
    (unless (process-live-p proc)
      (error "Python process is no longer live"))
    (unless (eca-elpy--process-ready-p proc)
      (error "Timeout waiting for Python process prompt"))))

(defun eca-elpy--start-process (&optional buffer-name directory)
  "Start a new Elpy inferior Python process and return it.

BUFFER-NAME, when non-nil, is used as the target shell buffer name.
DIRECTORY, when non-nil, is used as the shell starting directory."
  (eca-elpy--require-elpy)
  (let ((target-directory (and directory
                               (file-name-as-directory
                                (expand-file-name directory))))
        (process-name (eca-elpy--shell-process-name buffer-name))
        proc)
    (save-window-excursion
      (with-temp-buffer
        (when target-directory
          (setq default-directory target-directory))
        (python-mode)
        (when process-name
          (setq-local python-shell-buffer-name process-name))
        (let ((elpy-shell-starting-directory
               (if target-directory
                   'current-directory
                 elpy-shell-starting-directory)))
          (setq proc (elpy-shell-get-or-create-process)))))
    (unless (and proc (process-live-p proc))
      (error "No Elpy Python process found (and failed to start one)"))
    (eca-elpy--wait-for-prompt proc 5)
    proc))

(defun eca-elpy-inferior-python-process (&optional buffer-name directory)
  "Return a live Elpy inferior Python process.

If BUFFER-NAME is non-nil, prefer that exact shell buffer.
If DIRECTORY is non-nil, prefer a session whose `default-directory' matches.
Otherwise fall back to the most-recently-used inferior Python shell.
Start one via Elpy if none exists."
  (eca-elpy--require-elpy)
  (let* ((candidates (eca-elpy--live-python-shell-buffers))
         (wanted-buffer (eca-elpy--shell-buffer-name buffer-name))
         (target-directory (and directory
                                (file-name-as-directory
                                 (expand-file-name directory))))
         (exact-buffer
          (and wanted-buffer
               (cl-find wanted-buffer candidates
                        :key #'buffer-name :test #'string=)))
         (exact-directory-buffer
          (and target-directory
               (cl-find-if
                (lambda (candidate)
                  (with-current-buffer candidate
                    (string=
                     target-directory
                     (file-name-as-directory
                      (expand-file-name default-directory)))))
                candidates)))
         (prefix-directory-buffer
          (and target-directory
               (cl-find-if (lambda (candidate)
                             (eca-elpy--directory-matches-buffer-p
                              target-directory candidate))
                           candidates)))
         (buf (cond
               (exact-buffer exact-buffer)
               (exact-directory-buffer exact-directory-buffer)
               (prefix-directory-buffer prefix-directory-buffer)
               ((or buffer-name directory) nil)
               (t (car candidates)))))
    (if buf
        (get-buffer-process buf)
      (eca-elpy--start-process buffer-name directory))))

(defun eca-elpy-send-and-capture (proc sender &optional timeout)
  "Run SENDER against PROC, wait, and return the appended shell transcript.

SENDER is a function of no arguments that sends code to PROC.
TIMEOUT is the maximum number of seconds to wait before signaling an error."
  (unless (and proc (process-live-p proc))
    (error "PROC is not a live Python process"))
  (eca-elpy--wait-for-prompt proc timeout)
  (let* ((pbuf (process-buffer proc))
         (start (with-current-buffer pbuf
                  (point-max))))
    (with-current-buffer pbuf
      (funcall sender))
    (eca-elpy--wait-for-prompt proc timeout)
    (with-current-buffer pbuf
      (string-trim-right
       (buffer-substring-no-properties start (point-max))))))

(defun eca-elpy--sanitize-file-transcript (transcript)
  "Remove bridge-internal noise from file execution TRANSCRIPT."
  (let* ((warning "<string>:1: DeprecationWarning: codecs.open() is deprecated. Use open() instead.\n")
         (warning-with-leading-newline (concat "\n" warning)))
    (cond
     ((string-prefix-p warning-with-leading-newline transcript)
      (concat "\n"
              (string-remove-prefix warning-with-leading-newline transcript)))
     ((string-prefix-p warning transcript)
      (string-remove-prefix warning transcript))
     (t transcript))))

(defun eca-elpy-source-file (file &optional timeout buffer-name directory)
  "Evaluate FILE in an Elpy Python process and return appended transcript.

TIMEOUT is the maximum number of seconds to wait.
BUFFER-NAME or DIRECTORY narrow which shell to use."
  (let ((file (expand-file-name file)))
    (unless (file-exists-p file)
      (error "Python file does not exist: %s" file))
    (let ((proc (eca-elpy-inferior-python-process buffer-name directory)))
      (eca-elpy--sanitize-file-transcript
       (eca-elpy-send-and-capture
        proc
        (lambda ()
          (elpy-shell-send-file file proc nil nil nil))
        timeout)))))

(defun eca-elpy-eval (code &optional timeout buffer-name directory)
  "Evaluate CODE in Elpy Python and return appended transcript.

TIMEOUT is the maximum number of seconds to wait.
BUFFER-NAME or DIRECTORY narrow which shell to use."
  (let ((proc (eca-elpy-inferior-python-process buffer-name directory)))
    (eca-elpy-send-and-capture
     proc
     (lambda ()
       (python-shell-send-string code proc))
     timeout)))

(provide 'eca-elpy-bridge)
;;; eca-elpy-bridge.el ends here
