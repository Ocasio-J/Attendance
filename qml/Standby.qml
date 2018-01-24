import QtQuick 2.5

Item {

    property date currentDate: TimeKeeping.getDateTime()

    Connections {
        target: RosterManager
        onRfidAccepted: {
            var page = 0
            var isAdmin = RosterManager.currentUser.isAdmin()

            if (settingsLogin.active) {
                if (isAdmin) {
                    page = pages.settings
                }
            } else if ( ! isAdmin) {
                page = pages.clockIn
            }

            if (page > 0) {
                sounds.playGoodRFID()
                mainWindow.changePage(page)
            } else {
                sounds.playBadRFID()
                RosterManager.setCurrentUser("")
            }
        }
    }

    Timer {
        id: clockTimer
        interval: 1000; running: true; repeat: true;
        onTriggered: currentDate = TimeKeeping.getDateTime()
    }

    Text {
        id: timeLabel
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -20 }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font { pointSize: 80 }
        color: "white"
        text: currentDate.toLocaleTimeString(Qt.locale(), "h:mm AP")
    }

    Text {
        id: dateLabel
        anchors { horizontalCenter: parent.horizontalCenter; top: timeLabel.baseline; topMargin: 5 }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font { pointSize: 40 }
        color: "white"
        text: currentDate.toLocaleDateString(Qt.locale(), "ddd, MMM d, yyyy")
    }

    Text{
        id: userAlertLabel
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 35 }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font { pointSize: 15 }
        text: GPIO.batteryLow ? "Plug in the charger.\nLow Battery. System will shutdown soon" : ""
    }

    Image {
        id: settingsButton
        width: 50
        height: width
        anchors { bottom: parent.bottom; bottomMargin: 15; left: parent.left; leftMargin: 15 }
        source: mouseArea.containsMouse ? "../assets/images/settingsFilled.png" : "../assets/images/settings.png"

        MouseArea {
            id: mouseArea
            anchors { fill: parent }
            hoverEnabled: true
            onClicked: settingsLogin.active = true
        }
    }

    Loader {
        id: settingsLogin
        anchors { fill: parent }
        active: false
        sourceComponent: DialogBox {            
            text: "<b>Settings Access</b><br>Scan Administrator RFID Card"
            onLeftButtonClicked: settingsLogin.active = false
        }
    }
}
