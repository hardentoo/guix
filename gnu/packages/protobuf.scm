;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2014 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2016 Daniel Pimentel <d4n1@d4n1.org>
;;; Copyright © 2016 Leo Famulari <leo@famulari.name>
;;; Copyright © 2017 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2017 Tobias Geerinckx-Rice <me@tobias.gr>
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

(define-module (gnu packages protobuf)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module ((guix licenses)
                #:select (bsd-2 bsd-3))
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python))

(define-public protobuf
  (package
    (name "protobuf")
    (version "3.4.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/google/protobuf/releases/"
                                  "download/v" version "/protobuf-cpp-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "0y6cr4l7bwa6zvjv5flzr4cx28shk5h8dz99xw90v8qih954pcrb"))))
    (build-system gnu-build-system)
    (inputs `(("zlib" ,zlib)))
    (home-page "https://github.com/google/protobuf")
    (synopsis "Data encoding for remote procedure calls (RPCs)")
    (description
     "Protocol Buffers are a way of encoding structured data in an efficient
yet extensible format.  Google uses Protocol Buffers for almost all of its
internal RPC protocols and file formats.")
    (license bsd-3)))

;; XXX Remove this old version when no other packages depend on it.
(define-public protobuf-2
  (package (inherit protobuf)
    (version "2.6.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/google/protobuf/releases/"
                                  "download/v" version "/protobuf-"
                                  version ".tar.bz2"))
              (sha256
               (base32
                "040rcs9fpv4bslhiy43v7dcrzakz4vwwpyqg4jp8bn24sl95ci7f"))))))

(define-public protobuf-c
  (package
    (name "protobuf-c")
    (version "1.3.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/protobuf-c/protobuf-c/"
                                  "releases/download/v" version
                                  "/protobuf-c-" version ".tar.gz"))
              (sha256
               (base32
                "18aj4xfv26zjmj44zbb01wk90jl7y4aj5xvbzz4gg748kdxavjax"))))
    (build-system gnu-build-system)
    (inputs `(("protobuf" ,protobuf)))
    (native-inputs `(("pkg-config" ,pkg-config)))
    (home-page "https://github.com/protobuf-c/protobuf-c")
    (synopsis "Protocol Buffers implementation in C")
    (description
     "This is protobuf-c, a C implementation of the Google Protocol Buffers
data serialization format.  It includes @code{libprotobuf-c}, a pure C library
that implements protobuf encoding and decoding, and @code{protoc-c}, a code
generator that converts Protocol Buffer @code{.proto} files to C descriptor
code.")
    (license bsd-2)))

(define-public python-protobuf
  (package
    (name "python-protobuf")
    (version "3.4.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "protobuf" version))
       (sha256
        (base32
         "0x33xz85cy5ilg1n2rn92l4qwlcw25vzysx2ldv7k625yjg600pg"))))
    (build-system python-build-system)
    (propagated-inputs
     `(("python-six" ,python-six)))
    (home-page "https://github.com/google/protobuf")
    (synopsis "Protocol buffers is a data interchange format")
    (description
     "Protocol buffers are a language-neutral, platform-neutral extensible
mechanism for serializing structured data.")
    (license bsd-3)))

(define-public python2-protobuf
  (package-with-python2 python-protobuf))
