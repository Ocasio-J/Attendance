#include "Timekeeping.h"

#include <QDebug>

#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>

// DS1307 DATASHEET: http://datasheets.maximintegrated.com/en/ds/DS1307.pdf
// Main Reference: https://www.kernel.org/doc/Documentation/i2c/dev-interface

#define DS1307_ADDRESS		0x68  // Defined on the datasheet.

/* According to the datasheet, the register pointer automatically
 * increments after every I2C byte transfer. So we only need to specify
 * the address of the register we want to start with.
 * Starting address at the seconds register is the logical choice.
*/
#define DS1307_STARTING_ADDRESS			0x00

TimeKeeping::TimeKeeping(QObject *parent) :
    QObject(parent)
{
    mIsI2COpen = openI2C();

    mIsInternetAvailable = isInternetAvailable();
    if (mIsI2COpen && mIsInternetAvailable) {
        setRTCTime();
    }
}

/* A very simple but discouraged way to check for internet access.
 * Good enough for my purposes here.
 * System() simply runs the ping command in the shell and returns
 * whatever ping returns. Ping returns 0 when all is good.
 * See 'man ping' and 'man system'
 * 8.8.8.8 is Google's DNS service which is highly unlikely to ever go offline.
*/
bool TimeKeeping::isInternetAvailable() {
    return system("ping -w 1 -c 1 8.8.8.8 > /dev/null") == 0;
}

bool TimeKeeping::openI2C() {
    char i2cAdapter[15] = "/dev/i2c-1";
    mFd = open(i2cAdapter, O_RDWR);

    if (mFd < 0 || ioctl(mFd, I2C_SLAVE, DS1307_ADDRESS) < 0) {
        qDebug() << "Error: Can't open i2c adapter";
        return false;
    }

    return true;
}

void TimeKeeping::setRTCTime() {
    const QDateTime dateTime = readSystemTime();
    const QDate &date = dateTime.date();
    const QTime &time = dateTime.time();

    unsigned char buffer[10];
    buffer[0] = DS1307_STARTING_ADDRESS;            // Set Starting Register Address. See datasheet Figure 4.
    buffer[1] = decToCodedBin(time.second());	    // Set Seconds (0-59)
    buffer[2] = decToCodedBin(time.minute());	    // Set Minutes (0-59)
    buffer[3] = decToCodedBin(time.hour());         // Set Hours, 24 hour mode
    buffer[4] = decToCodedBin(date.dayOfWeek());    // Set Day (1 is Monday, 7 is Sunday)
    buffer[5] = decToCodedBin(date.day());		    // Set Date (1-31)
    buffer[6] = decToCodedBin(date.month());	    // Set Month (1-12)
    buffer[7] = decToCodedBin(date.year() % 100);   // Set Year (0-99)

    /*
     * Notice first 8 elements of the buffer array will contain the data we want to write.
     * 8 is the number of bytes we want to write to DS1307. Linux iterates through the array
     * and writes to the DS1307 automatically using the write() function.
    */
    if (write(mFd, buffer, 8) != 8) {
        qDebug() << "Error: RTC write buffer byte count mismatch.";
    }
}

unsigned char TimeKeeping::decToCodedBin(int decimal) {

    unsigned char tensDigit = decimal / 10;
    unsigned char onesDigit = decimal % 10;
    unsigned char codedBin = (tensDigit << 4) | onesDigit;

    return codedBin;
}

int TimeKeeping::codedBinToDec(int codedBin) {
    unsigned char tensValue = (codedBin >> 4) * 10;
    unsigned char onesValue = (codedBin & 0x0F);
    unsigned char decimal = tensValue + onesValue;

    return decimal;
}

QDateTime TimeKeeping::getDateTime() {

    return (mIsInternetAvailable || ! mIsI2COpen) ? readSystemTime() : readRTCTime();
}

QDateTime TimeKeeping::readSystemTime() {
    return QDateTime::currentDateTime();
}

QDateTime TimeKeeping::readRTCTime() {

    QDateTime dateTime;

    unsigned char buffer[10];
    buffer[0] = DS1307_STARTING_ADDRESS;	// Set starting register address.

    /* To read from DS1307, we need to write the register pointer again to determine where
     * we should start reading from. So we write again, then read. Figure 6 on datasheet.
    */
    if (write(mFd, buffer, 1) != 1) {
        qDebug()<<"Error: Couldn't set the register pointer.";
    } else if (read(mFd, buffer, 7) != 7) { // Only need 7 bytes on read.
        qDebug()<<"Error: Couldn't read from I2C slave.";
    } else {
        // At this point elements 0-6 of the buffer array contain the data read from DS1307
        int year = codedBinToDec(buffer[6]);        // Year
        int month = codedBinToDec(buffer[5]);       // Month
        int monthDay = codedBinToDec(buffer[4]);    // Month Day
      //int day = codedBinToDec(buffer[3]);         // Day (not used for this application)
        int hours = codedBinToDec(buffer[2]);       // Hour
        int minutes = codedBinToDec(buffer[1]);     // Minutes
        int seconds = codedBinToDec(buffer[0]);     // Seconds

        QDate date(year, month, monthDay);
        QTime time(hours, minutes, seconds, 0);

        dateTime.setDate(date);
        dateTime.setTime(time);
    }

    return dateTime;
}

