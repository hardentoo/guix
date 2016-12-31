;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2016 Danny Milosavljevic <dannym@scratchpost.org>
;;; Copyright © 2016 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2016 Hartmut Goebel <h.goebel@crazy-compilers.com>
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

(define-module (gnu packages education)
  #:use-module (ice-9 regex)
  #:use-module (gnu packages)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages xml)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix svn-download)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (srfi srfi-1))

(define-public stellarium
  (package
    (name "stellarium")
    (version "0.14.2")
    (source (origin
             (method url-fetch)
             (uri (string-append "mirror://sourceforge/stellarium/"
                                 "Stellarium-sources/"
                                 version "/stellarium-" version ".tar.gz"))
             (sha256 (base32
                      "1xxil0rv61zc08znfv83cpsc47y1gjl2f3njhz0pn5zd8jpaa15a"))))
    (build-system cmake-build-system)
    (inputs
      `(("qtbase" ,qtbase)
        ("zlib" ,zlib)
        ("qtserialport" ,qtserialport)
        ("qtscript" ,qtscript)
        ("gettext" ,gettext-minimal)))
    (native-inputs
      `(("qtbase" ,qtbase)                   ;Qt MOC is needed at compile time
        ("qttools" ,qttools)
        ("perl" ,perl)))                          ;for 'pod2man'
    (arguments
      `(#:test-target "tests"
        #:phases (modify-phases %standard-phases
                   (add-before 'check 'set-offscreen-display
                     (lambda _
                       (setenv "QT_QPA_PLATFORM" "offscreen")
                       (setenv "HOME" "/tmp")
                       #t)))))
    (home-page "http://www.stellarium.org/")
    (synopsis "3D sky viewer")
    (description "Stellarium is a planetarium.  It shows a realistic sky in
3D, just like what you see with the naked eye, binoculars, or a telescope.  It
can be used to control telescopes over a serial port for tracking celestial
objects.")
    (license license:gpl2+)))

(define-public gcompris
  (package
    (name "gcompris")
    (version "15.10")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://gcompris.net/download/gtk/src/gcompris-"
                                  version ".tar.bz2"))
              (sha256
               (base32
                "0f7wa27vvpn9ansp2aald1pajqlx5d51mvj07ba503yvl7i77fka"))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags
       ;; Use SDL mixer because otherwise GCompris would need an old version
       ;; of Gstreamer.
       (list "--enable-sdlmixer"
             "LDFLAGS=-lgmodule-2.0")
       #:phases
       (modify-phases %standard-phases
         (add-after 'set-paths 'set-sdl-paths
           (lambda* (#:key inputs #:allow-other-keys)
             (setenv "CPATH"
                     (string-append (assoc-ref inputs "sdl-mixer")
                                    "/include/SDL"))
             #t)))))
    (inputs
     `(("gtk+" ,gtk+-2)
       ("librsvg" ,librsvg)
       ("libxml2" ,libxml2)
       ("sdl-mixer" ,sdl-mixer)
       ("sqlite" ,sqlite)
       ("glib:bin" ,glib)
       ("python" ,python)))
    (native-inputs
     `(("intltool" ,intltool)
       ("texinfo" ,texinfo)
       ("texi2html" ,texi2html)
       ("glib:bin" ,glib "bin")
       ("pkg-config" ,pkg-config)))
    (home-page "http://gcompris.net")
    (synopsis "Educational software suite")
    (description "GCompris is an educational software suite comprising of
numerous activities for children aged 2 to 10.  Some of the activities are
game orientated, but nonetheless still educational.  Below you can find a list
of categories with some of the activities available in that category.

@enumerate
@item computer discovery: keyboard, mouse, different mouse gestures, ...
@item arithmetic: table memory, enumeration, double entry table, mirror image, ...
@item science: the canal lock, the water cycle, the submarine, electric simulation ...
@item geography: place the country on the map
@item games: chess, memory, connect 4, oware, sudoku ...
@item reading: reading practice
@item other: learn to tell time, puzzle of famous paintings, vector drawing, cartoon making, ...
@end enumerate
")
    (license license:gpl3+)))

(define-public tipp10
  (package
    (name "tipp10")
    (version "2.1.0")
    (source (origin
              (method url-fetch)
              ;; guix download is not able to handle the download links on the
              ;; home-page, which use '<meta http-equiv="refresh" …>'
              (uri (string-append "mirror://debian/pool/main/"
                                  "t/tipp10/tipp10_2.1.0.orig.tar.gz"))
              (sha256
               (base32
                "0d387b404j88gsv6kv0rb7wxr23v5g5vl6s5l7602x8pxf7slbbx"))
              (patches (search-patches "tipp10-fix-compiling.patch"
                                       "tipp10-remove-license-code.patch"))))
    (build-system cmake-build-system)
    (arguments
     `(#:tests? #f ; packages has no tests
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'disable-new-version-check
          (lambda _
            ;; Make new version check to default to false.
            ;; TODO: Remove the checkbox from the dialog and the check itself
            (substitute* '("widget/settingspages.cpp" "widget/mainwindow.cpp")
              (("settings.value(\"check_new_version\", true)")
               "settings.value(\"check_new_version\", false)"))))
         (replace 'configure
          (lambda* (#:key outputs #:allow-other-keys)
            (let ((out (assoc-ref outputs "out")))
              ;; Make program honor $PREFIX
              (substitute* "tipp10.pro"
                (("\\.path = /usr/") (string-append ".path = " out "/")))
              (substitute* "def/defines.h"
                (("\"/usr/") (string-append "\"" out "/")))
              ;; Recreate Makefile
              (zero? (system* "qmake"))))))))
    (inputs
     `(("qt4" ,qt-4)
       ("sqlite" ,sqlite)))
    (home-page "https://www.tipp10.com/")
    (synopsis "Touch typing tutor")
    (description "Tipp10 is a touch typing tutor for Windows, Mac OS and
Linux.  The ingenious thing about the software is its intelligence feature:
Characters that are mistyped are repeated more frequently.  Beginners will
find their way around right away so they can start practicing without a hitch.

Useful support functions and an extensive progress tracker, topical lessons
and the ability to create your own practice lessons make learning to type
easy.

Note: To change the language settings choose Datei (File) →
Grundeinstellungen (Generell Settings) → Sprache (Language) and change from
Deutsch to English. The you have restart the program to have the change take
effect.")
    (license license:gpl2)))
