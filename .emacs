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
(require 'cl)

;;Load environment for aliases to work
(setq shell-file-name "bash")
;;(setq shell-command-switch "-ic")

(setq x-alt-keysym 'meta)
(put 'downcase-region 'disabled nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                           HELM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path "~/.emacs.d/helm")
(add-to-list 'load-path "~/.emacs.d/async")
(require 'helm-config)
(helm-mode 1)
;;(semantic-mode 1)

(helm-autoresize-mode 1)
(setq helm-autoresize-min-height 25)
(setq helm-autoresize-max-height 25)

(global-set-key (kbd "C-c h")                        'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(global-set-key (kbd "M-x")                          'undefined)
(global-set-key (kbd "M-x")                          'helm-M-x)
(global-set-key (kbd "M-y")                          'helm-show-kill-ring)
(global-set-key (kbd "C-x C-f")                      'helm-find-files)
(global-set-key (kbd "C-c <SPC>")                    'helm-all-mark-rings)
(global-set-key (kbd "C-h r")                        'helm-info-emacs)
(global-set-key (kbd "C-:")                          'helm-eval-expression-with-eldoc)
(global-set-key (kbd "C-,")                          'helm-calcul-expression)
(global-set-key (kbd "C-h i")                        'helm-info-at-point)
(global-set-key (kbd "C-h a")                        'helm-apropos)
(global-set-key (kbd "C-c h o")                      'helm-occur)
(global-set-key (kbd "C-c h x")                      'helm-register)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
(define-key helm-map (kbd "C-i")   'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z")   'helm-select-action)

(define-key global-map [remap jump-to-register]      'helm-register)
(define-key global-map [remap list-buffers]          'helm-mini)
(define-key global-map [remap dabbrev-expand]        'helm-dabbrev)
(define-key global-map [remap find-tag]              'helm-etags-select)
(define-key global-map [remap xref-find-definitions] 'helm-etags-select)

(setq helm-split-window-in-side-p           t;
      helm-move-to-line-cycle-in-source     t;
      helm-ff-search-library-in-sexp        t;
      helm-scroll-amount                    8;
      helm-ff-file-name-history-use-recentf t)

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
 '(column-number-mode t)
 '(display-time-mode t)
 '(ecb-options-version "2.40")
 '(show-paren-mode t)
 '(tab-width 4)
 '(indent-tabs-mode nil)
 )
(setq c-default-style "linux"
      c-basic-offset 4)
(c-set-offset 'innamespace 0)

;;(custom-set-faces
;; '(default ((t (:inherit nil :stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil)))))

(load-theme 'manoj-dark t)
(set-default-font "Monospace-14")

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                           W3M
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq browse-url-browser-function 'w3m-goto-url-new-session)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                          PYTHON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;use ipython
(add-to-list 'load-path "~/.emacs.d/elpa/python-mode-6.1.3")
(require 'python-mode)
(setq-default py-shell-name "~/.local/bin/ipython")
(setq-default py-which-bufname "IPython")
(setq py-python-command-args '("--gui=wx" "--pylab=wx" "--colors" "Linux"))
(setq py-force-py-shell-name-p t)
; switch to the interpreter after executing code
;(setq py-shell-switch-buffers-on-execute-p t)
;(setq py-switch-buffers-on-execute-p t)
; don't split windows
(setq py-split-windows-on-execute-p nil)
; try to automagically figure out indentation
(setq py-smart-indentation t)

;;use pylookup
(setq pylookup-dir "~/.emacs.d/pylookup")
(add-to-list 'load-path pylookup-dir)
(eval-when-compile (require 'pylookup))
(setq pylookup-program (concat pylookup-dir "/pylookup.py"))
(setq pylookup-db-file (concat pylookup-dir "/pylookup.db"))
(autoload 'pylookup-lookup "pylookup" "Lookup SEARCH-TERM in the Python HTML indexes." t)
(autoload 'pylookup-update "pylookup" "Run pylookup-update and create the database at `pylookup-db-file'." t)
;(setq browse-url-browser-function "w3m-browse-url")
(global-set-key "\C-cp" 'pylookup-lookup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                      ESS STATISTICS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;ESS Statistics
(add-to-list 'load-path "~/.emacs.d/elpa/ess-20150903.35/lisp/")
(add-to-list 'load-path "~/.emacs.d/elpa/julia-mode-20150827.747/")
(load "ess-site.el")
(setq inferior-R-program-name "/usr/bin/R")

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                      PACKAGE REPOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
