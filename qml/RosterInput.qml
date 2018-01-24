import QtQuick 2.5

Item {
    id: rosterInput

    readonly property bool isAdmin: (mainWindow.activePage === pages.rosterAddAdmin)
                                     || (mainWindow.activePage === pages.rosterUpdateAdmin)
    readonly property bool updateMode: (mainWindow.activePage === pages.rosterUpdateAdmin)
                                       || (mainWindow.activePage === pages.rosterUpdateUser)

    property alias firstName: firstNameTextInput.text
    property alias lastName: lastNameTextInput.text
    property alias rfid: rfidTextInput.text

    function recordRoster() {
        var returnCode = 0
        prompt.text = ""

        if (updateMode) {
            returnCode = RosterManager.updateRoster(RosterManager.currentUser.rfid(), rfidTextInput.text, firstNameTextInput.text, lastNameTextInput.text, isAdmin)
        } else {
            returnCode = RosterManager.addToRoster(rfidTextInput.text, firstNameTextInput.text, lastNameTextInput.text, isAdmin)
        }

        if (returnCode === 1) {
            firstNameTextInput.text = ""
            lastNameTextInput.text = ""
            firstNameTextInput.forceActiveFocus()
        } else if (returnCode === -1){
            prompt.text = "Card ID is assigned to another person. Scan another card."
        } else {
            prompt.text = "A database error has occured."
        }

        rfidTextInput.text = "";

        return returnCode
    }

    Component.onCompleted: firstNameTextInput.forceActiveFocus()

    states: [
        State {
            name: "addAdmin"
            when: isAdmin && !updateMode
            PropertyChanges { target: header; text: "Add Administrators" }
            PropertyChanges {
                target: rightButton
                onClicked: {
                    if (recordRoster() === 1) {
                        if (mainWindow.previousPage === pages.splashScreen) {
                            mainWindow.changePage(pages.rosterAddUser)
                        } else {
                            mainWindow.changePage(mainWindow.previousPage)
                        }
                    }
                }
            }
        },
        State {
            name: "addUser"
            when: !isAdmin && !updateMode
            PropertyChanges { target: header; text: "Add Users" }
            PropertyChanges {
                target: rightButton
                onClicked: {
                    if (recordRoster() === 1) {
                        if (mainWindow.previousPage === pages.rosterAddAdmin) {
                            mainWindow.changePage(pages.standby)
                        } else {
                            mainWindow.changePage(mainWindow.previousPage)
                        }
                    }
                }
            }
        },
        State {
            name: "update"
            when: updateMode
            PropertyChanges { target: header; text: "Update " + (isAdmin ? "Administrator" : "User") }
            PropertyChanges { target: rfidTextInput; text: RosterManager.currentUser.rfid() }
            PropertyChanges { target: firstNameTextInput; text: RosterManager.currentUser.firstName() }
            PropertyChanges { target: lastNameTextInput; text: RosterManager.currentUser.lastName() }
            PropertyChanges {
                target: leftButton
                buttonText: "Cancel"
                enabled: true
                onClicked: mainWindow.changePage(mainWindow.previousPage)
            }
            PropertyChanges {
                target: rightButton
                onClicked: {
                    if (recordRoster() === 1) {
                        mainWindow.changePage(mainWindow.previousPage)
                    }
                }
            }
        }
    ]

    Text {
        id: header
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 20 }
        font { pixelSize: 48; bold: true; }
        style: Text.Outline
        styleColor: "#80ff3a19"
        color: "white"
    }

    Column {
        anchors { centerIn: parent }
        spacing: 20

        Row {
            id: firstNameRow
            spacing: 20

            Text {
                width: 200
                font { bold: true; pixelSize: 20 }
                color: "white"
                text: "First Name:"
            }

            MyTextField {
                id: firstNameTextInput
                placeholderText: "<i>Enter First Name</i>"
                validator: RegExpValidator { regExp: /^[A-Za-z]+/ }
            }
        }

        Row {
            id: lastNameRow
            spacing: 20

            Text {
                width: 200
                font { bold: true; pixelSize: 20 }
                color: "white"
                text: "Last Name:"
            }

            MyTextField {
                id: lastNameTextInput
                placeholderText: "<i>Enter Last Name</i>"
                validator: RegExpValidator { regExp: /^[A-Za-z]+/ }
            }
        }

        Row {
            id: rfidRow
            spacing: 20

            Text {
                width: 200
                font { bold: true; pixelSize: 20 }
                color: "white"
                text: "RFID:"
            }

            MyTextField {
                id: rfidTextInput
                placeholderText: "<i>Scan RFID Card</i>"
                validator: RegExpValidator { regExp: /^[0-9]+/ }
            }
        }

        Text {
            id: prompt
            font { pointSize: 15 }
            color: "white"
        }

        Row {
            id: buttonRow
            anchors { horizontalCenter: parent.horizontalCenter }
            spacing: 20

            Button {
                id: leftButton
                width: 200
                height: 50
                enabled: rightButton.enabled
                buttonText: "Add More"
                onClicked: recordRoster()
            }

            Button {
                id: rightButton
                width: 200
                height: 50
                enabled: firstNameTextInput.acceptableInput && lastNameTextInput.acceptableInput && rfidTextInput.acceptableInput
                buttonText: "Done"
                onClicked: {/*Overridden in States*/}
            }
        }
    }
}
