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
//const QString Logger::CREATE_UPDATE_PARAMETER_QUERY = "INSERT OR REPLACE INTO parameters (parameter,description,visualize,datatable) VALUES (?,?,?,?)";
//const QString Logger::DELETE_PARAMETER = "DELETE FROM parameters WHERE parameter = ?";
//const QString Logger::READ_PARAMETERS_TABLE = "SELECT * FROM parameters ORDER BY parameter ASC";

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
    QVector <QString> queries;

    queries.append("CREATE TABLE " + table + "(id INTEGER PRIMARY KEY, value REAL, timestamp TEXT)");

    for(int i=0;i<queries.size();i++)
    {
        db->exec(queries.at(i));
    }
}

void Logger::createParameterTable()
{
    QVector <QString> queries;

    queries.append("CREATE TABLE parameters (parameter TEXT PRIMARY KEY, description TEXT, visualize INTEGER, datatable TEXT)");

    for(int i=0;i<queries.size();i++)
    {
        db->exec(queries.at(i));
    }
}

QVariantList Logger::readData(QString table)
{
    QSqlQuery query = QSqlQuery("SELECT * FROM " + table + " ORDER BY timestamp ASC", *db);

    QVariantList tmp;
    QVariantMap map;

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



void Logger::addParameterEntry(QString parameterName, QString parameterDescription, bool visualize)
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
    }
    else
    {
        qDebug() << "addParameterEntry failed " << parameterName << " : " << query.lastError();
    }
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



