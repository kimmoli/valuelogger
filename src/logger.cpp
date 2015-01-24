/*
Copyright (c) 2014 kimmoli kimmo.lindholm@gmail.com @likimmo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include "logger.h"

#include <QCoreApplication>
#include <QCryptographicHash>
#include <QtSql>
#include <QTime>
#include <QColor>
#include <QFile>
#include <QLocale>

const QString Logger::DB_NAME = "";

Logger::Logger(QObject *parent) :
    QObject(parent)
{
    /* Initialise random number generator */
    qsrand( QDateTime::currentDateTime().toTime_t() );

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
    }
    else
    {
        qDebug() << "Open error";
        qDebug() << " " << db->lastError().text();
    }

    createParameterTable();
}

QString Logger::readVersion()
{
    return APPVERSION;
}


/*
 * Create table for data storage, each parameter has its own table
 * table name is prefixed with _ to allow number-starting tables
 */

void Logger::createDataTable(QString table)
{
    QSqlQuery query;

    if (query.exec("CREATE TABLE IF NOT EXISTS _" + table + " (key TEXT PRIMARY KEY, timestamp TEXT, value TEXT, annotation TEXT)"))
    {
        qDebug() << "datatable created _" << table;
    }
    else
    {
        qDebug() << "datatable not created _" << table << " : " << query.lastError();
    }
}

/*
 * When parameter is deleted, we need also to drop the datatable connected to it
 */

void Logger::dropDataTable(QString table)
{
    QSqlQuery query;

    if (query.exec("DROP TABLE IF EXISTS _" + table))
    {
        qDebug() << "datatable dropped _" << table;
    }
    else
    {
        qDebug() << "datatable not dropped _" << table << " : " << query.lastError();
    }
}

/*
 * Paramtere table collects parameters to which under data is being logged
 */

void Logger::createParameterTable()
{
    QSqlQuery query;

    if (query.exec("CREATE TABLE IF NOT EXISTS parameters (parameter TEXT, description TEXT, visualize INTEGER, plotcolor TEXT, datatable TEXT PRIMARY KEY, pairedtable TEXT)"))
    {
        qDebug() << "parameter table created";
    }
    else
    {
        qDebug() << "parameter table not created : " << query.lastError();
    }
}

/*
 * Set paired table
 */
void Logger::setPairedTable(QString datatable, QString pairedtable)
{
    QSqlQuery addColQuery;

    if (addColQuery.exec("ALTER TABLE parameters ADD COLUMN pairedtable TEXT"))
        qDebug() << "column pairedtable added succesfully";

    QSqlQuery query = QSqlQuery(QString("UPDATE parameters SET pairedtable='%1' WHERE datatable='%2'").arg(pairedtable).arg(datatable), *db);

    if (query.exec())
    {
        qDebug() << "paired table added " << datatable << " -- " << pairedtable;
    }
    else
    {
        qDebug() << "paired table failed " << datatable << " -- " << pairedtable << " : " << query.lastError();
    }

}

/*
 * Add new data entry to a parameter
 * key = "" to generate new
 */

QString Logger::addData(QString table, QString key, QString value, QString annotation, QString timestamp)
{
    qDebug() << "Adding " << value << " (" << timestamp << ") " << annotation << " to " << table;

    QString objHash = ( (key.length() > 0) ? key : generateHash(value));

    QSqlQuery addColQuery;

    if (addColQuery.exec("ALTER TABLE _" + table + " ADD COLUMN annotation TEXT"))
        qDebug() << "column annotation added succesfully";

    QSqlQuery query = QSqlQuery("INSERT OR REPLACE INTO _" + table + " (key,timestamp,value,annotation) VALUES (?,?,?,?)", *db);

    query.addBindValue(objHash);
    query.addBindValue(timestamp);
    query.addBindValue(value);
    query.addBindValue(annotation);

    if (query.exec())
    {
        qDebug() << "data added " << timestamp << " = " << value << " + " << annotation;
    }
    else
    {
        qDebug() << "failed " << timestamp << " = " << value << " : " << query.lastError();
    }
    return objHash;
}

/*
 * Get all data of one parameter, to raw data show page or for plotting
 */

