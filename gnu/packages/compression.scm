;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2012, 2013, 2014, 2015, 2017 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2013 Andreas Enge <andreas@enge.fr>
;;; Copyright © 2014, 2015 Mark H Weaver <mhw@netris.org>
;;; Copyright © 2015 Taylan Ulrich Bayırlı/Kammer <taylanbayirli@gmail.com>
;;; Copyright © 2015, 2016 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2015, 2016, 2017 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2015, 2017 Leo Famulari <leo@famulari.name>
;;; Copyright © 2015 Jeff Mickey <j@codemac.net>
;;; Copyright © 2015, 2016, 2017 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2016 Ben Woodcroft <donttrustben@gmail.com>
;;; Copyright © 2016 Danny Milosavljevic <dannym@scratchpost.org>
;;; Copyright © 2016, 2017 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2016 David Craven <david@craven.ch>
;;; Copyright © 2016 Kei Kebreau <kkebreau@posteo.net>
;;; Copyright © 2016 Marius Bakke <mbakke@fastmail.com>
;;; Copyright © 2017 ng0 <contact.ng0@cryptolab.net>
;;; Copyright © 2017 Manolis Fragkiskos Ragkousis <manolis837@gmail.com>
;;; Copyright © 2017 Theodoros Foradis <theodoros@foradis.org>
;;; Copyright © 2017 Stefan Reichör <stefan@xsteve.at>
;;; Copyright © 2017 Petter <petter@mykolab.ch>
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

(define-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system perl)
  #:use-module (guix build-system python)
  #:use-module (gnu packages)
  #:use-module (gnu packages assembly)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages base)
  #:use-module (gnu packages check)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages file)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages valgrind)
  #:use-module (ice-9 match)
  #:use-module ((srfi srfi-1) #:select (last)))

(define-public zlib
  (package
    (name "zlib")
    (version "1.2.11")
    (source
     (origin
      (method url-fetch)
      (uri (list (string-append "http://zlib.net/zlib-"
                                 version ".tar.gz")
                 (string-append "mirror://sourceforge/libpng/zlib/"
                                version "/zlib-" version ".tar.gz")))
      (sha256
       (base32
        "18dighcs333gsvajvvgqp8l4cx7h1x7yx9gd5xacnk80spyykrf3"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Zlib's home-made `configure' fails when passed
             ;; extra flags like `--enable-fast-install', so we need to
             ;; invoke it with just what it understand.
             (let ((out (assoc-ref outputs "out")))
               ;; 'configure' doesn't understand '--host'.
               ,@(if (%current-target-system)
                     `((setenv "CHOST" ,(%current-target-system)))
                     '())
               (zero?
                (system* "./configure"
                         (string-append "--prefix=" out)))))))))
    (home-page "http://zlib.net/")
    (synopsis "Compression library")
    (description
     "zlib is designed to be a free, general-purpose, legally unencumbered --
that is, not covered by any patents -- lossless data-compression library for
use on virtually any computer hardware and operating system.  The zlib data
format is itself portable across platforms.  Unlike the LZW compression method
used in Unix compress(1) and in the GIF image format, the compression method
currently used in zlib essentially never expands the data. (LZW can double or
triple the file size in extreme cases.)  zlib's memory footprint is also
independent of the input data and can be reduced, if necessary, at some cost
in compression.")
    (license license:zlib)))

(define-public minizip
  (package
    (name "minizip")
    (version (package-version zlib))
    (source (package-source zlib))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'enter-source
           (lambda _ (chdir "contrib/minizip") #t))
         (add-after 'enter-source 'autoreconf
           (lambda _
             (zero? (system* "autoreconf" "-vif")))))))
    (native-inputs
     `(("autoconf" ,autoconf)
       ("automake" ,automake)
       ("libtool" ,libtool)))
    (propagated-inputs `(("zlib" ,zlib)))
    (home-page (package-home-page zlib))
    (synopsis "Zip Compression library")
    (description
     "Minizip is a minimalistic library that supports compressing,
extracting and viewing ZIP archives.  This version is extracted from
the @code{zlib} source.")
    (license (package-license zlib))))

(define-public fastjar
  (package
   (name "fastjar")
   (version "0.98")
   (source (origin
             (method url-fetch)
             (uri (string-append "mirror://savannah/fastjar/fastjar-"
                                 version ".tar.gz"))
             (sha256
              (base32
               "0iginbz2m15hcsa3x4y7v3mhk54gr1r7m3ghx0pg4n46vv2snmpi"))))
   (build-system gnu-build-system)
   (inputs `(("zlib" ,zlib)))
   (home-page "http://savannah.nongnu.org/projects/fastjar")
   (synopsis "Replacement for Sun's 'jar' utility")
   (description
    "FastJar is an attempt to create a much faster replacement for Sun's 'jar'
utility.  Instead of being written in Java, FastJar is written in C.")
   (license license:gpl2+)))

(define-public libtar
  (package
   (name "libtar")
   (version "1.2.20")
   (source (origin
            (method url-fetch)
            (uri (list
                   (string-append
                     "ftp://ftp.feep.net/pub/software/libtar/libtar-"
                     version ".tar.gz")
                   (string-append
                     "mirror://debian/pool/main/libt/libtar/libtar_"
                     version ".orig.tar.gz")))
            (sha256
             (base32
              "02cihzl77ia0dcz7z2cga2412vyhhs5pa2355q4wpwbyga2lrwjh"))
            (patches (search-patches "libtar-CVE-2013-4420.patch"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f ;no "check" target
      #:phases
      (modify-phases %standard-phases
        (add-after 'unpack 'autoconf
          (lambda _ (zero? (system* "sh" "autoreconf" "-vfi")))))))
   (native-inputs
    `(("autoconf" ,autoconf)
      ("automake" ,automake)
      ("libtool" ,libtool)))
   (inputs
    `(("zlib" ,zlib)))
   (synopsis "C library for manipulating POSIX tar files")
   (description
    "libtar is a C library for manipulating POSIX tar files.  It handles
adding and extracting files to/from a tar archive.")
   (home-page "https://repo.or.cz/libtar.git")
   (license license:bsd-3)))

(define-public gzip
  (package
   (name "gzip")
   (version "1.8")
   (source (origin
            (method url-fetch)
            (uri (string-append "mirror://gnu/gzip/gzip-"
                                version ".tar.xz"))
            (sha256
             (base32
              "1lxv3p4iyx7833mlihkn5wfwmz4cys5nybwpz3dfawag8kn6f5zz"))))
   (build-system gnu-build-system)
   (synopsis "General file (de)compression (using lzw)")
   (arguments
    ;; FIXME: The test suite wants `less', and optionally Perl.
    '(#:tests? #f))
   (description
    "GNU Gzip provides data compression and decompression utilities; the
typical extension is \".gz\".  Unlike the \"zip\" format, it compresses a single
file; as a result, it is often used in conjunction with \"tar\", resulting in
\".tar.gz\" or \".tgz\", etc.")
   (license license:gpl3+)
   (home-page "https://www.gnu.org/software/gzip/")))

(define-public bzip2
  (package
    (name "bzip2")
    (version "1.0.6")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://www.bzip.org/" version "/bzip2-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "1kfrc7f0ja9fdn6j1y6yir6li818npy6217hvr3wzmnmzhs8z152"))))
    (build-system gnu-build-system)
    (arguments
     `(#:modules ((guix build gnu-build-system)
                  (guix build utils)
                  (srfi srfi-1))
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key target #:allow-other-keys)
             (if ,(%current-target-system)
                 ;; Cross-compilation: use the cross tools.
                 (substitute* (find-files "." "Makefile")
                   (("CC=.*$")
                    (string-append "CC = " target "-gcc\n"))
                   (("AR=.*$")
                    (string-append "AR = " target "-ar\n"))
                   (("RANLIB=.*$")
                    (string-append "RANLIB = " target "-ranlib\n"))
                   (("^all:(.*)test" _ prerequisites)
                    ;; Remove 'all' -> 'test' dependency.
                    (string-append "all:" prerequisites "\n")))
                 #t)))
         (add-before 'build 'build-shared-lib
           (lambda* (#:key inputs #:allow-other-keys)
             (patch-makefile-SHELL "Makefile-libbz2_so")
             (zero? (system* "make" "-f" "Makefile-libbz2_so"))))
         (add-after 'install 'install-shared-lib
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out    (assoc-ref outputs "out"))
                    (libdir (string-append out "/lib")))
               (for-each (lambda (file)
                           (let ((base (basename file)))
                             (format #t "installing `~a' to `~a'~%"
                                     base libdir)
                             (copy-file file
                                        (string-append libdir "/" base))))
                         (find-files "." "^libbz2\\.so")))
             #t))
         (add-after 'install-shared-lib 'patch-scripts
           (lambda* (#:key outputs inputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out")))
               (substitute* (string-append out "/bin/bzdiff")
                 (("/bin/rm") "rm")))
             #t)))

       #:make-flags (list (string-append "PREFIX="
                                         (assoc-ref %outputs "out")))

       ;; Don't attempt to run the tests when cross-compiling.
       ,@(if (%current-target-system)
             '(#:tests? #f)
             '())))
    (synopsis "High-quality data compression program")
    (description
     "bzip2 is a freely available, patent free (see below), high-quality data
compressor.  It typically compresses files to within 10% to 15% of the best
available techniques (the PPM family of statistical compressors), whilst
being around twice as fast at compression and six times faster at
decompression.")
    (license (license:non-copyleft "file://LICENSE"
                                   "See LICENSE in the distribution."))
    (home-page "http://www.bzip.org/")))

