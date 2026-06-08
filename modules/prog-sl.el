;;; prog-sl.el --- Programming packages and config -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Python

(when (fboundp 'exec-path-from-shell-copy-env)
  (exec-path-from-shell-copy-env "PYTHONPATH"))

;; Eglot LSP Configuration


(defun sl/python ()
  "Buffer-local Python Configuration"
  (subword-mode)
  (setq-local imenu-create-index-function
              #'python-imenu-create-flat-index)
  (eglot-ensure))

;;; C / C++

;; Modern indentation style
(setopt c-default-style "k&r"
        c-ts-mode-indent-style 'k&r
        c-basic-offset 2)
(c-set-offset 'substatement-open 0)

;; Eglot LSP Configuration


(defun sl/cc ()
  "Buffer-local C/C++ Configuration"
  (subword-mode)
  (eglot-ensure))

(add-hook 'makefile-mode-hook #'indent-tabs-mode)

;;; Git
(use-package magit
  :ensure t
  :bind ("C-x g" . #'magit-status))

;; Git diff highlights in the gutter
(use-package diff-hl
  :ensure t
  :config (global-diff-hl-mode))

;;; Install

;; direnv support
(use-package envrc
  :ensure t)

;; LSP support
(use-package eglot
  :ensure nil
  :commands (eglot-ensure)
  :hook ((python-mode python-ts-mode) . #'sl/python)
  :hook ((c-mode c-ts-mode c++-mode c++-ts-mode) . #'sl/cc)
  :custom (eglot-send-changes-idle-time 0.1)
  :config
  (progn
    (add-to-list 'eglot-server-programs
                 '(python-ts-mode . ("emacs-lsp-booster" "--disable-bytecode" "--"
                                     "ty" "server")))
    (add-to-list 'eglot-server-programs
                 '(c-ts-mode . ("emacs-lsp-booster" "--disable-bytecode" "--"
                                "clangd" "--clang-tidy")))))

;; Auto-formatting on save
(use-package apheleia
  :ensure t
  :hook prog-mode)

(provide 'prog-sl)
;;; prog-sl.el ends here
