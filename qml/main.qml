import QtQuick 2.5
import QtQuick.Window 2.2

Window {
    id: mainWindow

    readonly property bool isSetupDone: RosterManager.adminsExist()

    property int activePage: pages.splashScreen
    property int previousPage: activePage

    QtObject {
        id: pages
        readonly property int splashScreen:         0
        readonly property int rosterAddAdmin:       1
        readonly property int rosterAddUser:        2
        readonly property int rosterUpdateAdmin:    3
        readonly property int rosterUpdateUser:     3
        readonly property int standby:              4
        readonly property int clockIn:              5
        readonly property int settings:             6
    }

    function changePage(page) {
        if (page !== mainWindow.activePage) {
            mainWindow.previousPage = mainWindow.activePage
            mainWindow.activePage = page
        }
    }

    Component.onCompleted: {
        Qt.application.name = "Attendance"
        Qt.application.organization = "Coastal Connections"
    }

    visible: true
    width: 800
    height: 400

    Image {
        id: backgroundImage
        anchors { fill: parent }
        source: (mainWindow.activePage !== pages.splashScreen) ? "../assets/images/purpleGradient.jpg" : ""
    }

    Sounds { id: sounds }

    Loader { id: pageLoader; anchors.fill: parent }

    // Page Control
    StateGroup {
        states: [
            State {
                name: "splashScreen"
                when: mainWindow.activePage === pages.splashScreen
                PropertyChanges { target: pageLoader; source: "SplashScreen.qml" }
            },
            State {
                name: "rosterInput"
                when:    mainWindow.activePage === pages.rosterAddAdmin
                      || mainWindow.activePage === pages.rosterAddUser
                      || mainWindow.activePage === pages.rosterUpdateAdmin
                      || mainWindow.activePage === pages.rosterUpdateUser
                PropertyChanges { target: pageLoader; source: "RosterInput.qml" }
            },
            State {
                name: "standby"
                when: mainWindow.activePage === pages.standby
                PropertyChanges { target: pageLoader; source: "Standby.qml" }
                StateChangeScript { script: RosterManager.setCurrentUser() }
            },
            State {
                name: "settings"
                when: mainWindow.activePage === pages.settings
                PropertyChanges { target: pageLoader; source: "Settings.qml" }
            },
            State {
                name: "clockIn"
                when: mainWindow.activePage === pages.clockIn
                PropertyChanges { target: pageLoader; source: "ClockIn.qml" }
            }
        ]
    }
}