(define-public lbzip2
  (package
    (name "lbzip2")
    (version "2.5")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://archive.lbzip2.org/lbzip2-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "1sahaqc5bw4i0iyri05syfza4ncf5cml89an033fspn97klmxis6"))))
    (build-system gnu-build-system)
    (synopsis "Parallel bzip2 compression utility")
    (description
     "lbzip2 is a multi-threaded compression utility with support for the
bzip2 compressed file format.  lbzip2 can process standard bz2 files in
parallel.  It uses POSIX threading model (pthreads), which allows it to take
full advantage of symmetric multiprocessing (SMP) systems.  It has been proven
to scale linearly, even to over one hundred processor cores.  lbzip2 is fully
compatible with bzip2 – both at file format and command line level.")
    (home-page "http://www.lbzip2.org/")
    (license license:gpl3+)))

(define-public pbzip2
  (package
    (name "pbzip2")
    (version "1.1.12")
    (source (origin
             (method url-fetch)
             (uri (string-append "https://launchpad.net/pbzip2/"
                                 (version-major+minor version) "/" version
                                 "/+download/" name "-" version ".tar.gz"))
             (sha256
              (base32
               "1vk6065dv3a47p86vmp8hv3n1ygd9hraz0gq89gvzlx7lmcb6fsp"))))
    (build-system gnu-build-system)
    (inputs
     `(("bzip2" ,bzip2)))
    (arguments
     `(#:tests? #f ; no tests
       #:phases (modify-phases %standard-phases
                  (delete 'configure))
       #:make-flags (list (string-append "PREFIX=" %output))))
    (home-page "http://compression.ca/pbzip2/")
    (synopsis "Parallel bzip2 implementation")
    (description
     "Pbzip2 is a parallel implementation of the bzip2 block-sorting file
compressor that uses pthreads and achieves near-linear speedup on SMP machines.
The output of this version is fully compatible with bzip2 v1.0.2 (i.e. anything
compressed with pbzip2 can be decompressed with bzip2).")
    (license (license:non-copyleft "file://COPYING"
                                   "See COPYING in the distribution."))))

(define-public xz
  (package
   (name "xz")
   (version "5.2.2")
   (source (origin
            (method url-fetch)
            (uri (list (string-append "http://tukaani.org/xz/xz-" version
                                      ".tar.gz")
                       (string-append "http://multiprecision.org/guix/xz-"
                                      version ".tar.gz")))
            (sha256
             (base32
              "18h2k4jndhzjs8ln3a54qdnfv59y6spxiwh9gpaqniph6iflvpvk"))))
   (build-system gnu-build-system)
   (synopsis "General-purpose data compression")
   (description
    "XZ Utils is free general-purpose data compression software with high
compression ratio.  XZ Utils were written for POSIX-like systems, but also
work on some not-so-POSIX systems.  XZ Utils are the successor to LZMA Utils.

The core of the XZ Utils compression code is based on LZMA SDK, but it has
been modified quite a lot to be suitable for XZ Utils.  The primary
compression algorithm is currently LZMA2, which is used inside the .xz
container format.  With typical files, XZ Utils create 30 % smaller output
than gzip and 15 % smaller output than bzip2.")
   (license (list license:gpl2+ license:lgpl2.1+)) ; bits of both
   (home-page "http://tukaani.org/xz/")))

(define-public lzo
  (package
    (name "lzo")
    (version "2.09")
    (source
     (origin
      (method url-fetch)
      (uri (string-append "http://www.oberhumer.com/opensource/lzo/download/lzo-"
                          version ".tar.gz"))
      (sha256
       (base32
        "0k5kpj3jnsjfxqqkblpfpx0mqcy86zs5fhjhgh2kq1hksg7ag57j"))))
    (build-system gnu-build-system)
    (arguments '(#:configure-flags '("--enable-shared")))
    (home-page "http://www.oberhumer.com/opensource/lzo")
    (synopsis
     "Data compression library suitable for real-time data de-/compression")
    (description
     "LZO is a data compression library which is suitable for data
de-/compression in real-time.  This means it favours speed over
compression ratio.

LZO is written in ANSI C.  Both the source code and the compressed data
format are designed to be portable across platforms.")
    (license license:gpl2+)))

(define-public python-lzo
  (package
    (name "python-lzo")
    (version "1.11")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "python-lzo" version))
       (sha256
        (base32
         "11p3ifg14p086byhhin6azx5svlkg8dzw2b5abixik97xd6fm81q"))))
    (build-system python-build-system)
    (arguments
     `(#:test-target "check"
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-setuppy
           (lambda _
             (substitute* "setup.py"
               (("include_dirs.append\\(.*\\)")
                (string-append "include_dirs.append('"
                               (assoc-ref %build-inputs "lzo")
                               "/include/lzo"
                               "')")))
             #t)))))
    (inputs
     `(("lzo" ,lzo)))
    (home-page "https://github.com/jd-boyd/python-lzo")
    (synopsis "Python bindings for the LZO data compression library")
    (description
     "Python-LZO provides Python bindings for LZO, i.e. you can access
the LZO library from your Python scripts thereby compressing ordinary
Python strings.")
    (license license:gpl2+)))

(define-public python2-lzo
  (package-with-python2 python-lzo))

(define-public lzop
  (package
    (name "lzop")
    (version "1.03")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "http://www.lzop.org/download/lzop-"
                           version ".tar.gz"))
       (sha256
        (base32
         "1jdjvc4yjndf7ihmlcsyln2rbnbaxa86q4jskmkmm7ylfy65nhn1"))))
    (build-system gnu-build-system)
    (inputs `(("lzo" ,lzo)))
    (home-page "http://www.lzop.org/")
    (synopsis "Compress or expand files")
    (description
     "Lzop is a file compressor which is very similar to gzip.  Lzop uses the
LZO data compression library for compression services, and its main advantages
over gzip are much higher compression and decompression speed (at the cost of
some compression ratio).")
    (license license:gpl2+)))

(define-public lzip
  (package
    (name "lzip")
    (version "1.18")
    (source (origin
             (method url-fetch)
             (uri (string-append "mirror://savannah/lzip/lzip-"
                                 version ".tar.gz"))
             (sha256
              (base32
               "1p8lvc22sv3damld9ng8y6i8z2dvvpsbi9v7yhr5bc2a20m8iya7"))))
    (build-system gnu-build-system)
    (home-page "http://www.nongnu.org/lzip/lzip.html")
    (synopsis "Lossless data compressor based on the LZMA algorithm")
    (description
     "Lzip is a lossless data compressor with a user interface similar to the
one of gzip or bzip2.  Lzip decompresses almost as fast as gzip and compresses
more than bzip2, which makes it well-suited for software distribution and data
archiving.  Lzip is a clean implementation of the LZMA algorithm.")
    (license license:gpl3+)))

(define-public lziprecover
  (package
    (name "lziprecover")
    (version "1.19")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://savannah/lzip/" name "/"
                                  name "-" version ".tar.gz"))
              (sha256
               (base32
                "0z5fbkm0qprypjf7kxkqganniibj0zml13zvfkrchnjafcmmzyld"))))
    (build-system gnu-build-system)
    (home-page "http://www.nongnu.org/lzip/lziprecover.html")
    (synopsis "Recover and decompress data from damaged lzip files")
    (description
     "Lziprecover is a data recovery tool and decompressor for files in the lzip
compressed data format (.lz).  It can test the integrity of lzip files, extract
data from damaged ones, and repair most files with small errors (up to one
single-byte error per member) entirely.

Lziprecover is not a replacement for regular backups, but a last line of defence
when even the backups are corrupt.  It can recover files by merging the good
parts of two or more damaged copies, such as can be easily produced by running
@command{ddrescue} on a failing device.

This package also includes @command{unzcrash}, a tool to test the robustness of
decompressors when faced with corrupted input.")
    (license (list license:bsd-2        ; arg_parser.{cc,h}
                   license:gpl2+))))    ; everything else

(define-public sharutils
  (package
    (name "sharutils")
    (version "4.15.2")
    (source
     (origin
      (method url-fetch)
      (uri (string-append "mirror://gnu/sharutils/sharutils-"
                          version ".tar.xz"))
      (sha256
       (base32
        "16isapn8f39lnffc3dp4dan05b7x6mnc76v6q5nn8ysxvvvwy19b"))))
    (build-system gnu-build-system)
    (inputs
     `(("which" ,which)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'patch-source-shebangs 'unpatch-source-shebang
           ;; revert the patch-shebang phase on a script which is
           ;; in fact test data
           (lambda _
             (substitute* "tests/shar-1.ok"
               (((which "sh")) "/bin/sh"))
             #t)))))
    (home-page "https://www.gnu.org/software/sharutils/")
    (synopsis "Archives in shell scripts, uuencode/uudecode")
    (description
     "GNU sharutils is a package for creating and manipulating shell
archives that can be readily emailed.  A shell archive is a file that can be
processed by a Bourne-type shell to unpack the original collection of files.
This package is mostly for compatibility and historical interest.")
    (license license:gpl3+)))

(define-public sfarklib
  (package
    (name "sfarklib")
    (version "2.24")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/raboof/sfArkLib/archive/"
                                  version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0bzs2d98rk1xw9qwpnc7gmlbxwmwc3dg1rpn310afy9pq1k9clzi"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ;no "check" target
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
                  (lambda* (#:key outputs #:allow-other-keys)
                    (substitute* "Makefile"
                      (("/usr/local") (assoc-ref outputs "out")))
                    #t)))))
    (inputs
     `(("zlib" ,zlib)))
    (home-page "https://github.com/raboof/sfArkLib")
    (synopsis "Library for SoundFont decompression")
    (description
     "SfArkLib is a C++ library for decompressing SoundFont files compressed
with the sfArk algorithm.")
    (license license:gpl3+)))

(define-public sfarkxtc
 (let ((commit "b5e0a2ba3921f019d74d4b92bd31c36dd19d2cf1"))
  (package
    (name "sfarkxtc")
    (version (string-take commit 10))
    (source (origin
              ;; There are no release tarballs, so we just fetch the latest
              ;; commit at this time.
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/raboof/sfarkxtc.git")
                    (commit commit)))
              (sha256
               (base32
                "0f5x6i46qfl6ry21s7g2p4sd4b2r1g4fb03yqi2vv4kq3saryhvj"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ;no "check" target
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
                  (lambda* (#:key outputs #:allow-other-keys)
                    (substitute* "Makefile"
                      (("/usr/local") (assoc-ref outputs "out")))
                    #t)))))
    (inputs
     `(("zlib" ,zlib)
       ("sfarklib" ,sfarklib)))
    (home-page "https://github.com/raboof/sfarkxtc")
    (synopsis "Basic sfArk decompressor")
    (description "SfArk extractor converts SoundFonts in the compressed legacy
sfArk file format to the uncompressed sf2 format.")
    (license license:gpl3+))))

(define-public libmspack
  (package
    (name "libmspack")
    (version "0.6")
    (source
     (origin
      (method url-fetch)
      (uri (string-append "http://www.cabextract.org.uk/libmspack/libmspack-"
                          version "alpha.tar.gz"))
      (sha256
       (base32 "08gr2pcinas6bdqz3k0286g5cnksmcx813skmdwyca6bmj1fxnqy"))))
    (build-system gnu-build-system)
    (home-page "http://www.cabextract.org.uk/libmspack/")
    (synopsis "Compression tools for some formats used by Microsoft")
    (description
     "The purpose of libmspack is to provide both compression and
decompression of some loosely related file formats used by Microsoft.")
    (license license:lgpl2.1+)))

(define-public perl-compress-raw-bzip2
  (package
    (name "perl-compress-raw-bzip2")
    (version "2.074")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://cpan/authors/id/P/PM/PMQS/"
                           "Compress-Raw-Bzip2-" version ".tar.gz"))
       (sha256
        (base32
         "0b5jwqf15zr787acnx8sfyy2zavdd7gfkd98n1dgy8fs6r8yb8a4"))))
    (build-system perl-build-system)
    ;; TODO: Use our bzip2 package.
    (home-page "http://search.cpan.org/dist/Compress-Raw-Bzip2")
    (synopsis "Low-level interface to bzip2 compression library")
    (description "This module provides a Perl interface to the bzip2
compression library.")
    (license license:perl-license)))

(define-public perl-compress-raw-zlib
  (package
    (name "perl-compress-raw-zlib")
    (version "2.074")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://cpan/authors/id/P/PM/PMQS/"
                           "Compress-Raw-Zlib-" version ".tar.gz"))
       (sha256
        (base32
         "08bpx9v6i40n54rdcj6invlj294z20amrl8wvwf9b83aldwdwsd3"))))
    (build-system perl-build-system)
    (inputs
     `(("zlib" ,zlib)))
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (add-before
                   'configure 'configure-zlib
                   (lambda* (#:key inputs #:allow-other-keys)
                     (call-with-output-file "config.in"
                       (lambda (port)
                         (format port "
BUILD_ZLIB = False
INCLUDE = ~a/include
LIB = ~:*~a/lib
OLD_ZLIB = False
GZIP_OS_CODE = AUTO_DETECT"
                                 (assoc-ref inputs "zlib")))))))))
    (home-page "http://search.cpan.org/dist/Compress-Raw-Zlib")
    (synopsis "Low-level interface to zlib compression library")
    (description "This module provides a Perl interface to the zlib
compression library.")
    (license license:perl-license)))

(define-public perl-io-compress
  (package
    (name "perl-io-compress")
    (version "2.074")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://cpan/authors/id/P/PM/PMQS/"
                           "IO-Compress-" version ".tar.gz"))
       (sha256
        (base32
         "1wlpy2026djfmq0bjync531yq6s695jf7bcnpvjphrasi776igdl"))))
    (build-system perl-build-system)
    (propagated-inputs
     `(("perl-compress-raw-zlib" ,perl-compress-raw-zlib)     ; >=2.074
       ("perl-compress-raw-bzip2" ,perl-compress-raw-bzip2))) ; >=2.074
    (home-page "http://search.cpan.org/dist/IO-Compress")
    (synopsis "IO Interface to compressed files/buffers")
    (description "IO-Compress provides a Perl interface to allow reading and
writing of compressed data created with the zlib and bzip2 libraries.")
    (license license:perl-license)))

