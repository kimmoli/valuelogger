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

    createParameterTable();

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

void Logger::createDataTable(QString table)
{
    QSqlQuery query = QSqlQuery("CREATE TABLE " + table + "(timestamp TEXT PRIMARY KEY, value TEXT)", *db);


    if (query.exec())
    {
        qDebug() << "datatable created " << table;
    }
    else
    {
        qDebug() << "datatable not created " << table << " : " << query.lastError();
    }
}

void Logger::createParameterTable()
{
    QSqlQuery query = QSqlQuery("CREATE TABLE parameters (parameter TEXT PRIMARY KEY, description TEXT, visualize INTEGER, datatable TEXT)", *db);

    if (query.exec())
    {
        qDebug() << "parameter table created";
    }
    else
    {
        qDebug() << "parameter table not created : " << query.lastError();
    }
}

void Logger::addData(QString table, QString value, QString timestamp)
{
    qDebug() << "Adding " << value << " (" << timestamp << ") to " << table;

    QSqlQuery query = QSqlQuery("INSERT OR REPLACE INTO " + table + " (timestamp,value) VALUES (?,?)", *db);
    query.addBindValue(timestamp);
    query.addBindValue(value);

    if (query.exec())
    {
        qDebug() << "data added " << timestamp << " = " << value;
    }
    else
    {
        qDebug() << "failed " << timestamp << " = " << value << " : " << query.lastError();
    }
}

QVariantList Logger::readData(QString table)
{
    QSqlQuery query = QSqlQuery("SELECT * FROM " + table + " ORDER BY timestamp ASC", *db);

    QVariantList tmp;
    QVariantMap map;

    return tmp;
}

QVariantList Logger::readParameters()
{
    QSqlQuery query = QSqlQuery("SELECT * FROM parameters ORDER BY parameter ASC", *db);

    QVariantList tmp;
    QVariantMap map;

    if (query.exec())
    {
        map.clear();
        while (query.next())
        {
            map.insert("description", query.record().value("description").toString());
            map.insert("visualize", query.record().value("visualize").toString());
            map.insert("datatable", query.record().value("datatable").toString());
            map.insert("name", query.record().value("parameter").toString());
            tmp.append(map);
        }
    }
    else
    {
        qDebug() << "readParameters failed " << query.lastError();
    }
    return tmp;
}



QString Logger::addParameterEntry(QString parameterName, QString parameterDescription, bool visualize)
{
    qDebug() << "Adding entry: " << parameterName << " - " << parameterDescription;

    QString objHash = QString(QCryptographicHash::hash((parameterName.toUtf8()),QCryptographicHash::Md5).toHex());

    qDebug() << "hash" << objHash;

    QSqlQuery query = QSqlQuery("INSERT OR REPLACE INTO parameters (parameter,description,visualize,datatable) VALUES (?,?,?,?)", *db);

    query.addBindValue(parameterName);
    query.addBindValue(parameterDescription);
    query.addBindValue(visualize ? 1:0 ); // store bool as integer
    query.addBindValue(objHash);

    if (query.exec())
    {
        qDebug() << "parameter added: " << parameterName;

        createDataTable(objHash);
    }
    else
    {
        qDebug() << "addParameterEntry failed " << parameterName << " : " << query.lastError();
    }

    return objHash;
}

void Logger::deleteParameterEntry(QString parameterName)
{
    QSqlQuery query = QSqlQuery("DELETE FROM parameters WHERE parameter = ?", *db);
    query.addBindValue(parameterName);
    if (query.exec())
        qDebug() << "Parameter " << parameterName << " deleted";
    else
        qDebug() << "deleteParameterEntry failed";
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



