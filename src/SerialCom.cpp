#include "SerialCom.h"

#include <QByteArray>
#include <QDebug>

#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#define START_CODE  0x02
#define END_CODE    0x03

SerialCom::SerialCom(QObject *parent) :
    QThread(parent)
{
    if (openSerial()) {
        start();
    } else {
        qDebug() << "Error: Unable to open UART serial port.";
    }
}

bool SerialCom::openSerial(){
    mFd = open("/dev/ttyAMA0", O_RDWR | O_NOCTTY | O_NDELAY);

    if (mFd == -1)	{
        return false;
    }

    struct termios options;

    tcgetattr(mFd, &options);

    cfsetispeed(&options, B9600);
    cfsetospeed(&options, B9600);

    options.c_cflag |= (CLOCAL | CREAD);
    options.c_cflag &= ~PARENB;
    options.c_cflag &= ~CSTOPB;
    options.c_cflag &= ~CSIZE;
    options.c_cflag |= CS8;
    options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG) ;
    options.c_oflag &= ~OPOST ;

    tcsetattr(mFd, TCSANOW, &options);
    tcflush(mFd, TCIOFLUSH);

    return true;
}

void SerialCom::run() {
    sleep(1);
    qDebug() << "RFID read thread started.";

    tcflush(mFd, TCIOFLUSH);

    QByteArray cardID;
    QString rfid;
    int dataRead = 0;
    unsigned char serialByte = 0;

    while (1) {
        dataRead = read(mFd, &serialByte, 1);
        if (dataRead) {
            switch (serialByte) {
                case START_CODE:
                    cardID.clear();
                    rfid.clear();
                    break;
                case END_CODE:
                    tcflush(mFd, TCIOFLUSH);

                    cardID.remove(0,4);
                    cardID.remove(6,2);

                    rfid = QString::number(cardID.toInt(Q_NULLPTR, 16),10);

                    emit rfidReceived(rfid);

                    sleep(3);
                    break;
                default:
                    cardID.append(serialByte);
                    break;
            }
        }
    }
}
