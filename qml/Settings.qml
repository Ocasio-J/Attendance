import QtQuick 2.5

Item {
    id: settings

    ListView {
        id: listview
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: bottomBar.top; topMargin: 5; bottomMargin: 5 }
        spacing: 10
        clip: true
        model: RosterManager.rosterModel()
        delegate: Rectangle {
            id: cell
            anchors { left: parent.left; right: parent.right; leftMargin: 20; rightMargin: 20 }
            height: 50
            color: "#50000000"
            border { color: "white" }
            radius: 10

            Text {
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 20 }
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font { pointSize: 15 }
                text: firstName + ' ' + lastName
            }

            Button {
                id: modifyButton
                anchors { verticalCenter: parent.verticalCenter; right: deleteButton.left; rightMargin: 20 }
                height: 25
                width: 100
                buttonText: "Modify"
                onClicked:{
                    RosterManager.setCurrentUser(rfid)
                    var page = (groupName.toLowerCase() === "users") ? pages.rosterUpdateUser : pages.rosterUpdateAdmin
                    mainWindow.changePage(page)
                }
            }

            Button {
                id: deleteButton
                anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 20 }
                height: 25
                width: 100
                color: focus ? "firebrick": "tomato"
                buttonText: "Delete"
                onClicked: {
                    dialogBox.rfidToDelete = rfid
                    dialogBox.state = "deleteUser"
                }
            }
        }

        section.property: "groupName"
        section.criteria: ViewSection.FullString
        section.delegate: Item {
            id: headerCell

            readonly property bool isAdminSection: section.toLowerCase() === "admin"
            readonly property string sectionName: isAdminSection ? "Administrators" : "Users"

            anchors { left: parent.left; right: parent.right; leftMargin: 20; rightMargin: 20 }
            height: 50

            Text {
                id: sectionHeader
                anchors { verticalCenter: parent.verticalCenter; left: parent.left }
                width: 200
                verticalAlignment: Text.AlignVCenter
                font { pointSize: 15; bold: true }
                color: "white"
                text: headerCell.sectionName
            }

            Button {
                id: addButton
                anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 20 }
                height: 25
                width: 50
                radius: 10
                color: focus ? "gray": "seagreen"
                buttonText: "+"
                onClicked: {
                    var page = headerCell.isAdminSection ? pages.rosterAddAdmin : pages.rosterAddUser
                    mainWindow.changePage(page)
                }
            }
        }
    }

    DialogBox {
        id: dialogBox

        property string rfidToDelete: ""

        anchors { fill: parent }
        z: 100
        visible: state.length !== 0
        rightButtonText: "OK"
        onLeftButtonClicked: state = ""

        states: [
            State {
                name: "deleteUser"
                PropertyChanges {
                    target: dialogBox
                    text: "This will remove the user and delete\n all of their data. Delete anyways?"
                    onRightButtonClicked: {
                        RosterManager.deleteUser(rfidToDelete)
                        state = ""
                    }
                }
            },
            State {
                name: "quitApp"
                PropertyChanges {
                    target: dialogBox
                    text: "Quit the application and \ngo to the desktop?"
                    onRightButtonClicked: {
                        Qt.quit()
                        state = ""
                    }
                }
            },
            State {
                name: "shutdown"
                PropertyChanges {
                    target: dialogBox
                    text: "Shutdown the system?"
                    onRightButtonClicked: {
                        GPIO.shutdown()
                        state = ""
                    }
                }
            }
        ]
    }

    Rectangle {
        id: bottomBar
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 60
        color:"#50000000"

        Image {
            id: backButton
            anchors { verticalCenter: parent.verticalCenter; left: parent.left; margins: 20 }
            source: mouseArea.containsMouse ? "../assets/images/backArrowFilled.png" : "../assets/images/backArrow.png"

            MouseArea {
                id: mouseArea
                anchors { fill: parent }
                hoverEnabled: true
                onClicked: mainWindow.changePage(mainWindow.previousPage)
            }
        }

        Button {
            id: exitAppButton
            anchors { verticalCenter: parent.verticalCenter; right: shutdownButton.left; margins: 20 }
            height: 40
            width: 200
            radius: 10
            color: focus ? "gray" : "firebrick"
            buttonText: "Exit to Desktop"
            onClicked: dialogBox.state = "quitApp"
        }

        Button {
            id: shutdownButton
            width: 40
            height: width
            anchors { verticalCenter: parent.verticalCenter; right: parent.right; margins: 20 }
            radius: 10
            color: focus ? "gray" : "firebrick"
            onClicked: dialogBox.state = "shutdown"

            Image {
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                source: "../assets/images/shutoff.png"
            }
        }
    }
}
