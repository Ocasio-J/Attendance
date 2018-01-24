#ifndef TIMEKEEPING_H
#define TIMEKEEPING_H

#include <QObject>
#include <QDateTime>

class TimeKeeping : public QObject
{
    Q_OBJECT
public:
    explicit TimeKeeping(QObject *parent = 0);

public slots:
    QDateTime getDateTime();

private:
    int mFd;
    bool mIsInternetAvailable;
    bool mIsI2COpen;

    bool openI2C();
    bool isInternetAvailable();
    void setRTCTime();
    int codedBinToDec(int codedBin);
    unsigned char decToCodedBin(int decimal);
    QDateTime readRTCTime();
    QDateTime readSystemTime();
};

#endif // TIMEKEEPING_H
