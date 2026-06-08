;;; post-early-init.el --- Rare overrides of minimal early-init -*- no-byte-compile: t; lexical-binding: t;

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq user-lisp-directory (expand-file-name "user-lisp/" minimal-emacs-user-directory))
