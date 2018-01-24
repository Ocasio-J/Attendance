import QtQuick 2.5
import QtGraphicalEffects 1.0

Item {
    id: clockIn

    property bool toggleIndicatorImage: false

    Image {
        id: userImage
        width: 250
        height: width
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        fillMode: Image.PreserveAspectFit
        visible: false
        source: "file:///" + RosterManager.photosDirectory + RosterManager.currentUser.rfid()
        onStatusChanged: {
            if (userImage.status === Image.Error) {
                source = "../assets/images/defaultUserImage.png"
            }
        }
    }

    OpacityMask {
        id: opacityMask
        anchors { fill: userImage }
        source: userImage
        maskSource: mask

        Rectangle {
            id: mask
            width: 250
            height: 250
            visible: false
            radius: 30
        }
    }

    Text {
        id: nameLabel        
        anchors { horizontalCenter: parent.horizontalCenter; top: userImage.bottom; topMargin: 10 }
        color: "white"
        font { pointSize: 20 }
        text: RosterManager.currentUser.firstName() + " " + RosterManager.currentUser.lastName()
    }

    Image {
        id: indicator
        width: 75
        height: width
        anchors { right: parent.right; bottom: parent.bottom; rightMargin: 10; bottomMargin: 10 }
        source: toggleIndicatorImage ? "../assets/images/buttonIndicatorOn.png" : "../assets/images/buttonIndicatorOff.png"
    }

    SequentialAnimation {
        id: imageAnimation
        NumberAnimation { target: userImage; properties: "width"; to: 260; duration: 50 }
        NumberAnimation { target: userImage; properties: "width"; to: 0; duration: 700 }
        PropertyAction { target: userImage; property: "source"; value: "../assets/images/clockedIn.png" }
        NumberAnimation { target: userImage; properties: "width"; to: 250; duration: 700 }
        PauseAnimation { duration: 3000 }
        ScriptAction { script: mainWindow.changePage(mainWindow.previousPage) }
    }

    Timer {
        id: indicatorTimer
        interval: 1000; running: true; repeat: true;
        onTriggered: toggleIndicatorImage = !toggleIndicatorImage
    }

    Connections {
        target: GPIO
        enabled: GPIO.clockInButtonEnabled

        onClockInButtonPressed: {
            GPIO.clockInButtonEnabled = false
            sounds.playClockedIn()
            indicator.visible = false
            imageAnimation.start()
        }
    }

    Component.onCompleted: {
        GPIO.clockInButtonEnabled = true
        sounds.playUserGreeting(RosterManager.currentUser.rfid())
    }
}
