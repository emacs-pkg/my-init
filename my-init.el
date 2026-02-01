;; [straight.el]
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package '(c-quick :type git :host github :repo "emacs-pkg/c-quick"))
(require 'c-quick)

(straight-use-package '(xprint :type git :host github :repo "emacs-pkg/xprint"))
(require 'xprint)

(xdump (c-quick-list-non-special-buffers))

(setq warning-minimum-level :emergency)
(setq-default make-backup-files nil)
(setq-default indent-tabs-mode nil)
(put 'erase-buffer 'disabled nil)

(setq locale-coding-system 'utf-8-unix)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))
;; Set default buffer file coding system to utf-8-unix
(setq default-buffer-file-coding-system 'utf-8-unix)
;; Also set the default for undecided files
(prefer-coding-system 'utf-8-unix)
;;改行コード表示
(setq eol-mnemonic-dos "(CRLF)")
(setq eol-mnemonic-mac "(CR)")
(setq eol-mnemonic-unix "(LF)")

;; [get-feature]
(unless (featurep 'get-feature)
  (defun get-feature (feature-name &optional url file-name)
    (if (featurep feature-name) t
      (unless url (setq url (format "https://github.com/emacs-pkg/%s/raw/main/%s.el"
                                    feature-name feature-name)))
      (unless file-name (setq file-name (format "%s.el" feature-name)))
      (let ((make-backup-files nil)
            (file-path (expand-file-name file-name user-emacs-directory)))
        (ignore-errors
          (url-copy-file url file-path 'ok-if-already-exists))
        (ignore-errors
          (load file-path nil 'nomessage))
        (featurep feature-name))))
  (get-feature 'get-feature))

;;(get-feature 'c-quick)
;;(get-feature 'xprint)

;;(get-feature 'oop)
;;(get-feature 'getprop)

;;(get-feature 'newlisp)
;;(add-to-list 'auto-mode-alist '("\\.lsp$" . newlisp-mode))

;;(get-feature 'janet-mode)
;;(add-to-list 'auto-mode-alist '("\\.janet$" . janet-mode))
;;(add-to-list 'auto-mode-alist '("\\.j$"     . janet-mode))

(require 'json)
(defun jencode ($x)
  (json-encode $x))
(defun jparse ($x)
  (json-parse-string
   $x
   :array-type 'list
   :false-object nil
   :object-type 'plist))

;; https://qiita.com/keita44_f4/items/2adae69f05dd4a7c5f25
(use-package dired
  :custom
  (dired-listing-switches "-lgGhF")
  :config
  ;; C-.でドットファイルの表示と非表示を切り替える
  (defun reload-current-dired-buffer ()
    "Reload current `dired-mode' buffer."
    (let* ((dir (dired-current-directory)))
      (progn (kill-buffer (current-buffer))
             (dired dir))))
  (defun toggle-dired-listing-switches ()
    "Toggle `dired-mode' switch between with and without 'A' option to show or hide dot files."
    (interactive)
    (progn
      (if (string-match "[Aa]" dired-listing-switches)
          (setq dired-listing-switches "-lgGhF")
        (setq dired-listing-switches "-lgGhFA"))
      (reload-current-dired-buffer)))
  :bind (:map dired-mode-map
              ("C-." . toggle-dired-listing-switches)))

;; [company]
(straight-use-package 'company)
(require 'company)
;;(global-company-mode) ; 全バッファで有効にする
;;(setq company-idle-delay 0.5) ; デフォルトは0.5
(setq company-idle-delay 0) ; デフォルトは0.5
(setq company-minimum-prefix-length 1) ; デフォルトは4
(setq company-selection-wrap-around nil) ; 候補の一番下でさらに下に行こうとすると一番上に戻る
(add-hook 'emacs-lisp-mode-hook #'(lambda () (company-mode 1)))
(add-hook 'lisp-interaction-mode-hook #'(lambda () (company-mode 1)))
(add-hook 'racket-mode-hook #'(lambda () (company-mode 1)))
(add-hook 'lisp-mode-hook #'(lambda () (company-mode 1)))

;; [racket]
(straight-use-package 'racket-mode)
(add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-mode))

;; https://github.com/magnars/dash.el
(require 'cl)
(straight-use-package 'dash)
(require 'dash)

;; https://github.com/Fuco1/dired-hacks
(straight-use-package 'dired-hacks-utils)
(require 'dired-hacks-utils)
(straight-use-package 'dired-filter)
(require 'dired-filter)

(straight-use-package 'dired-subtree)
(require 'dired-subtree)
(define-key dired-mode-map (kbd "C-,")
            'dired-subtree-toggle)
(define-key dired-mode-map (kbd "C-i")
            'dired-subtree-only-this-file)

;; [evil]
;; (straight-use-package 'evil)
;; (require 'evil)
;; (evil-mode 1)

;; [viper]
;; (straight-use-package 'viper)
;; (setq viper-mode t)
;; (require 'viper)

(defun eshell-load-bash-aliases ()
  "Read Bash aliases and add them to the list of eshell aliases."
  ;; Bash needs to be run - temporarily - interactively
  ;; in order to get the list of aliases.
  (interactive)
  (with-temp-buffer
    (call-process "bash" nil '(t nil) nil "-ci" "alias")
    (goto-char (point-min))
    (while (re-search-forward "alias \\(.+\\)='\\(.+\\)'$" nil t)
      (eshell/alias (match-string 1) (match-string 2)))))
;; (add-hook 'eshell-mode-hook 'eshell-load-bash-aliases)

(defun list-all-buffers (&optional files-only)
  "Display a list of names of existing buffers.
The list is displayed in a buffer named `*Buffer List*'.
Non-null optional arg FILES-ONLY means mention only file buffers.

For more information, see the function `buffer-menu'."
  (interactive "P")
  (display-buffer (list-buffers-noselect files-only (buffer-list))))

(defun mu-open-in-external-app ()
  "Open the file where point is or the marked files in Dired in external
app. The app is chosen from your OS's preference."
  (interactive)
  (let* ((file-list
          (dired-get-marked-files)))
    (mapc
     (lambda (file-path)
       (c-quick-run-command-in-eshell
        default-directory
        (format "bash.exe -c \"xrun '%s'\"" (file-name-nondirectory file-path))
        )
       )
     file-list)))

(defadvice save-buffer (before save-buffer-always activate)
  "always save buffer"
  (set-buffer-modified-p t)
  (set-buffer-file-coding-system 'utf-8-unix)
  (delete-trailing-whitespace)
  (view-mode-enter)
  )

(provide 'my-init)
