import QtQuick 2.5

Rectangle {
    id: splashScreen
    color: "white"

    Image {
        id: splashImage
        width: 532
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        fillMode: Image.PreserveAspectFit
        source: "../assets/images/splashImage.png"

        SequentialAnimation on opacity {
            NumberAnimation {from: 0; to: 1; duration: 3000 }
            PauseAnimation { duration: 1000 }

            onStopped: {
                if(mainWindow.isSetupDone) {
                    mainWindow.changePage(pages.standby)
                } else {
                    mainWindow.changePage(pages.rosterAddAdmin)
                }
            }
        }
    }
}
