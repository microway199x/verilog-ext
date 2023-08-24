;;; verilog-ext-tests.el --- Verilog-Ext ERT tests  -*- lexical-binding: t -*-

;; Copyright (C) 2022-2023 Gonzalo Larumbe

;; Author: Gonzalo Larumbe <gonzalomlarumbe@gmail.com>
;; URL: https://github.com/gmlarumbe/verilog-ext

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; ERT Tests
;;
;;; Code:


;;;; Performance utils
(require 'profiler)

(defun verilog-ext-profile-file (file)
  "Use Emacs profiler in FILE."
  (profiler-start 'cpu+mem)
  (find-file file)
  (profiler-stop)
  (profiler-report))

(defun verilog-ext-profile-imenu ()
  "Use Emacs profiler on `verilog-ext-imenu-list'."
  (profiler-start 'cpu+mem)
  (verilog-ext-imenu-list)
  (profiler-stop)
  (profiler-report))

;;;; Native compile
(defun verilog-ext-compile-dir (dir)
  "Compile DIR.
Native compile if native compilation is available.
Otherwise, byte-compile."
  (if (native-comp-available-p)
      (dolist (file (directory-files-recursively dir "\.el$"))
        (message "Native compiling %s" file)
        (native-compile file))
    ;; Nix Emacs images might still lack native compilation support, so byte-compile them
    (message "Byte-compiling %s" dir)
    (byte-recompile-directory dir 0)))


;;;; Tests
(require 'verilog-ext)

(defvar verilog-ext-tests-test-dir (if (bound-and-true-p straight-base-dir)
                                       (file-name-concat (expand-file-name straight-base-dir) "straight/repos/verilog-ext/test")
                                     (file-name-directory (or load-file-name (buffer-file-name)))))
(defvar verilog-ext-tests-files-dir (file-name-concat verilog-ext-tests-test-dir "files"))
(defvar verilog-ext-tests-beautify-dir (file-name-concat verilog-ext-tests-files-dir "beautify"))
(defvar verilog-ext-tests-common-dir (file-name-concat verilog-ext-tests-files-dir "common"))
(defvar verilog-ext-tests-faceup-dir (file-name-concat verilog-ext-tests-files-dir "faceup"))
(defvar verilog-ext-tests-indent-dir (file-name-concat verilog-ext-tests-files-dir "indent"))
(defvar verilog-ext-tests-jump-parent-dir (file-name-concat verilog-ext-tests-files-dir "jump-parent"))
(defvar verilog-ext-tests-hierarchy-dir (file-name-concat verilog-ext-tests-files-dir "hierarchy"))
(defvar verilog-ext-tests-tags-dir (file-name-concat verilog-ext-tests-files-dir "tags"))

(unless (member verilog-ext-tests-test-dir load-path)
  (add-to-list 'load-path verilog-ext-tests-test-dir))

(require 'verilog-ext-tests-imenu)
(require 'verilog-ext-tests-navigation)
(require 'verilog-ext-tests-font-lock)
(require 'verilog-ext-tests-utils)
(require 'verilog-ext-tests-beautify)
(require 'verilog-ext-tests-indent)
(require 'verilog-ext-tests-hierarchy)
(require 'verilog-ext-tests-tags)
(require 'verilog-ext-tests-workspace)
(if (not (and (>= emacs-major-version 29)
              (treesit-available-p)
              (treesit-language-available-p 'verilog)))
    (message "Skipping verilog-ext-tests-tree-sitter...")
  (defvar verilog-ext-tests-tree-sitter-dir (file-name-concat verilog-ext-tests-files-dir "tree-sitter"))
  (require 'verilog-ext-tests-tree-sitter))


;;; CI
(when (getenv "GITHUB_WORKSPACE")
  (setq temporary-file-directory (file-name-concat (getenv "GITHUB_WORKSPACE") "tmp/"))
  (make-directory temporary-file-directory :parents))


;;;; Report loaded file
(when noninteractive ; Only report in batch-mode
  ;; Not sure if this one really reports if functions have been loaded from .eln files
  (message "verilog-ext is: %s" (locate-library "verilog-ext"))
  ;; `describe-function' is not intended to be used programatically, but seems it can do the trick
  (message "%s" (car (split-string (describe-function 'verilog-ext-mode) "\n")))
  (message "%s" (car (split-string (describe-function 'verilog-ext-find-module-instance-fwd) "\n"))))
;; If files are compiled successfully, subsequent invocations of Emacs should
;; try to load files from native compiled instead of byte-compiled or interactive ones.




(provide 'verilog-ext-tests)

;;; verilog-ext-tests.el ends here
