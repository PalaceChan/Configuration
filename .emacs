;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                        STARTUP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Disable toolbars and menus when in windowed mode
(menu-bar-mode 0)
(tool-bar-mode 0)
(transient-mark-mode 0)

;;Disable startup messages
(setq inhibit-startup-message t
  inhibit-startup-echo-area-message t
  initial-scratch-message nil)

;;Disable Column Goal Warning/Region Upcase Warning/Region Narrow Warning
(put 'set-goal-column 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
(setq large-file-warning-threshold nil)

;;Enable grep highlighting and paren-mode highlighting
(setq grep-highlight-matches t)

;;Load the common lisp library & allow for long output
;;(require 'cl)

;;Load environment for aliases to work
(setq shell-file-name "bash")
;;(setq shell-command-switch "-ic")

(setq x-alt-keysym 'meta)
(put 'downcase-region 'disabled nil)
(setq scroll-step 1)

;;save history and desktop
;(desktop-save-mode 1)
(savehist-mode 1)
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                       MISC OVERRIDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;override timezones of interest
(setq display-time-world-list '(
                                ("America/Chicago" "Chicago") ("Asia/Tokyo" "Japan")
                                ("Europe/Berlin" "Frankfurt") ("Australia/Sydney" "Australia") ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                               CODE NAVIGATION & COMPILATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Follow default tag in etags without prompting
(fset 'tagmac
   "\C-[xfind tag\C-m\C-m")
(define-key global-map (kbd "M-.") 'tagmac)

;;C-scope indexing
;;(load-file "/wherever/this/is/installed/xcscope.el")
;;(require 'xcscope)

;;In C/C++ mode, toggle between Implementation and Header
;;TODO: Improve so it doesnt only search same directory
(setq cc-search-directories
'( "/usr/include" "/usr/include/sys" "/usr/include/linux"
   "."
  )
)
(setq cc-other-file-alist
'(("\\.cpp$" (".h" ".hpp"))
("\\.h$" (".cpp" ".c"))
("\\.hpp$" (".cpp" ".c"))
("\\.C$" (".H"))
("\\.H$" (".C"))
))
(add-hook 'c-mode-common-hook (lambda() (global-set-key (kbd "C-c o") 'ff-find-other-file)))
;;Follow default compile command when compiling
(setq compile-command "make")
(setq compilation-read-command nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                        SHORTCUTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "C-x l") 'align-regexp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                      BUFFER OPTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;DISPLAY OPTIONS
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-time-mode t)
 '(ecb-options-version "2.40")
 '(indent-tabs-mode nil)
 '(package-selected-packages
   (quote
    (wrap-region company dired-subtree ess use-package yasnippet)))
 '(send-mail-function (quote sendmail-send-it))
 '(show-paren-mode t)
 '(tab-width 4))

(setq c-default-style "linux"
      c-basic-offset 4)
