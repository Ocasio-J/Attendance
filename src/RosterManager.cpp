#include "RosterManager.h"

#include <QDateTime>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QDebug>

#include <unistd.h>

RosterManager::RosterManager(QObject *parent) :
    QObject(parent)
{        
    for (const QString &dirName : { HOMEDIR, PHOTOSDIR, AUDIODIR }) {

        QDir dir(dirName);
        if ( ! dir.exists()) {
            dir.mkpath(dirName);

        /*
         * Since program is running as root (required for wiringPi GPIO), all directories will have root ownership.
         * Not ideal since the user using ftp needs to write to these directories.
         * Better to change directory ownership than to give user ftp root access.
         * chown() 2nd and 3rd parameters are the user id and group id. Found by running 'id' in terminal.
         */
            int owner = chown(qPrintable(dirName), 1000, 1000);
            if (owner == -1) {
                qDebug() << "Error: Folder permission/owner not changed";
            }
        }
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(DBPATH);

    if ( ! db.open()) {
        qDebug() << "Error: Database connection failed";
        return;
    }

    QSqlQuery query;
    const QString qStr1 = "CREATE TABLE IF NOT EXISTS "
                    "roster (rfid INTEGER PRIMARY KEY, firstName TEXT, lastName TEXT,groupName TEXT)";
    const QString qStr2 = "CREATE TABLE IF NOT EXISTS "
                    "attendance (rfid INTEGER, firstName TEXT, lastName TEXT, datetime TEXT)";

    if ( ! query.exec(qStr1) || ! query.exec(qStr2)) {
        qDebug() << "Error: Table could not be created " << query.lastError();
    }

    m_rosterModel = new RosterSqlModel(this);
}

// Add user to roster table.
int RosterManager::addToRoster(const QString &rfid, const QString &firstName, const QString &lastName, const bool asAdmin) {
    QSqlQuery query;
    const QString qStr = QString("INSERT INTO roster VALUES (%1, '%2', '%3', '%4')").arg(rfid, firstName, lastName, asAdmin ? "admin" : "user");

    if ( ! query.exec(qStr)) {
        qDebug() << "Error: Adding person to roster: "<< query.lastError();
        if (query.lastError().number() == 19) {
            // Duplicate Rfid
            return -1;
        }
        return 0;
    }

    m_rosterModel->refresh();
    return 1;
}

int RosterManager::updateRoster(const QString &rfid, const QString &newRFID, const QString &newFirstName, const QString &newLastName, const bool &isAdmin){
    QSqlQuery query;
    const QString qStr1 = QString("UPDATE "
                                      "roster "
                                  "SET "
                                      "rfid = %1, "
                                      "firstName = '%2', "
                                      "lastName = '%3' "
                                  "WHERE rfid = %4").arg(newRFID, newFirstName, newLastName, rfid);

    const QString qStr2 = QString("UPDATE "
                                      "attendance "
                                  "SET "
                                      "rfid = %1, "
                                      "firstName = '%2', "
                                      "lastName = '%3' "
                                  "WHERE rfid = %4").arg(newRFID, newFirstName, newLastName, rfid);

    if ( ! query.exec(qStr1) || ! query.exec(qStr2)) {
        qDebug() << "Error: Updating user "<< query.lastError();
        if (query.lastError().number() == 19) {
            // Duplicate Rfid
            return -1;
        }
        return 0;
    }

    // Update user photo filename.
    if ( ! isAdmin) {
        QFile::rename(PHOTOSDIR + rfid, PHOTOSDIR + newRFID);
        QFile::rename(AUDIODIR + rfid, AUDIODIR + newRFID);
    }

    m_rosterModel->refresh();

    return 1;
}

void RosterManager::onRFIDReceived(const QString &rfid) {

    setCurrentUser(rfid);

    if (mCurrentUser.isValid()) {
        emit rfidAccepted();
    }
}

void RosterManager::setCurrentUser(const QString &rfid) {
    if (mCurrentUser.rfid() == rfid) {
        return;
    }

    if ( ! rfid.isEmpty()) {

        QSqlQuery query;
        const QString qStr = QString("SELECT firstName, lastName, groupName FROM roster WHERE rfid = %1").arg(rfid);

        if ( ! query.exec(qStr) || ! query.first()) {
            qDebug() << "Error: Cannot get user's name."<< query.lastError();
            mCurrentUser.clear();
            return;
        }

        const QString firstName = query.value(0).toString();
        const QString lastName = query.value(1).toString();
        const bool isAdmin = query.value(2).toString() == "admin";

        mCurrentUser.setAttributes(rfid, firstName, lastName, isAdmin);
    } else {
        mCurrentUser.clear();
    }

    Q_EMIT currentUserChanged();
}

void RosterManager::recordClockIn() {
    if (mCurrentUser.isAdmin() || ! mCurrentUser.isValid()) {
        return;
    }

    QSqlQuery query;
    const QString qStr = QString("INSERT INTO attendance VALUES (%1, '%2', '%3', '%4')")
                                .arg(mCurrentUser.rfid(),
                                     mCurrentUser.firstName(),
                                     mCurrentUser.lastName(),
                                     QDateTime::currentDateTime().toString()
                                    );

    if ( ! query.exec(qStr)) {
        qDebug() << "Error: Recording clock-in "<< query.lastError() << query.lastQuery();
        return;
    }

    exportCSV();
}

// Deletes user from roster table and deletes the user's log table.
void RosterManager::deleteUser(const QString &rfid) {
    QSqlQuery query;
    QString qStr = QString ("DELETE FROM roster WHERE rfid = '%1'").arg(rfid);

    if( ! query.exec(qStr)) {
        qDebug() << "Error: Deleting user from roster table:" << query.lastError() << query.lastQuery();
        return;
    }

    qStr = QString ("DELETE FROM attendance WHERE rfid = '%1'").arg(rfid);

    if( ! query.exec(qStr)) {
        qDebug() << "Error: Deleting user from attendance table:" << query.lastError() << query.lastQuery();
    }

    // Delete user photo
    QFile::remove(PHOTOSDIR + rfid);
    QFile::remove(AUDIODIR + rfid);
    m_rosterModel->refresh();
}

void RosterManager::exportCSV() {

    const QString qStr = QString ("SELECT * FROM attendance");

    QSqlQuery query;
    if ( ! query.exec(qStr)) {
        qDebug() << "Error: Could not export CSV file" << query.lastError();
    }

    QFile file(HOMEDIR + "attendance.csv");
    if ( ! file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "Error: Failed to open CSV file.";
        return;
    }

    QTextStream out(&file);

    QString csv = "RFID,FIRST NAME,LAST NAME,DATETIME";
    while (query.next()) {
        csv.append(QChar::LineFeed);
        QSqlRecord record = query.record();
        for (int i = 0; ! record.value(i).isNull(); ++i) {
            csv.append(query.value(i).toString());
            csv.append(",");
        }

        out << csv;

        csv.clear();
    }
}

bool RosterManager::adminsExist()
{
    QSqlQuery query;
    QString qStr = QString ("SELECT count(*) FROM roster WHERE groupName = 'admin'");

    if( ! query.exec(qStr) || ! query.first()) {
        return false;
    }

    return query.value(0).toInt() > 0;
}
