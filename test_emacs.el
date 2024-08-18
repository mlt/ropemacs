(require 'ert-x)
;; (add-to-list 'load-path "/path/to/Pymacs")
(require 'pymacs)
(autoload 'pymacs-load "pymacs" nil t)
(pymacs-load "ropemacs" "rope-")

(let ((dir ".ropeproject"))
  (unless (file-exists-p dir)
    (make-directory dir t)))
(rope-open-project ".")

(defconst pycode "class SomeClass:
  \"\"\"docstring\"\"\"
  def abc(self):
      pass
")

(defconst pydoc "*rope-pydoc*")

(ert-deftest show-doc-none ()
  "Test that we can get info that no Python docs available"
  (ert-with-message-capture captured
    (with-temp-buffer
      (insert pycode)
      (goto-char (point-min))
      (rope-show-doc "SomeClass"))
    (should (string-prefix-p "No docs available!" captured)))
  (should-not (get-buffer pydoc)))

(ert-deftest show-doc ()
  "Test that we can get Python docs"
  (with-temp-buffer
    (insert pycode)
    (search-backward "Some")
    (rope-show-doc nil)
    (let ((b (get-buffer pydoc)))
      (should b)
      (with-current-buffer b
        (should buffer-read-only)
        (save-excursion
          (goto-char (point-min))
          (should (search-forward "docstring" nil t))))))
  (kill-buffer pydoc))
