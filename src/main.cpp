#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>

#include "RosterSqlModel.h"
#include "SerialCom.h"
#include "RosterManager.h"
#include "GPIO.h"
#include "Timekeeping.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    RosterManager *rosterManager = new RosterManager(&app);
    SerialCom *serialCom = new SerialCom(&app);
    GPIO *gpio = new GPIO(&app);
    TimeKeeping *timeKeeping = new TimeKeeping(&app);

    QObject::connect(serialCom, SIGNAL(rfidReceived(QString)), rosterManager, SLOT(onRFIDReceived(QString)));
    QObject::connect(gpio, SIGNAL(clockInButtonPressed()), rosterManager, SLOT(recordClockIn()));
    
    QFile::copy(":/assets/sounds/RFIDGood.wav","/var/opt/RFIDGood.wav");
    QFile::copy(":/assets/sounds/RFIDBad.wav","/var/opt/RFIDBad.wav");
    QFile::copy(":/assets/sounds/clockedIn.wav","/var/opt/clockedIn.wav");

    QQmlApplicationEngine engine;
    engine.rootContext() -> setContextProperty("RosterManager", rosterManager);
    engine.rootContext() -> setContextProperty("GPIO", gpio);
    engine.rootContext() -> setContextProperty("TimeKeeping", timeKeeping);
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
