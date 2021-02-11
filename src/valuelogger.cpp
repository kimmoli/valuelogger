/*
Copyright (c) 2014-2015 kimmoli kimmo.lindholm@gmail.com @likimmo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtQml>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include <QSurfaceFormat>
#include "graph.h"
#include "logger.h"


int main(int argc, char *argv[])
{
    qmlRegisterType<Graph>("harbour.valuelogger.Logger", 1, 0, "Graph");
    qmlRegisterType<Logger>("harbour.valuelogger.Logger", 1, 0, "Logger");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    QTranslator translator;
    translator.load("translations_" + QLocale::system().name(), "/usr/share/harbour-valuelogger/i18n");
    app->installTranslator(&translator);

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    // Enable multisampling
    QSurfaceFormat format = view->format();
    format.setSamples(16);
    view->setFormat(format);
    view->setSource(SailfishApp::pathTo("qml/valuelogger.qml"));
    view->show();

    return app->exec();
}