(define-public lz4
  (package
    (name "lz4")
    (version "1.8.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/lz4/lz4/archive/"
                           "v" version ".tar.gz"))
       (sha256
        (base32
         "1xnckwwah74gl98gylf1b00vk4km1d8sgd8865h07ccvgbm8591c"))
       (file-name (string-append name "-" version ".tar.gz"))))
    (build-system gnu-build-system)
    (native-inputs `(("valgrind" ,valgrind)))   ; for tests
    (arguments
     `(#:test-target "test"
       #:parallel-tests? #f ; tests fail if run in parallel
       #:make-flags (list "CC=gcc"
                          (string-append "PREFIX=" (assoc-ref %outputs "out")))
       #:phases (modify-phases %standard-phases
                  (delete 'configure))))        ; no configure script
    (home-page "http://www.lz4.org")
    (synopsis "Compression algorithm focused on speed")
    (description "LZ4 is a lossless compression algorithm, providing
compression speed at 400 MB/s per core (0.16 Bytes/cycle).  It also features an
extremely fast decoder, with speed in multiple GB/s per core (0.71 Bytes/cycle).
A high compression derivative, called LZ4_HC, is also provided.  It trades CPU
time for compression ratio.")
    ;; The libraries (lz4, lz4hc, and xxhash) are BSD licenced. The command
    ;; line interface programs (lz4, fullbench, fuzzer, datagen) are GPL2+.
    (license (list license:bsd-2 license:gpl2+))))

(define-public python-lz4
  (package
    (name "python-lz4")
    (version "0.10.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "lz4" version))
       (sha256
        (base32
         "0ghv1xbaq693kgww1x9c22bplz479ls9szjsaa4ig778ls834hm0"))))
    (build-system python-build-system)
    (native-inputs
     `(("python-nose" ,python-nose)
       ("python-setuptools-scm" ,python-setuptools-scm)))
    (home-page "https://github.com/python-lz4/python-lz4")
    (synopsis "LZ4 bindings for Python")
    (description
     "This package provides python bindings for the lz4 compression library
by Yann Collet.  The project contains bindings for the LZ4 block format and
the LZ4 frame format.")
    (license license:bsd-3)))

(define-public python2-lz4
  (package-with-python2 python-lz4))

(define-public python-lzstring
  (package
    (name "python-lzstring")
    (version "1.0.3")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "lzstring" version))
       (sha256
        (base32
         "1d3ck454y41mii0gcjabpmp2skb7n0f9zk232gycqdv8z2jxakfm"))))
    (build-system python-build-system)
    (propagated-inputs
     `(("python-future" ,python-future)))
    (home-page "https://github.com/gkovacs/lz-string-python")
    (synopsis "String compression")
    (description "Lz-string is a string compressor library for Python.")
    (license license:expat)))

