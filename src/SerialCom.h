#ifndef SERIALCOM_H
#define SERIALCOM_H

#include <QThread>
#include <QString>

class SerialCom : public QThread {
    Q_OBJECT

public:
    explicit SerialCom(QObject *parent = 0);

protected:
    void run();

signals:
    void rfidReceived(QString rfid);

private:
    int mFd;

    bool openSerial();
};

#endif // SERIALCOM_H
