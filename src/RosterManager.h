#ifndef ROSTERMANAGER_H
#define ROSTERMANAGER_H

#include "RosterSqlModel.h"

#include <QObject>
#include <QString>

class User : public QObject {
    Q_OBJECT
public:
    void setAttributes(const QString &rfid, const QString &firstName, const QString &lastName, const bool isAdmin) {
        mRfid = rfid;
        mFirstname = firstName;
        mLastname = lastName;
        mIsAdmin = isAdmin;
    }

public:
    void clear() {
        mRfid.clear();
        mFirstname.clear();
        mLastname.clear();
        mIsAdmin = false;
    }

public slots:
    QString rfid() { return mRfid; }
    QString firstName() { return mFirstname; }
    QString lastName() { return mLastname; }
    bool isAdmin() { return mIsAdmin; }
    bool isValid() { return ! mRfid.isEmpty() && ! mFirstname.isEmpty() && ! mLastname.isEmpty(); }

private:
    QString mRfid;
    QString mFirstname;
    QString mLastname;
    bool mIsAdmin;
};

class RosterManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(User* currentUser READ currentUser NOTIFY currentUserChanged)
    Q_PROPERTY(QString homeDirectory READ homeDirectory CONSTANT)
    Q_PROPERTY(QString photosDirectory READ photosDirectory CONSTANT)
    Q_PROPERTY(QString audioDirectory READ audioDirectory CONSTANT)

public:
    explicit RosterManager(QObject *parent = 0);

    void exportCSV();

    User* currentUser() { return &mCurrentUser; }
    QString homeDirectory() { return HOMEDIR; }
    QString photosDirectory() { return PHOTOSDIR; }
    QString audioDirectory() { return AUDIODIR; }

public slots:
    void setCurrentUser(const QString &rfid = QString());
    int addToRoster(const QString &rfid, const QString &firstName, const QString &lastName, const bool isAdmin = false);
    int updateRoster(const QString &rfid, const QString &newRFID, const QString &newFirstName, const QString &newLastName, const bool &isAdmin);
    void deleteUser(const QString &rfid);
    bool adminsExist();
    QObject* rosterModel() { return m_rosterModel; }

signals:
    void currentUserChanged();
    void rfidAccepted();

private slots:
    void recordClockIn();
    void onRFIDReceived(const QString &rfid);

private:
    const QString HOMEDIR = "/home/pi/attendance/";
    const QString DBPATH = HOMEDIR + "attendance.db";
    const QString PHOTOSDIR = HOMEDIR + "photos/";
    const QString AUDIODIR = HOMEDIR + "audio/";

    User mCurrentUser;
    RosterSqlModel *m_rosterModel;
};

#endif // ROSTERMANAGER_H