(define-public python2-lzstring
  (package-with-python2 python-lzstring))

(define-public squashfs-tools
  (package
    (name "squashfs-tools")
    (version "4.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://sourceforge/squashfs/squashfs/"
                                  "squashfs" version "/"
                                  "squashfs" version ".tar.gz"))
              (sha256
               (base32
                "1xpklm0y43nd9i6jw43y2xh5zvlmj9ar2rvknh0bh7kv8c95aq0d"))))
    (build-system gnu-build-system)
    (arguments
     '(#:tests? #f ; no check target
       #:make-flags
       (list "CC=gcc"
             "XZ_SUPPORT=1"
             "LZO_SUPPORT=1"
             "LZ4_SUPPORT=1"
             (string-append "INSTALL_DIR=" %output "/bin"))
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
                  (lambda _
                    (chdir "squashfs-tools"))))))
    (inputs
     `(("lz4" ,lz4)
       ("lzo" ,lzo)
       ("xz" ,xz)
       ("zlib" ,zlib)))
    (home-page "http://squashfs.sourceforge.net/")
    (synopsis "Tools to create and extract squashfs file systems")
    (description
     "Squashfs is a highly compressed read-only file system for Linux.  It uses
zlib to compress files, inodes, and directories.  All blocks are packed to
minimize the data overhead, and block sizes of between 4K and 1M are supported.
It is intended to be used for archival use, for live CDs, and for embedded
systems where low overhead is needed.  This package allows you to create and
extract such file systems.")
    (license license:gpl2+)))

(define-public pigz
  (package
    (name "pigz")
    (version "2.3.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://zlib.net/pigz/"
                                  name "-" version ".tar.gz"))
              (sha256
               (base32
                "172hdf26k4zmm7z8md7nl0dph2a7mhf3x7slb9bhfyff6as6g2sf"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
                  (lambda* (#:key outputs #:allow-other-keys)
                    (let* ((out (assoc-ref outputs "out"))
                           (bin (string-append out "/bin"))
                           (man (string-append out "/share/man/man1")))
                      (install-file "pigz" bin)
                      (symlink "pigz" (string-append bin  "/unpigz"))
                      (install-file "pigz.1" man)
                      #t))))
       #:make-flags (list "CC=gcc")
       #:test-target "tests"))
    (inputs `(("zlib" ,zlib)))
    (home-page "http://zlib.net/pigz/")
    (synopsis "Parallel implementation of gzip")
    (description
     "This package provides a parallel implementation of gzip that exploits
multiple processors and multiple cores when compressing data.")

    ;; Things under zopfli/ are under ASL2.0, but 4 files at the top-level,
    ;; written by Mark Adler, are under another non-copyleft license.
    (license license:asl2.0)))

