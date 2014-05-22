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

    Q_INVOKABLE void addParameterEntry(QString parameterName, QString parameterDescription);
    Q_INVOKABLE void testReadEntries(QString table);

    void closeDatabase();
    void createTables();

    static const QString CREATE_TABLE;
    static const QString INSERT_REPLACE;
    static const QString PARAMETERS_TABLE;
    static const QString CREATE_PARAMETERS_TABLE_QUERY;
    static const QString CREATE_UPDATE_PARAMETER_QUERY;
    static const QString DB_NAME;

signals:
    void varChanged();
    void versionChanged();

private:
    QString m_var;
    QSqlDatabase* db;

};


#endif // LOGGER_H

