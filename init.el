;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                         INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(require 'package)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(use-package diminish)
(use-package bind-key)
(setq use-package-enable-imenu-support t)

(use-package gcmh
  :ensure t
  :custom
  (gcmh-verbose t)
  :config
  (gcmh-mode 1))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                       LITERATE CONFIG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (file-readable-p "~/.emacs.d/config.org")
  (org-babel-load-file (expand-file-name "~/.emacs.d/config.org")))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-show-quick-access t nil nil "Customized with use-package company")
 '(inferior-ess-r-program "/usr/bin/R" nil nil "Customized with use-package ess")
 '(package-selected-packages
   '(ztree yasnippet-snippets ws-butler wrap-region which-key wgrep-helm wgrep-deadgrep vterm vlf visual-fill-column use-package undo-tree tree-sitter-langs transpose-frame sqlite3 speed-type smart-comment rmsbolt python-black phi-search-mc pdf-tools orgit org-noter org-modern org-mime org-appear move-text mixed-pitch minions lsp-ui leetcode json-mode jq-mode irony-eldoc iedit ibuffer-vc helpful helm-swoop helm-rg helm-projectile helm-org-rifle helm-org helm-git-grep helm-descbinds helm-dash helm-company helm-ag gptel git-timemachine git-gutter gcmh forge flycheck-clang-tidy fancy-narrow expand-region ess erc-colorize ement emacsql-sqlite elpy elfeed eldoc-stan eglot editorconfig easy-kill dumb-jump doom-themes doom-modeline dmenu discover-my-major dired-subtree dired-rsync dired-recent dired-git-info diminish deadgrep crux company-stan company-shell company-posframe company-irony company-c-headers company-auctex clj-refactor clang-format auto-package-update ace-window ace-link)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