(define-public pixz
  (package
    (name "pixz")
    (version "1.0.6")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/vasi/pixz/releases/download/v" version
                    "/pixz-" version ".tar.xz"))
              (sha256
               (base32
                "1s3j7zw6j5zi3fhdxg287ndr3wf6swac7z21mqd1pyiln530gi82"))))
    (build-system gnu-build-system)
    (native-inputs
     `(("pkg-config" ,pkg-config)
       ("libarchive" ,libarchive)))
    (home-page "https://github.com/vasi/pixz")
    (synopsis "Parallel indexing implementation of LZMA")
    (description
     "The existing XZ Utils provide great compression in the .xz file format,
but they produce just one big block of compressed data.  Pixz instead produces
a collection of smaller blocks which makes random access to the original data
possible and can compress in parallel.  This is especially useful for large
tarballs.")
    (license license:bsd-2)))

(define-public brotli
  (let ((commit "e992cce7a174d6e2b3486616499d26bb0bad6448")
        (revision "1"))
    (package
      (name "brotli")
      (version (string-append "0.1-" revision "."
                              (string-take commit 7)))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/bagder/libbrotli.git")
                      (commit commit)
                      (recursive? #t)))
                (file-name (string-append name "-" version ".tar.xz"))
                (sha256
                 (base32
                  "1qxxsasvwbbbh6dl3138y9h3fg0q2v7xdk5jjc690bdg7g1wrj6n"))
                (modules '((guix build utils)))
                (snippet
                 ;; This is a recursive submodule that is unnecessary for this
                 ;; package, so delete it.
                 '(delete-file-recursively "brotli/terryfy"))))
      (build-system gnu-build-system)
      (native-inputs
       `(("autoconf" ,autoconf)
         ("automake" ,automake)
         ("libtool" ,libtool)))
      (arguments
       `(#:phases (modify-phases %standard-phases
                    (add-after 'unpack 'autogen
                      (lambda _
                        (mkdir "m4")
                        (zero? (system* "autoreconf" "-vfi")))))))
      (home-page "https://github.com/bagder/libbrotli/")
      (synopsis "Implementation of the Brotli compression algorithm")
      (description
       "Brotli is a general-purpose lossless compression algorithm.  It is
similar in speed to deflate but offers denser compression.  This package
provides encoder and a decoder libraries: libbrotlienc and libbrotlidec,
respectively, based on the reference implementation from Google.")
      (license license:expat))))

(define-public cabextract
 (package
   (name "cabextract")
   (version "1.6")
   (source (origin
              (method url-fetch)
              (uri (string-append
                    "http://cabextract.org.uk/cabextract-" version ".tar.gz"))
              (sha256
               (base32
                "1ysmmz25fjghq7mxb2anyyvr1ljxqxzi4piwjhk0sdamcnsn3rnf"))))
    (build-system gnu-build-system)
    (arguments '(#:configure-flags '("--with-external-libmspack")))
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("libmspack" ,libmspack)))
    (home-page "http://www.cabextract.org.uk/")
    (synopsis "Tool to unpack Cabinet archives")
    (description "Extracts files out of Microsoft Cabinet (.cab) archives")
    ;; Some source files specify gpl2+, lgpl2+, however COPYING is gpl3.
    (license license:gpl3+)))

(define-public xdelta
  (package
    (name "xdelta")
    (version "3.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/jmacd/xdelta/archive/v"
                           version ".tar.gz"))
       (sha256
        (base32
         "17g2pbbqy6h20qgdjq7ykib7kg5ajh8fwbsfgyjqg8pwg19wy5bm"))
       (file-name (string-append name "-" version ".tar.gz"))
       (snippet
        ;; This file isn't freely distributable and has no effect on building.
        '(delete-file "xdelta3/draft-korn-vcdiff.txt"))))
    (build-system gnu-build-system)
    (native-inputs
     `(("autoconf" ,autoconf)
       ("automake" ,automake)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'enter-build-directory
           (lambda _ (chdir "xdelta3")))
         (add-after 'enter-build-directory 'autoconf
           (lambda _ (zero? (system* "autoreconf" "-vfi")))))))
    (home-page "http://xdelta.com")
    (synopsis "Delta encoder for binary files")
    (description "xdelta encodes only the differences between two binary files
using the VCDIFF algorithm and patch file format described in RFC 3284.  It can
also be used to apply such patches.  xdelta is similar to @command{diff} and
@command{patch}, but is not limited to plain text and does not generate
human-readable output.")
    (license license:asl2.0)))

