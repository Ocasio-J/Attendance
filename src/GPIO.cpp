#include "GPIO.h"

#define INPUT_MODE 0
#define LOW 0
#define RESISTOR_OFF 0
#define OUTPUT_MODE 1
#define HIGH 1
#define RESISTOR_PULL_DOWN
#define RESISTOR_PULL_UP 2
#define BATTERY_PIN 26
#define BUTTON_PIN 27

GPIO::GPIO(QObject *parent):
    QObject(parent),
    m_batteryLow(false),
    m_clockInButtonEnabled(false)
{
    wiringPiSetup();

    // WiringPi pinout: http://pinout.xyz/pinout/wiringpi_gpio_pinout
    pinMode(BATTERY_PIN, INPUT_MODE);
    pinMode(BUTTON_PIN, INPUT_MODE);
    pullUpDnControl(BUTTON_PIN, RESISTOR_PULL_UP);

    startTimer(200);
}

void GPIO::timerEvent(QTimerEvent *event)
{
    Q_UNUSED(event)

    // Check battery level.
    if (read(BATTERY_PIN)){
        setBatteryLow(true);
        system("shutdown +1");
    } else {
        setBatteryLow(false);
        system("shutdown -c");
    }

    // Check button pressed.
    if (m_clockInButtonEnabled && !digitalRead(BUTTON_PIN)) {
        Q_EMIT clockInButtonPressed();
    }
}

void GPIO::setclockInButtonEnabled(bool clockInButtonEnabled)
{
    if (m_clockInButtonEnabled == clockInButtonEnabled) {
        return;
    }

    m_clockInButtonEnabled = clockInButtonEnabled;
    emit clockInButtonEnabledChanged();
}

void GPIO::setBatteryLow(const bool &batteryLow)
{
    if (m_batteryLow != batteryLow) {
        m_batteryLow = batteryLow;
        emit batteryLowChanged();
    }
}

int GPIO::read(int pin){
    return digitalRead (pin);
}

void GPIO::shutdown(){
    system("shutdown +0");
}
