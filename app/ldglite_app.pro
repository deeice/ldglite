TEMPLATE = app
TARGET   =

include($$PWD/../ldgliteglobal.pri)

# The ABI version.
VER_MAJ = 1
VER_MIN = 3
VER_PAT = 4
VER_BLD = 0

win32 {
  VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT"."$$VER_BLD # major.minor.patch.build

  QMAKE_TARGET_COMPANY = "Don Heyse"
  QMAKE_TARGET_DESCRIPTION = "LDraw Image Renderer"
  QMAKE_TARGET_COPYRIGHT = "Copyright (c) 2018 Don Heyse, Trevor SANDY"
  QMAKE_TARGET_PRODUCT = "LDGLite ($$join(ARCH,,,bit))"
  RC_LANG = "English (United Kingdom)"
  RC_ICONS = "ldglite.ico"

} else {
  VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT              # major.minor.patch
}
DEFINES += VERSION_INFO=\\\"$$VERSION\\\"

DEPENDPATH  += .
INCLUDEPATH += .
INCLUDEPATH += ../ldrawini
ENABLE_TEST_GUI: INCLUDEPATH += ../mui

unix:!macx:TARGET = ldglite
else:      TARGET = LDGLite

# messages
win32: message("~~~ USING LOCAL STATIC FREEGLUT LIBRARY ~~~")
!isEmpty(OSMESA_LIBDIR): message("~~~ OSMESA - USING LOCAL LIBRARIES AT $${OSMESA_LOCAL_PREFIX_}/lib$$LIB_ARCH ~~~")

include($$PWD/ldgliteapp.pri)

ENABLE_TILE_RENDERING {
  DEFINES += TILE_RENDER_OPTION
  include($$PWD/tiles.pri)
}

ENABLE_PNG {
  DEFINES += USE_PNG
  win32 {
    INCLUDEPATH += \
    $$PWD/../win/png/include \

    equals (ARCH, 64): LIBS_ += -L$$_PRO_FILE_PWD_/../win/png/lib/x64 -lpng
    else:              LIBS_ += -L$$_PRO_FILE_PWD_/../win/png/lib -lpng
    message("~~~ USING LOCAL COPY OF PNG LIBRARY ~~~")

  } else {
    macx {
      # To install libpng follow these instructions:
      # 1. Press Command+Space and type Terminal and press enter/return key.
      # 2. [Optional - if you don't already have Homebrew installed] Run in Terminal app:
      #    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
      #    and press enter/return key. Wait for the command to finish - it may take a long time.
      # 3. Run:
      #    brew install libpng --universal [both 32-bit and 64-bit code]
      # Done! You can now use libpng.
      #
      SYSTEM_PNG_HEADERS = /usr/local/include/png.h
      exists(SYSTEM_PNG_HEADERS) {
        INCLUDEPATH += /usr/local/include
      } else {
        message("~~~ USING LOCAL COPY OF PNG HEADERS ~~~")
        INCLUDEPATH += $$PWD/../macx/png/include
      }
      SYSTEM_PNG_LIB = /usr/local/lib/libpng.a
      exists(SYSTEM_PNG_LIB) {
        LIBS_ += /usr/local/lib/libpng.a
      } else {
        message("~~~ USING LOCAL COPY OF PNG LIBRARY ~~~")
        LIBS_ += $$_PRO_FILE_PWD_/../macx/png/lib/libpng.a
      }
    } else {
      LIBS_ += -lpng
    }
  }
}

LIBS_  += -L$$DESTDIR/../../ldrawini/$$DESTDIR -lldrawini

ENABLE_TEST_GUI {
  LIBS_ += -L$$DESTDIR/../../mui/$$DESTDIR -lmui
}

LIBS += $${LIBS_} $${_LIBS} -lz

macx {
  MAKE_APP_BUNDLE {
    ICON = ldglite.icns
    QMAKE_INFO_PLIST = $$_PRO_FILE_PWD_/Info.plist

    ldglite_osxwrapper.files  += ldglite_w.command
    ldglite_osxwrapper.path    = Contents/MacOS

    ldglite_docs.files        += $$_PRO_FILE_PWD_/../doc/LICENCE $$_PRO_FILE_PWD_/../doc/Readme.macLdGLite $$_PRO_FILE_PWD_/../doc/README.TXT
    ldglite_docs.path          = Contents/doc

    set_ldraw_directory.files += set-ldrawdir.command
    set_ldraw_directory.path   = Contents/Resources

    QMAKE_BUNDLE_DATA += ldglite_osxwrapper set_ldraw_directory

    INFO_PLIST_FILE  = $$shell_quote$$DESTDIR/$${TARGET}.app/Contents/Info.plist
    PLIST_COMMAND    = /usr/libexec/PlistBuddy -c
    TYPEINFO_COMMAND = /bin/echo "APPLLdGL" > $$DESTDIR/$${TARGET}.app/Contents/PkgInfo
    WRAPPER_TARGET   = $$DESTDIR/$${TARGET}.app/Contents/MacOS/ldglite_w.command
    WRAPPER_CHMOD_COMMAND  = chmod 755 $$WRAPPER_TARGET
    LDRAWDIR_TARGET  = $$DESTDIR/$${TARGET}.app/Contents/Resources/set-ldrawdir.command
    LDRAWDIR_CHMOD_COMMAND = chmod 755 $$LDRAWDIR_TARGET
    QMAKE_POST_LINK += $$escape_expand(\n\t)   \
                       $$PLIST_COMMAND \"Set :CFBundleShortVersionString $${VERSION}\" $${INFO_PLIST_FILE}  \
                       $$escape_expand(\n\t)   \
                       $$PLIST_COMMAND \"Set :CFBundleVersion $${VERSION}\" $${INFO_PLIST_FILE} \
                       $$escape_expand(\n\t)   \
                       $$PLIST_COMMAND \"Set :CFBundleGetInfoString $${TARGET} $${VERSION} https://github.com/trevorsandy/ldglite\" $${INFO_PLIST_FILE} \
                       $$escape_expand(\n\t)   \
                       $$shell_quote$${TYPEINFO_COMMAND} \
                       $$escape_expand(\n\t)   \
                       $$shell_quote$${WRAPPER_CHMOD_COMMAND} \
                       $$escape_expand(\n\t)   \
                       $$shell_quote$${LDRAWDIR_CHMOD_COMMAND}
  } else {
    macx: CONFIG    -= app_bundle   # don't creatre app bundle
  }
}

3RD_PARTY_INSTALL {
  isEmpty(3RD_PACKAGE_VER):3RD_PACKAGE_VER = $$TARGET-$$VER_MAJ"."$$VER_MIN
  isEmpty(3RD_BINDIR):3RD_BINDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/bin/$$QT_ARCH
  isEmpty(3RD_DOCDIR):3RD_DOCDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/docs
  isEmpty(3RD_RESOURCES):3RD_RESOURCES     = $$3RD_PREFIX/$$3RD_PACKAGE_VER/resources

  message("~~~ LDGLITE 3RD INSTALL PREFIX $${3RD_PREFIX} ~~~")

  target.path                 = $${3RD_BINDIR}
  documentation.path          = $${3RD_DOCDIR}
  documentation.files         = $$_PRO_FILE_PWD_/../doc/ldglite.1 \
                                $$_PRO_FILE_PWD_/../doc/LICENCE \
                                $$_PRO_FILE_PWD_/../doc/README.TXT
  resources.path              = $${3RD_RESOURCES}
  resources.files             = set-ldrawdir.command
  macx: resources.files      += ldglite_w.command

  INSTALLS += target documentation resources

} else:linux:!macx {
  # someone asked for the standard linux install routine so here it is...
  isEmpty(PREFIX):PREFIX      = /usr
  isEmpty(BINDIR):BINDIR      = $$PREFIX/bin
  isEmpty(DATADIR):DATADIR    = $$PREFIX/share
  isEmpty(DOCDIR):DOCDIR      = $$DATADIR/doc
  isEmpty(MANDIR):MANDIR      = $$DATADIR/man

  target.path                 = $${BINDIR}
  documentation.path          = $${DOCDIR}/$${TARGET}
  documentation.files         = $$_PRO_FILE_PWD_/../doc/LICENCE \
                                $$_PRO_FILE_PWD_/../doc/README.TXT
  manual.path                 = $${MANDIR}
  manual.files                = $$_PRO_FILE_PWD_/../doc/ldglite.1

  INSTALLS += target documentation manual
}

# set config to enable build check
# CONFIG+=BUILD_CHECK
# ldglite -l3 -i2 -ca0.01 -cg23,-45,3031328 -J -v1240,1753 -o0,-292 -W2 -q -fh -2g,2x -w1 -l -ldcFtests/LDConfigCustom01.ldr -mFtests/TestOK_1.3.4_Foo2.png tests/Foo2.ldr
BUILD_CHECK: unix {
  # LDraw library path - needed for tests
  LDRAW_PATH = $$(LDRAWDIR)
  !isEmpty(LDRAW_PATH){
    message("~~~ LDRAW LIBRARY $${LDRAW_PATH} ~~~")
    QMAKE_POST_LINK += $$escape_expand(\n\t)                                               \
                       cd $${OUT_PWD}/$${DESTDIR} && ./$${TARGET} -l3 -i2 -ca0.01          \
                       -cg23,-45,3031328 -J -v1240,1753 -o0,-292 -W2 -q -fh -2g,2x -w1 -l  \
                       -ldcF$$_PRO_FILE_PWD_/../tests/LDConfigCustom01.ldr                 \
                       -mF$$_PRO_FILE_PWD_/../tests/$$DESTDIR-TestOK_1.3.4_Foo2.png        \
                       $$_PRO_FILE_PWD_/../tests/Foo2.ldr
  } else {
    message("WARNING: LDRAW LIBRARY PATH NOT DEFINED - LDGLite CUI cannot be tested")
  }
}