(c-set-offset 'innamespace 0)

;;(custom-set-faces
;; '(default ((t (:inherit nil :stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil)))))

(load-theme 'manoj-dark t)
(set-default-font "Monospace-11")

(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

;; from http://www.dotemacs.de/dotfiles/DaveGallucci.emacs.html
;; kill current buffer without confirmation
(defun kill-current-buffer ()
  "Kill the current buffer, without confirmation."
  (interactive)
  (kill-buffer (current-buffer)))
(global-set-key "\C-xk" 'kill-current-buffer)

;;Force diplay of some buffers in same window
(add-to-list 'same-window-buffer-names "*Buffer List*")
(add-to-list 'same-window-buffer-names "*grep*")

;;Prevent those annoying *~ backup files
(setq make-backup-files nil)

;;Enlarge the undo-outer limit for large files (50MB)
(setq undo-outer-limit 50000000)

;;Dired mode date display and file size display
(setq dired-listing-switches "-Al --si --time-style long-iso")

;;ansi-term keep more lines than 2048
(setq term-buffer-maximum-size 262144)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                      PACKAGE REPOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                           USE-PACKAGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(package-initialize)
(defvar avelazqu/default-install-packages
  (list 'yasnippet 'use-package 'bind-key 'diminish)
  "Packages that should be installed by default.")
(unless package-archive-contents
  (package-refresh-contents))
(dolist (package avelazqu/default-install-packages)
  (unless (package-installed-p package)
    (package-install package)))
(require 'bind-key)
(require 'use-package)
(require 'diminish)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                           HELM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package helm
             :demand t
             :diminish helm-mode
             :init
             (progn
               (require 'helm-config)
               (setq helm-candidate-number-limit 100)
               (setq helm-idle-delay 0.0
                     helm-input-idle-delay 0.01
                     helm-yas-display-key-on-candidate t
                     helm-quick-update t
                     helm-M-x-requires-pattern nil)
               (helm-mode)
               )
             :bind (
                    ("C-h a" . helm-apropos)
                    ("C-x C-b" . helm-buffers-list)
                    ("C-x b" . helm-buffers-list)
                    ("M-y" . helm-show-kill-ring)
                    ("M-x" . helm-M-x)
                    ("C-x C-f" . helm-find-files)
                    ("C-c h o" . helm-occur)
                    ("C-c h r" . helm-register)
                    ("C-c h b" . helm-resume)
                    )
             :config
             (setq helm-command-prefix-key "C-c h")
             (setq helm-autoresize-min-height 25)
             (setq helm-autoresize-max-height 25)
             (setq helm-split-window-in-side-p t
                   helm-move-to-line-cycle-in-source t
                   helm-ff-search-library-in-sexp t
                   helm-scroll-amount 8
                   helm-ff-file-name-history-use-recentf t)
             (helm-mode 1)
             (helm-autoresize-mode 1)
             (define-key  helm-map (kbd "<tab>") 'helm-execute-persistent-action)
             (define-key  helm-map (kbd "C-i") 'helm-execute-persistent-action)
             (define-key  helm-map (kbd "C-z") 'helm-select-action)
             :ensure helm)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                        COMPANY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package company
  :ensure t
  :pin melpa
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  ;; setup tab to manually trigger company completion
  (define-key company-mode-map (kbd "TAB") 'company-indent-or-complete-common)
  (define-key company-active-map (kbd "TAB") 'company-complete-common)
  ;; setup M-h to show documentation for items on the autocomplete menu
  (define-key company-active-map (kbd "M-h") 'company-show-doc-buffer)
  (setq company-global-modes '(not term-mode not compilation-mode))
  )

;;(use-package hippie-expand
;;             :init
;;             (setq hippie-expand-try-functions-list
;;                   '(try-complete-file-name-partially
;;                     try-complete-file-name
;;                     try-expand-dabbrev
;;                     try-expand-dabbrev-all-buffers
;;                     try-expand-dabbrev-from-kill))
;;             :bind
;;             ("M-/" . hippie-expand))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                         ORG AND AGENDA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-use-speed-commands 1)
(setq org-list-description-max-indent 5)
(setq org-export-html-postamble nil)
(setq org-log-done 'note)

(setq org-confirm-babel-evaluate nil)
(org-babel-do-load-languages 'org-babel-load-languages '( (emacs-lisp . t) (sh . t) (R . t) ))

(global-set-key (kbd "C-c a") 'org-agenda)
(setq org-agenda-files (quote ("~/todo.org")))
(setq org-agenda-window-setup (quote current-window))

(define-key global-map (kbd "C-c l") 'org-store-link)
(define-key global-map (kbd "C-c c") 'org-capture)
(setq org-capture-templates '(("t" "todo" entry (file+headline "~/todo.org" "Tasks") "* TODO %?")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                       DIRED SUBTREE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package dired-subtree
             :config
             (define-key dired-mode-map "i" 'dired-subtree-insert)
             (define-key dired-mode-map ";" 'dired-subtree-remove)
             :ensure dired-subtree)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                       WRAP REGION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package wrap-region
  :ensure wrap-region
  :config (wrap-region-global-mode t)
  :diminish wrap-region-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                           W3M
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq browse-url-browser-function 'w3m-goto-url-new-session)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                      ESS STATISTICS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ess
             :init (require 'ess-site)
             :config
             (setq inferior-R-program-name "/usr/bin/R")
             (setq ess-eval-visibly-p nil)
             (setq ess-directory "/home/andres")
             (defun ava-ess-settings () ;http://stackoverflow.com/questions/780796/emacs-ess-mode-tabbing-for-comment-region
               (setq ess-indent-with-fancy-comments nil))
             (add-hook 'ess-mode-hook #'ava-ess-settings)
             :ensure ess)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                      CUSTOM FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Toggle between horizontal and vertical split with C-x |
(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(global-set-key (kbd "C-x |") 'toggle-window-split)

(defun copy-fname-to-killring ()
  "copy current buffer filename to kill ring"
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "%s copied to kill ring." filename))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                          PYTHON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;use ipython
;(add-to-list 'load-path "~/.emacs.d/elpa/python-mode-6.1.3")
;(require 'python-mode)
;(setq-default py-shell-name "~/.local/bin/ipython")
;(setq-default py-which-bufname "IPython")
;(setq py-python-command-args '("--gui=wx" "--pylab=wx" "--colors" "Linux"))
;(setq py-force-py-shell-name-p t)
;; switch to the interpreter after executing code
;;(setq py-shell-switch-buffers-on-execute-p t)
;;(setq py-switch-buffers-on-execute-p t)
;; don't split windows
;(setq py-split-windows-on-execute-p nil)
;; try to automagically figure out indentation
;(setq py-smart-indentation t)
;
;;;use pylookup
;(setq pylookup-dir "~/.emacs.d/pylookup")
;(add-to-list 'load-path pylookup-dir)
;(eval-when-compile (require 'pylookup))
;(setq pylookup-program (concat pylookup-dir "/pylookup.py"))
;(setq pylookup-db-file (concat pylookup-dir "/pylookup.db"))
;(autoload 'pylookup-lookup "pylookup" "Lookup SEARCH-TERM in the Python HTML indexes." t)
;(autoload 'pylookup-update "pylookup" "Run pylookup-update and create the database at `pylookup-db-file'." t)
;;(setq browse-url-browser-function "w3m-browse-url")
;(global-set-key "\C-cp" 'pylookup-lookup)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
