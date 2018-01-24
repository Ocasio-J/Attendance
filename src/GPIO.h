#ifndef GPIO_H
#define GPIO_H

#include <QObject>
#include "wiringPi.h"

class GPIO :public QObject {
    Q_OBJECT
    Q_PROPERTY(bool batteryLow READ batteryLow NOTIFY batteryLowChanged)
    Q_PROPERTY(bool clockInButtonEnabled READ clockInButtonEnabled WRITE setclockInButtonEnabled NOTIFY clockInButtonEnabledChanged)

public:
    explicit GPIO(QObject *parent = 0);

    bool batteryLow() const { return m_batteryLow; }
    bool clockInButtonEnabled() const { return m_clockInButtonEnabled; }

public slots:
    int read(int pin);
    void shutdown();

    void setclockInButtonEnabled(bool clockInButtonEnabled);

signals:
    void clockInButtonPressed();
    void batteryLowChanged();
    void clockInButtonEnabledChanged();

protected:
    void timerEvent(QTimerEvent *event);

private:
    bool m_batteryLow;
    bool m_clockInButtonEnabled;

    void setBatteryLow(const bool &batteryLow);
};

#endif // GPIO_H