(define-public lrzip
  (package
    (name "lrzip")
    (version "0.631")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "http://ck.kolivas.org/apps/lrzip/lrzip-" version ".tar.bz2"))
       (sha256
        (base32
         "0mb449vmmwpkalq732jdyginvql57nxyd31sszb108yps1lf448d"))))
    (build-system gnu-build-system)
    (native-inputs
     `(;; nasm is only required when building for 32-bit x86 platforms
       ,@(if (string-prefix? "i686" (or (%current-target-system)
                                        (%current-system)))
             `(("nasm" ,nasm))
             '())
       ("perl" ,perl)))
    (inputs
     `(("bzip2" ,bzip2)
       ("lzo" ,lzo)
       ("zlib" ,zlib)))
    (home-page "http://ck.kolivas.org/apps/lrzip/")
    (synopsis "Large file compressor with a very high compression ratio")
    (description "lrzip is a compression utility that uses long-range
redundancy reduction to improve the subsequent compression ratio of
larger files.  It can then further compress the result with the ZPAQ or
LZMA algorithms for maximum compression, or LZO for maximum speed.  This
choice between size or speed allows for either better compression than
even LZMA can provide, or a higher speed than gzip while compressing as
well as bzip2.")
    (license (list license:gpl3+
                   license:public-domain)))) ; most files in lzma/

(define-public snappy
  (package
    (name "snappy")
    (version "1.1.3")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/google/snappy/releases/download/"
                    version "/" name "-" version ".tar.gz"))
              (sha256
               (base32
                "1wzf8yif5ym2gj52db6v5m1pxnmn258i38x7llk9x346y2nq47ig"))))
    (build-system gnu-build-system)
    (home-page "https://github.com/google/snappy")
    (synopsis "Fast compressor/decompressor")
    (description "Snappy is a compression/decompression library. It does not
aim for maximum compression, or compatibility with any other compression library;
instead, it aims for very high speeds and reasonable compression. For instance,
compared to the fastest mode of zlib, Snappy is an order of magnitude faster
for most inputs, but the resulting compressed files are anywhere from 20% to
100% bigger.")
    (license license:asl2.0)))

(define-public p7zip
  (package
    (name "p7zip")
    (version "16.02")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://sourceforge/" name "/" name "/"
                                  version "/" name "_" version
                                  "_src_all.tar.bz2"))
              (sha256
               (base32
                "07rlwbbgszq8i7m8jh3x6j2w2hc9a72dc7fmqawnqkwlwb00mcjy"))
              (modules '((guix build utils)))
              (snippet
               '(begin
                  ;; Remove non-free source files
                  (for-each delete-file
                            (append
                             (find-files "CPP/7zip/Compress" "Rar.*")
                             (find-files "CPP/7zip/Crypto" "Rar.*")
                             (find-files "DOC/unRarLicense.txt")
                             (find-files  "Utils/file_Codecs_Rar_so.py")))
                  (delete-file-recursively "CPP/7zip/Archive/Rar")
                  (delete-file-recursively "CPP/7zip/Compress/Rar")
                  #t))
              (patches (search-patches "p7zip-CVE-2016-9296.patch"
                                       "p7zip-remove-unused-code.patch"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "DEST_HOME=" (assoc-ref %outputs "out")) "all3")
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key system outputs #:allow-other-keys)
             (zero? (system* "cp"
                             (let ((system ,(or (%current-target-system)
                                                (%current-system))))
                               (cond
                                ((string-prefix? "x86_64" system)
                                 "makefile.linux_amd64_asm")
                                ((string-prefix? "i686" system)
                                 "makefile.linux_x86_asm_gcc_4.X")
                                (else
                                 "makefile.linux_any_cpu_gcc_4.X")))
                             "makefile.machine"))))
         (replace 'check
           (lambda _
             (and (zero? (system* "make" "test"))
                  (zero? (system* "make" "test_7z"))
                  (zero? (system* "make" "test_7zr"))))))))
    (inputs
     (let ((system (or (%current-target-system)
                       (%current-system))))
       `(,@(cond ((string-prefix? "x86_64" system)
                  `(("yasm" ,yasm)))
                 ((string-prefix? "i686" system)
                  `(("nasm" ,nasm)))
                 (else '())))))
    (home-page "http://p7zip.sourceforge.net/")
    (synopsis "Command-line file archiver with high compression ratio")
    (description "p7zip is a command-line port of 7-Zip, a file archiver that
handles the 7z format which features very high compression ratios.")
    (license (list license:lgpl2.1+
                   license:gpl2+
                   license:public-domain))))

(define-public gzstream
  (package
    (name "gzstream")
    (version "1.5")
    (source (origin
              (method url-fetch)
              (uri
                ;; No versioned URL, but last release was in 2003.
                "http://www.cs.unc.edu/Research/compgeom/gzstream/gzstream.tgz")
                (file-name (string-append name "-" version ".tgz"))
                (sha256
                 (base32
                  "00y19pqjsdj5zcrx4p9j56pl73vayfwnb7y2hvp423nx0cwv5b4r"))
                (modules '((guix build utils)))
                (snippet
                 ;; Remove pre-compiled object.
                 '(delete-file "gzstream.o"))))
    (build-system gnu-build-system)
    (arguments
     `(#:test-target "test"
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (lib (string-append out "/lib"))
                    (include (string-append out "/include")))
               (install-file "libgzstream.a" lib)
               (install-file "gzstream.h" include)
               #t))))))
    (propagated-inputs `(("zlib" ,zlib)))
    (home-page "http://www.cs.unc.edu/Research/compgeom/gzstream/")
    (synopsis "Compressed C++ iostream")
    (description "gzstream is a small library for providing zlib
functionality in a C++ iostream.")
    (license license:lgpl2.1+)))

(define-public zpaq
  (package
    (name "zpaq")
    (version "7.15")
    (source
     (origin
       (method url-fetch/zipbomb)
       (uri (string-append "http://mattmahoney.net/dc/zpaq"
                           (string-delete #\. version) ".zip"))
       (sha256
        (base32
         "066l94yyladlfzri877nh2dhkvspagjn3m5bmv725fmhkr9c4pp8"))
       (modules '((guix build utils)))
       (snippet
        ;; Delete irrelevant pre-compiled binaries.
        '(for-each delete-file (find-files "." "\\.exe$")))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'configure))           ; no ‘configure’ script
       #:make-flags
       (list
        (string-append "CPPFLAGS=-Dunix"
                       ,(match (or (%current-target-system)
                                   (%current-system))
                               ("x86_64-linux"  "")
                               ("i686-linux"    "")
                               (_               " -DNOJIT")))
        ;; These should be safe, lowest-common-denominator instruction sets,
        ;; allowing for some optimisation while remaining reproducible.
        (string-append "CXXFLAGS=-O3 -DNDEBUG"
                       ,(match (or (%current-target-system)
                                   (%current-system))
                               ("x86_64-linux"  " -march=nocona -mtune=generic")
                               ("i686-linux"    " -march=i686 -mtune=generic")
                               ("armhf-linux"   " -mtune=generic-armv7-a")
                               (_               "")))
        (string-append "PREFIX="
                       (assoc-ref %outputs "out")))))
    (native-inputs
     `(("perl" ,perl)))                 ; for pod2man
    (home-page "http://mattmahoney.net/dc/zpaq.html")
    (synopsis "Incremental journaling archiver")
    (description "ZPAQ is a command-line archiver for realistic situations with
many duplicate and already compressed files.  It backs up only those files
modified since the last update.  All previous versions remain untouched and can
be independently recovered.  Identical files are only stored once (known as
@dfn{de-duplication}).  Archives can also be encrypted.

ZPAQ is intended to back up user data, not entire operating systems.  It ignores
owner and group IDs, ACLs, extended attributes, or special file types like
devices, sockets, or named pipes.  It does not follow or restore symbolic links
or junctions, and always follows hard links.")
    (license (list license:public-domain
                   ;; libzpaq.cpp contains a mix of public-domain and
                   ;; expat-licenced (or ‘MIT’) code.
                   license:expat))))

(define-public unshield
  (package
    (name "unshield")
    (version "1.4.2")
    (source
     (origin (method url-fetch)
             (uri (string-append "http://github.com/twogood/unshield/archive/"
                                 version ".tar.gz"))
             (sha256
              (base32
               "0x7ps644yp5dka2zhb8w0ifqmw3d255jafpzfwv8xbcpgq6fmm2x"))))
    (build-system cmake-build-system)
    (inputs
     `(("zlib" ,zlib)
       ("openssl" ,openssl)
       ;; test data that is otherwise downloaded with curl
       ("unshield-avigomanager11b22.zip"
        ,(origin
           (method url-fetch)
           (uri (string-append "https://www.dropbox.com/s/8r4b6752swe3nhu/"
                               "unshield-avigomanager11b22.zip?dl=1"))
           (sha256
            (base32 "0fwq7lih04if68wpwpsk5wjqyvh32db76a41sq6gbx4dn1lc3ddn"))
           (file-name "unshield-avigomanager11b22.zip")))
       ("unshield-the-feeble-files-spanish.zip"
        ,(origin
           (method url-fetch)
           (uri (string-append "https://www.dropbox.com/s/1ng0z9kfxc7eb1e/"
                               "unshield-the-feeble-files-spanish.zip?dl=1"))
           (sha256
            (base32 "1k5cw6vnpja8yjlnhx5124xrw9i8s1l539hfdqqrqz3l5gn0bnyd"))
           (file-name "unshield-the-feeble-files-spanish.zip")))))
    (native-inputs
     `(("unzip" ,unzip)))
    (arguments
     `(#:out-of-source? #f
       #:phases
       (modify-phases %standard-phases
         (add-before 'check 'pre-check
           (lambda* (#:key inputs #:allow-other-keys)
             (for-each (lambda (i)
                         (copy-file (assoc-ref inputs i)
                                    (string-append "test/v0/" i)))
                       '("unshield-avigomanager11b22.zip"
                         "unshield-the-feeble-files-spanish.zip"))
             (substitute* (find-files "test/" "/*\\.sh")
               ;; Tests expect the unshield binary in a specific
               ;; location.
               (("/var/tmp/unshield/bin/unshield")
                (string-append (getcwd) "/src/unshield"))
               ;; We no longer need to download the data.
               ((".?URL=.*$") "")
               (("curl -(|f)sSL -o test.zip .*") ""))
             (substitute* "test/v0/avigomanager.sh"
               (("test.zip")
                (string-append (getcwd)
                  "/test/v0/unshield-avigomanager11b22.zip")))
             (substitute* "test/v0/the-feeble-files-spanish.sh"
               (("test.zip")
                (string-append (getcwd)
                               "/test/v0/unshield-the-feeble-files-spanish.zip")))
             #t))
         (replace 'check
           (lambda _
            (zero? (system* "./run-tests.sh")))))))
    (home-page "https://github.com/twogood/unshield")
    (synopsis "Extract CAB files from InstallShield installers")
    (description
     "@command{unshield} is a tool and library for extracting @file{.cab}
 archives from InstallShield installers.")
    (license license:expat)))

(define-public unrar
  (package
    (name "unrar")
    (version "0.0.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "http://download.gna.org/unrar/unrar-" version ".tar.gz"))
              (sha256
               (base32
                "1fgmjaxffj3shyxgy765jhxwz1cq88hk0fih1bsdzyvymyyz6mz7"))))
    (build-system gnu-build-system)
    (home-page "http://download.gna.org/unrar")
    (synopsis "RAR archive extraction tool")
    (description "Unrar is a simple command-line program to list and extract
RAR archives.")
    (license license:gpl2+)))

(define-public zstd
  (package
    (name "zstd")
    (version "1.3.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/facebook/zstd/archive/v"
                                  version ".tar.gz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "12krs9k5f408kyn0d7dwxqyc67177mgd14783ay10rafqsim8l5c"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'configure))           ; no configure script
       #:make-flags
       (list "CC=gcc"
             (string-append "PREFIX=" (assoc-ref %outputs "out")))
       #:test-target "test"))
    (home-page "http://zstd.net/")
    (synopsis "Zstandard real-time compression algorithm")
    (description "Zstandard (@command{zstd}) is a lossless compression algorithm
that combines very fast operation with a compression ratio comparable to that of
zlib.  In most scenarios, both compression and decompression can be performed in
‘real time’.  The compressor can be configured to provide the most suitable
trade-off between compression ratio and speed, without affecting decompression
speed.")
    (license (list license:bsd-3         ; the main top-level LICENSE file
                   license:bsd-2         ; many files explicitly state 2-Clause
                   license:gpl2          ; the mail top-level COPYING file
                   license:gpl3+         ; tests/gzip/*.sh
                   license:expat         ; lib/dictBuilder/divsufsort.[ch]
                   license:public-domain ; zlibWrapper/examples/fitblk*
                   license:zlib))))      ; zlibWrapper/{gz*.c,gzguts.h}

(define-public pzstd
  (package
    (name "pzstd")
    (version (package-version zstd))
    (source (package-source zstd))
    (build-system gnu-build-system)
    (native-inputs
     `(("googletest", googletest)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'enter-subdirectory
           (lambda _ (chdir "contrib/pzstd")))
         (delete 'configure)            ; no configure script
         (add-before 'check 'compile-tests
           (lambda* (#:key make-flags #:allow-other-keys)
             (zero? (apply system* "make" "tests" make-flags))))
         (add-after 'install 'install-documentation
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (doc (string-append out "/share/doc/" ,name)))
               (mkdir-p doc)
               (install-file "README.md" doc)
               #t))))
       #:make-flags
       (list "CC=gcc"
             (string-append "PREFIX=" (assoc-ref %outputs "out")))))
    (home-page (package-home-page zstd))
    (synopsis "Threaded implementation of the Zstandard compression algorithm")
    (description "Parallel Zstandard (PZstandard or @command{pzstd}) is a
multi-threaded implementation of the @uref{http://zstd.net/, Zstandard
compression algorithm}.  It is fully compatible with the original Zstandard file
format and command-line interface, and can be used as a drop-in replacement.

Compression is distributed over multiple processor cores to improve performance,
as is the decompression of data compressed in this manner.  Data compressed by
other implementations will only be decompressed by two threads: one performing
the actual decompression, the other input and output.")
    (license (package-license zstd))))

(define-public zip
  (package
    (name "zip")
    (version "3.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://sourceforge/infozip"
                           "/Zip%203.x%20%28latest%29/3.0/zip30.tar.gz"))
       (sha256
        (base32
         "0sb3h3067pzf3a7mlxn1hikpcjrsvycjcnj9hl9b1c3ykcgvps7h"))))
    (build-system gnu-build-system)
    (inputs `(("bzip2" ,bzip2)))
    (arguments
     `(#:tests? #f ; no test target
       #:make-flags (let ((out (assoc-ref %outputs "out")))
                      (list "-f" "unix/Makefile"
                            (string-append "prefix=" out)
                            (string-append "MANDIR=" out "/share/man/man1")))
       #:modules ((guix build gnu-build-system)
                  (guix build utils)
                  (srfi srfi-1))
       #:phases
       (modify-phases %standard-phases
         (replace 'build
           (lambda* (#:key (make-flags '()) #:allow-other-keys)
             (zero? (apply system* "make" "generic_gcc" make-flags))))
         (delete 'configure))))
    (home-page "http://www.info-zip.org/Zip.html")
    (synopsis "Compression and file packing utility")
    (description
     "Zip is a compression and file packaging/archive utility.  Zip is useful
for packaging a set of files for distribution, for archiving files, and for
saving disk space by temporarily compressing unused files or directories.
Zip puts one or more compressed files into a single ZIP archive, along with
information about the files (name, path, date, time of last modification,
protection, and check information to verify file integrity).  An entire
directory structure can be packed into a ZIP archive with a single command.

Zip has one compression method (deflation) and can also store files without
compression.  Zip automatically chooses the better of the two for each file.
Compression ratios of 2:1 to 3:1 are common for text files.")
    (license (license:non-copyleft "file://LICENSE"
                                   "See LICENSE in the distribution."))))

(define-public unzip
  (package (inherit zip)
    (name "unzip")
    (version "6.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://sourceforge/infozip"
                           "/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz"))
       (sha256
        (base32
         "0dxx11knh3nk95p2gg2ak777dd11pr7jx5das2g49l262scrcv83"))
       (patches (search-patches "unzip-CVE-2014-8139.patch"
                                "unzip-CVE-2014-8140.patch"
                                "unzip-CVE-2014-8141.patch"
                                "unzip-CVE-2014-9636.patch"
                                "unzip-CVE-2015-7696.patch"
                                "unzip-CVE-2015-7697.patch"
                                "unzip-allow-greater-hostver-values.patch"
                                "unzip-initialize-symlink-flag.patch"
                                "unzip-remove-build-date.patch"
                                "unzip-attribs-overflow.patch"
                                "unzip-overflow-on-invalid-input.patch"
                                "unzip-format-secure.patch"
                                "unzip-overflow-long-fsize.patch"))))
    (build-system gnu-build-system)
    ;; no inputs; bzip2 is not supported, since not compiled with BZ_NO_STDIO
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (delete 'configure)
                  (replace 'build
                    (lambda* (#:key make-flags #:allow-other-keys)
                      (zero? (apply system* "make"
                                    `("-j" ,(number->string
                                             (parallel-job-count))
                                      ,@make-flags
                                      "generic_gcc"))))))
       #:make-flags (list "-f" "unix/Makefile"
                          (string-append "prefix=" %output)
                          (string-append "MANDIR=" %output "/share/man/man1"))))
    (home-page "http://www.info-zip.org/UnZip.html")
    (synopsis "Decompression and file extraction utility")
    (description
     "UnZip is an extraction utility for archives compressed in .zip format,
also called \"zipfiles\".

UnZip lists, tests, or extracts files from a .zip archive.  The default
behaviour (with no options) is to extract into the current directory, and
subdirectories below it, all files from the specified zipfile.  UnZip
recreates the stored directory structure by default.")
    (license (license:non-copyleft "file://LICENSE"
                                   "See LICENSE in the distribution."))))

(define-public zziplib
  (package
    (name "zziplib")
    (version "0.13.62")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://sourceforge/zziplib/zziplib13/"
                           version "/zziplib-"
                           version ".tar.bz2"))
       (patches (search-patches "zziplib-CVE-2017-5974.patch"
                                "zziplib-CVE-2017-5975.patch"
                                "zziplib-CVE-2017-5976.patch"
                                "zziplib-CVE-2017-5978.patch"
                                "zziplib-CVE-2017-5979.patch"
                                "zziplib-CVE-2017-5981.patch"))
       (sha256
        (base32
         "0nsjqxw017hiyp524p9316283jlf5piixc1091gkimhz38zh7f51"))))
    (build-system gnu-build-system)
    (inputs
     `(("zlib" ,zlib)))
    (native-inputs `(("perl" ,perl)     ; for the documentation
                     ("pkg-config" ,pkg-config)
                     ;; for the documentation; Python 3 not supported,
                     ;; http://forums.gentoo.org/viewtopic-t-863161-start-0.html
                     ("python" ,python-2)
                     ("zip" ,zip))) ; to create test files
    (arguments
     `(#:parallel-tests? #f)) ; since test files are created on the fly
    (home-page "http://zziplib.sourceforge.net/")
    (synopsis "Library for accessing zip files")
    (description
     "ZZipLib is a library based on zlib for accessing zip files.")
    (license license:lgpl2.0+)))

(define-public perl-zip
  (package
    (name "perl-zip")
    (version "1.59")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "mirror://cpan/authors/id/A/AD/ADAMK/Archive-Zip-"
             version ".tar.gz"))
       (sha256
        (base32
         "0m31qlppg65vh32pwxkwjby02q70abx49d2yk6vfd4585fqb27cx"))))
    (build-system perl-build-system)
    (synopsis  "Provides an interface to ZIP archive files")
    (description "The Archive::Zip module allows a Perl program to create,
manipulate, read, and write Zip archive files.")
    (home-page "http://search.cpan.org/~adamk/Archive-Zip-1.30/")
    (license license:perl-license)))

(define-public libzip
  (package
    (name "libzip")
    (version "1.3.0")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://nih.at/libzip/libzip-" version ".tar.xz"))
              (sha256
               (base32
                "0wykw0q9dwdzx0gssi2dpgckx9ggr2spzc1amjnff6wi6kz6x4xa"))))
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-after 'build 'remove-failing-tests
           ;; These tests are known to fail on 32-bit architectures.
           ;; see thread: https://nih.at/listarchive/libzip-discuss/msg00713.html
           (lambda _
             (substitute* "regress/Makefile"
               (("encryption-nonrandom") "#encryption-nonrandom"))
             #t)))))
    (native-inputs
     `(("perl" ,perl)))
    (inputs
     `(("zlib" ,zlib)))
    (build-system gnu-build-system)
    (home-page "https://nih.at/libzip/index.html")
    (synopsis "C library for reading, creating, and modifying zip archives")
    (description "Libzip is a C library for reading, creating, and modifying
zip archives.  Files can be added from data buffers, files, or compressed data
copied directly from other zip archives.  Changes made without closing the
archive can be reverted.")
    (license license:bsd-3)))

(define-public atool
  (package
    (name "atool")
    (version "0.39.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "http://savannah.nongnu.org/download/atool/atool-"
                           version ".tar.gz"))
       (sha256
        (base32
         "0fvhzip2v08jgnlfpyj6rapan39xlsl1ksgq4lp8gfsai2ah1xma"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'embed-absolute-file-name
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "atool"
               (("(^\\$::cfg_path_file.*= )'file'" _ pre)
                (string-append pre "'" (assoc-ref inputs "file")
                               "/bin/file'")))
             #t)))))
    (inputs
     `(("perl" ,perl)
       ("file" ,file)))
    (home-page "http://www.nongnu.org/atool/")
    (synopsis  "Universal tool to manage file archives of various types")
    (description "The main command is @command{aunpack} which extracts files
from an archive.  The other commands provided are @command{apack} (to create
archives), @command{als} (to list files in archives), and @command{acat} (to
extract files to standard out).  As @command{atool} invokes external programs
to handle the archives, not all commands may be supported for a certain type
of archives.")
    (license license:gpl2+)))

(define-public perl-archive-extract
  (package
    (name "perl-archive-extract")
    (version "0.80")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://cpan/authors/id/B/BI/BINGOS/Archive-Extract-"
                           version ".tar.gz"))
       (sha256
        (base32
         "1x15j1q6w6z8hqyqgap0lz4qbq2174wfhksy1fdd653ccbaw5jr5"))))
    (build-system perl-build-system)
    (home-page "http://search.cpan.org/dist/Archive-Extract/")
    (synopsis "Generic archive extracting mechanism")
    (description "It allows you to extract any archive file of the type .tar,
.tar.gz, .gz, .Z, tar.bz2, .tbz, .bz2, .zip, .xz,, .txz, .tar.xz or .lzma
without having to worry how it does so, or use different interfaces for each
type by using either Perl modules, or command-line tools on your system.")
    (license license:perl-license)))
