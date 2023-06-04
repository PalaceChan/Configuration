;;; early-init.el -*- lexical-binding: t; -*-

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

(setq package-quickstart t
      load-prefer-newer t)

(setq frame-resize-pixelwise t
      fast-but-imprecise-scrolling t
      frame-inhibit-implied-resize t)

(when (native-comp-available-p)
  (setq package-native-compile t
        native-comp-deferred-compilation t
        native-comp-async-report-warnings-errors 'silent))
