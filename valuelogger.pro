#
# Project valuelogger, Value Logger
#

TARGET = valuelogger

CONFIG += sailfishapp

QT += sql

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""

message($${DEFINES})

SOURCES += src/valuelogger.cpp \
	src/logger.cpp
	
HEADERS += src/logger.h

OTHER_FILES += qml/valuelogger.qml \
    qml/cover/CoverPage.qml \
    qml/pages/Valuelogger.qml \
    qml/pages/AboutPage.qml \
    rpm/valuelogger.spec \
	valuelogger.png \
    valuelogger.desktop \
    qml/pages/NewParameter.qml

