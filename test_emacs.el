;; This is the only sane way to capture coverage data on Windows
(add-hook 'kill-emacs-hook (lambda () (pymacs-exec "cov.save()")))

(require 'ert-x)
;; (add-to-list 'load-path "/path/to/Pymacs")
(require 'pymacs)
(autoload 'pymacs-load "pymacs" nil t)
(pymacs-load "ropemacs" "rope-")

(let ((dir ".ropeproject"))
  (unless (file-exists-p dir)
    (make-directory dir t)))
(rope-open-project ".")

(defconst pydoc "*rope-pydoc*")

(defconst b (find-file "ropemacs/__init__.py"))

(ert-deftest show-doc-none ()
  "Test that we can get info that no Python docs available"
  (ert-with-message-capture
   captured
   (with-current-buffer b
     (goto-char (point-min))
     (rope-show-doc nil))
   (should (string-prefix-p "No docs available!" captured)))
  (should-not (get-buffer pydoc)))

(ert-deftest show-doc ()
  "Test that we can get Python docs"
  (with-current-buffer b
    (goto-char (point-min))
    (search-forward "_make_b")
    (rope-show-doc nil)
    (let ((b (get-buffer pydoc)))
      (should b)
      (with-current-buffer b
        (should buffer-read-only)
        (save-excursion
          (goto-char (point-min))
          (should (search-forward "Make an emacs buffer" nil t))))))
  (kill-buffer pydoc))

(ert-deftest show-occurences ()
  "Test whether can navigate occurences"
  (with-current-buffer b
    (goto-char (point-min))
    (search-forward "_make_buffer")
    (cl-letf (((symbol-function ropemacs-completing-read-function)
               (lambda (&rest _) "search")))
      (rope-find-occurrences))
    (dotimes (i 5)               ; only 4 occurences, should wrap around
      (should (next-error)))))
