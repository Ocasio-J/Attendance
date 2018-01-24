#ifndef ROSTERSQLMODEL_H
#define ROSTERSQLMODEL_H

#include <QSqlQueryModel>
#include <QSqlRecord>
#include <QDebug>
#include <QSqlQuery>

class RosterSqlModel: public QSqlQueryModel {
    Q_OBJECT

public:
    explicit RosterSqlModel(QObject* parent = 0) :
        QSqlQueryModel(parent)
    {
        mRoleNames[RfidRole] = QByteArray("rfid");
        mRoleNames[FirstNameRole] = QByteArray("firstName");
        mRoleNames[LastNameRole] = QByteArray("lastName");
        mRoleNames[GroupNameRole] = QByteArray("groupName");
        refresh();
    }

    QVariant data(const QModelIndex& index, int role) const {
        if(!index.isValid() || role < Qt::UserRole) {
            return QVariant();
        }

        QSqlQuery q = query();
        q.seek(index.row());

        return q.value(role - Qt::UserRole);
    }

    QHash<int, QByteArray> roleNames() const { return mRoleNames; }

    void refresh() { setQuery(m_queryString); }

private:
    enum roles {
        RfidRole = Qt::UserRole,
        FirstNameRole,
        LastNameRole,
        GroupNameRole
    };

    QHash<int, QByteArray> mRoleNames;
    const QString m_queryString = "SELECT rfid, firstName, lastName, groupName FROM roster ORDER BY groupName, firstName COLLATE NOCASE ASC";
};

#endif // ROSTERSQLMODEL_H
