/*
Copyright (c) 2014 kimmoli kimmo.lindholm@gmail.com @likimmo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#ifndef LOGGER_H
#define LOGGER_H
#include <QObject>
#include <QtSql>
#include <QColor>


class Logger : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString variable READ readVar WRITE writeVar(QString) NOTIFY varChanged())
    Q_PROPERTY(QString version READ readVersion NOTIFY versionChanged())

public:
    explicit Logger(QObject *parent = 0);
    ~Logger();

    QString readVar();
    QString readVersion();

    void writeVar(QString);

    Q_INVOKABLE void readInitParams();

    Q_INVOKABLE QString addParameterEntry(QString key, QString parameterName, QString parameterDescription, bool visualize, QColor plotColor);
    Q_INVOKABLE void deleteParameterEntry(QString parameterName, QString datatable);
    Q_INVOKABLE QVariantList readParameters();
    Q_INVOKABLE QVariantList readData(QString table);
    Q_INVOKABLE QString addData(QString table, QString key, QString value, QString timestamp);
    Q_INVOKABLE void deleteData(QString table, QString key);

    Q_INVOKABLE QString colorToString(QColor color) { return color.name(); }

    void dropDataTable(QString table);

    QString generateHash(QString sometext);

    void closeDatabase();
    void createParameterTable();
    void createDataTable(QString table);

    static const QString DB_NAME;

signals:
    void varChanged();
    void versionChanged();

private:
    QString m_var;
    QSqlDatabase* db;

};


#endif // LOGGER_H

