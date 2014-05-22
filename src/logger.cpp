/*
Copyright (c) 2014 kimmoli kimmo.lindholm@gmail.com @likimmo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include "logger.h"
#include <QSettings>
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QtSql>

const QString Logger::DB_NAME = "";

const QString Logger::CREATE_TABLE ="CREATE TABLE ";
const QString Logger::INSERT_REPLACE = "INSERT OR REPLACE INTO ";
const QString Logger::PARAMETERS_TABLE = "parameters";
const QString Logger::CREATE_PARAMETERS_TABLE_QUERY = Logger::CREATE_TABLE + Logger::PARAMETERS_TABLE + " (parameter TEXT PRIMARY KEY, description TEXT, datatable TEXT)";
const QString Logger::CREATE_UPDATE_PARAMETER_QUERY = INSERT_REPLACE + PARAMETERS_TABLE +" (parameter,description,datatable) VALUES (?,?,?)";

Logger::Logger(QObject *parent) :
    QObject(parent)
{
    /* Open the SQLite database */

    QDir dbdir(QStandardPaths::writableLocation(QStandardPaths::DataLocation));

    if (!dbdir.exists())
    {
        dbdir.mkpath(QStandardPaths::writableLocation(QStandardPaths::DataLocation));
    }

    db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));

    db->setDatabaseName(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/valueLoggerDb.sqlite");

    qDebug()  << QStandardPaths::writableLocation(QStandardPaths::DataLocation);


    if (db->open())
    {
        qDebug() << "Open Success";
//        dbOpened();
    }
    else
    {
        qDebug() << "Open error";
        qDebug() << " " << db->lastError().text();
//        dbOpenError();
    }
    createTables();

    /* Read settings */

    m_var = "";
    emit versionChanged();
}

QString Logger::readVersion()
{
    return APPVERSION;
}

void Logger::readInitParams()
{
    QSettings settings;
    m_var = settings.value("var", "").toString();

    emit varChanged();
}

void Logger::createTables()
{
    QVector <QString> queries;
    queries.append(Logger::CREATE_PARAMETERS_TABLE_QUERY);

    for(int i=0;i<queries.size();i++)
    {
        db->exec(queries.at(i));
    }
}

void Logger::testReadEntries(QString table)
{
    QSqlQuery query = QSqlQuery("SELECT * FROM " + table + " ORDER BY parameter ASC", *db);

    if (query.exec())
    {
        while (query.next())
        {
            qDebug() << query.record().value("parameter").toString() << " : " << query.record().value("description").toString();
        }
    }
    else
    {
        qDebug() << "test read failed " << query.lastError();
    }
}

void Logger::addParameterEntry(QString parameterName, QString parameterDescription)
{
    qDebug() << "Adding entry: " << parameterName << " - " << parameterDescription;

    QString objHash = QString(QCryptographicHash::hash((parameterName.toUtf8()),QCryptographicHash::Md5).toHex());

    qDebug() << "hash" << objHash;

    QSqlQuery query = QSqlQuery(Logger::CREATE_UPDATE_PARAMETER_QUERY, *db);

    query.addBindValue(parameterName);
    query.addBindValue(parameterDescription);
    query.addBindValue(objHash);

    if (query.exec())
    {
        qDebug() << "parameter added: " << parameterName;
    }
    else
    {
        qDebug() << "error: " << parameterName << " : " << query.lastError();
    }
}

void Logger::closeDatabase()
{
    qDebug() << "Closing db";
    if (db)
    {
        db->removeDatabase(Logger::DB_NAME);
        db->close();
    }
}

Logger::~Logger()
{
    qDebug() << "Logger quitting";

    if (db)
    {
        delete db;
        db = 0;
    }
}


QString Logger::readVar()
{
    return m_var;
}

void Logger::writeVar(QString s)
{
    m_var = s;

    QSettings settings;
    settings.setValue("var", m_var);

    emit varChanged();
}



