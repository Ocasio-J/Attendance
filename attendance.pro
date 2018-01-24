TEMPLATE = app

QT += qml quick sql multimedia

CONFIG += c++11

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

LIBS += -L/lib/x86_64-linux-gnu/ -lglib-2.0

HEADERS += \
    src/GPIO.h \
    src/SerialCom.h \
    src/RosterManager.h \
    src/RosterSqlModel.h \
    src/Timekeeping.h

SOURCES += \
    src/GPIO.cpp \
    src/main.cpp \
    src/SerialCom.cpp \
    src/RosterManager.cpp \
    src/Timekeeping.cpp


