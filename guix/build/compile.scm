;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013, 2014, 2016, 2017 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2015 Taylan Ulrich Bayırlı/Kammer <taylanbayirli@gmail.com>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (guix build compile)
  #:use-module (ice-9 match)
  #:use-module (ice-9 format)
  #:use-module (ice-9 threads)
  #:use-module (system base target)
  #:use-module (system base compile)
  #:use-module (system base message)
  #:use-module (guix modules)
  #:use-module (guix build utils)
  #:export (%default-optimizations
            %lightweight-optimizations
            compile-files))

;;; Commentary:
;;;
;;; Support code to compile Guile code as efficiently as possible (both with
;;; Guile 2.0 and 2.2).
;;;
;;; Code:

(cond-expand
  (guile-2.2 (use-modules (language tree-il optimize)
                          (language cps optimize)))
  (else #f))

(define %default-optimizations
  ;; Default optimization options (equivalent to -O2 on Guile 2.2).
  (cond-expand
    (guile-2.2 (append (tree-il-default-optimization-options)
                       (cps-default-optimization-options)))
    (else '())))

(define %lightweight-optimizations
  ;; Lightweight optimizations (like -O0, but with partial evaluation).
  (let loop ((opts %default-optimizations)
             (result '()))
    (match opts
      (() (reverse result))
      ((#:partial-eval? _ rest ...)
       (loop rest `(#t #:partial-eval? ,@result)))
      ((kw _ rest ...)
       (loop rest `(#f ,kw ,@result))))))

(define %warnings
  ;; FIXME: 'format' is missing because it reports "non-literal format
  ;; strings" due to the fact that we use 'G_' instead of '_'.  We'll need
  ;; help from Guile to solve this.
  '(unsupported-warning unbound-variable arity-mismatch
    macro-use-before-definition))                 ;new in 2.2

(define (optimization-options file)
  "Return the default set of optimizations options for FILE."
  (if (string-contains file "gnu/packages/")
      %lightweight-optimizations                  ;build faster
      '()))

(define (scm->go file)
  "Strip the \".scm\" suffix from FILE, and append \".go\"."
  (string-append (string-drop-right file 4) ".go"))

(define* (load-files directory files
                     #:key
                     (report-load (const #f))
                     (debug-port (%make-void-port "w")))
  "Load FILES, a list of relative file names, from DIRECTORY."
  (define total
    (length files))

  (let loop ((files files)
             (completed 0))
    (match files
      (()
       (unless (zero? total)
         (report-load #f total completed))
       *unspecified*)
      ((file files ...)
       (report-load file total completed)
       (format debug-port "~%loading '~a'...~%" file)

       (parameterize ((current-warning-port debug-port))
         (resolve-interface (file-name->module-name file)))

       (loop files (+ 1 completed))))))

(define-syntax-rule (with-augmented-search-path path item body ...)
  "Within the dynamic extent of BODY, augment PATH by adding ITEM to the
front."
  (let ((initial-value path))
    (dynamic-wind
      (lambda ()
        (set! path (cons item path)))
      (lambda ()
        body ...)
      (lambda ()
        (set! path initial-value)))))

(define* (compile-files source-directory build-directory files
                        #:key
                        (host %host-type)
                        (workers (current-processor-count))
                        (optimization-options optimization-options)
                        (warning-options `(#:warnings ,%warnings))
                        (report-load (const #f))
                        (report-compilation (const #f))
                        (debug-port (%make-void-port "w")))
  "Compile FILES, a list of source files taken from SOURCE-DIRECTORY, to
BUILD-DIRECTORY, using up to WORKERS parallel workers.  The resulting object
files are for HOST, a GNU triplet such as \"x86_64-linux-gnu\"."
  (define progress-lock (make-mutex))
  (define total (length files))
  (define completed 0)

  (define (build file)
    (with-mutex progress-lock
      (report-compilation file total completed))
    (with-fluids ((*current-warning-prefix* ""))
      (with-target host
        (lambda ()
          (compile-file file
                        #:output-file (string-append build-directory "/"
                                                     (scm->go file))
                        #:opts (append warning-options
                                       (optimization-options file))))))
    (with-mutex progress-lock
      (set! completed (+ 1 completed))))

  (with-augmented-search-path %load-path source-directory
    (with-augmented-search-path %load-compiled-path build-directory
      ;; FIXME: To work around <https://bugs.gnu.org/15602>, we first load all
      ;; of FILES.
      (load-files source-directory files
                  #:report-load report-load
                  #:debug-port debug-port)

      ;; Make sure compilation related modules are loaded before starting to
      ;; compile files in parallel.
      (compile #f)

      (n-par-for-each workers build files)
      (unless (zero? total)
        (report-compilation #f total total)))))

;;; Local Variables:
;;; eval: (put 'with-augmented-search-path 'scheme-indent-function 2)
;;; eval: (put 'with-target 'scheme-indent-function 1)
;;; End:
