#
# Project valuelogger, Value Logger
#

TARGET = harbour-valuelogger

CONFIG += sailfishapp

QT += sql

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""

message($${DEFINES})

#system(lupdate qml -ts $$PWD/i18n/*.ts)
system(lrelease $$PWD/i18n/*.ts)

i18n.path = /usr/share/harbour-valuelogger/i18n
i18n.files = i18n/translations_fi.qm \
             i18n/translations_sv.qm

INSTALLS += i18n

SOURCES += src/valuelogger.cpp \
	src/logger.cpp
	
HEADERS += src/logger.h

OTHER_FILES += qml/valuelogger.qml \
    qml/cover/CoverPage.qml \
    qml/pages/Valuelogger.qml \
    qml/pages/AboutPage.qml \
    rpm/valuelogger.spec \
        harbour-valuelogger.png \
    harbour-valuelogger.desktop \
    qml/pages/NewParameter.qml \
    qml/pages/AddValue.qml \
    qml/pages/ShowData.qml \
    qml/pages/DrawData.qml \
    qml/components/LinePlot.qml \
    i18n/translations_fi.ts \
    i18n/translations_sv.ts \
    qml/icon-cover-plot.png

TRANSLATIONS += i18n/translations_fi.ts \
                i18n/translations_sv.ts