QVariantList Logger::readData(QString table)
{
    QSqlQuery query = QSqlQuery("SELECT * FROM _" + table + " ORDER BY timestamp ASC", *db);

    QVariantList tmp;
    QVariantMap map;

    if (query.exec())
    {
        map.clear();
        while (query.next())
        {
            map.insert("key", query.record().value("key").toString());
            map.insert("timestamp", query.record().value("timestamp").toString());
            map.insert("value", query.record().value("value").toString());
            map.insert("annotation", query.record().value("annotation").toString());
            tmp.append(map);
        }
    }
    else
    {
        qDebug() << "readParameters failed " << query.lastError();
    }

    return tmp;
}

/*
 * Delete one data entry of a parameter
 */

void Logger::deleteData(QString table, QString key)
{
    QSqlQuery query = QSqlQuery("DELETE FROM _" + table + " WHERE key = ?", *db);

    query.addBindValue(key);

    if (query.exec())
        qDebug() << "Data logged with " << key << " deleted";
    else
        qDebug() << "deleting data failed: " << table << " " << key << " : " << query.lastError();

}

/*
 * Read all parameters (to be shown on mainpage listview
 */

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
            map.insert("plotcolor", query.record().value("plotcolor").toString());
            map.insert("datatable", query.record().value("datatable").toString());
            map.insert("name", query.record().value("parameter").toString());
            map.insert("pairedtable", query.record().value("pairedtable").toString());
            tmp.append(map);
        }
    }
    else
    {
        qDebug() << "readParameters failed " << query.lastError();
    }
    return tmp;
}

/*
 * Generates md5 of some data
 */

QString Logger::generateHash(QString sometext)
{
    int rnd = qrand();

    QString tmp = QString("%1 %2 %3").arg(sometext).arg(rnd).arg(QTime::currentTime().hour());

    return QString(QCryptographicHash::hash((tmp.toUtf8()),QCryptographicHash::Md5).toHex());
}

/*
 * Add created parameter entry to parameter table
 *
 * datatable name is md5 of timestamp + random number
 */

QString Logger::addParameterEntry(QString key, QString parameterName, QString parameterDescription, bool visualize, QColor plotColor, QString pairedtable)
{
    qDebug() << "Adding entry: " << parameterName << " - " << parameterDescription << " color " << plotColor;

    QString objHash = ( (key.length() > 0) ? key : generateHash(parameterName));

    QSqlQuery query = QSqlQuery("INSERT OR REPLACE INTO parameters (parameter,description,visualize,plotcolor,datatable,pairedtable) VALUES (?,?,?,?,?,?)", *db);

    query.addBindValue(parameterName);
    query.addBindValue(parameterDescription);
    query.addBindValue(visualize ? 1:0 ); // store bool as integer
    query.addBindValue(plotColor.name());
    query.addBindValue(objHash);
    query.addBindValue(pairedtable);


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

/*
 * Delete one parameter, deletes also associated datatable
 */

void Logger::deleteParameterEntry(QString parameterName, QString datatable)
{
    QSqlQuery query = QSqlQuery("DELETE FROM parameters WHERE datatable = ?", *db);

    query.addBindValue(datatable);

    if (query.exec())
        qDebug() << "Parameter " << parameterName << " deleted";
    else
        qDebug() << "deleteParameterEntry failed";

    dropDataTable(datatable);
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

/*
 * Export to CSV file
 */

QString Logger::exportToCSV()
{
    qDebug() << "Exporting";

    QLocale loc = QLocale::system(); /* Should return current locale */

    QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';
    qDebug() << "Using" << separator << "as separator";

    QString filename = QString("%1/valuelogger.csv").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    qDebug() << "Output filename is" << filename;

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");

    QVariantList eParameters = readParameters();
    QListIterator<QVariant> i(eParameters);

    while (i.hasNext())
    {
        QVariantMap eParamData = i.next().value<QVariantMap>();

        out << eParamData["name"].toString() << separator << eParamData["description"].toString() << "\n";

        QVariantList eData = readData(eParamData["datatable"].toString());
        QListIterator<QVariant> n(eData);

        while (n.hasNext())
        {
            QVariantMap eDataData = n.next().value<QVariantMap>();

            out << eDataData["timestamp"].toString() << separator << eDataData["value"].toString().replace('.', loc.decimalPoint()) << separator << "\"" << eDataData["annotation"].toString() << "\"\n";
        }
    }
    out.flush();

    file.close();

    return filename;
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


