import QtQuick 2.3

Rectangle {
    id:root
    color: "transparent"

    property alias headerText: header.text
    property bool isAddingAdmin: true
    property var rfid
    property var firstName
    property var lastName

    signal reEnable

    Text {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        text: qsTr("Add Administrators")
        height: 80
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 24
        color: "white"
    }

    Text {
        id: firstNameLabel
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 50
        anchors.top: header.bottom
        anchors.topMargin: 10

        text: qsTr("First Name:")
        color: "white"
        font.bold: true
        font.pixelSize: 20
    }

    MyTextField{
        id: firstNameTextInput
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 50
        anchors.top: firstNameLabel.top

        placeholderText: "<i>Enter First Name</i>"
        validator: RegExpValidator {regExp: /^[A-Za-z]+/}
    }

    Text {
        id: lastNameLabel
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 50
        anchors.top: firstNameLabel.bottom
        anchors.topMargin: 25

        text: qsTr("Last Name:")
        color: "white"
        font.bold: true
        font.pixelSize: 20
    }

    MyTextField{
        id: lastNameTextInput
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 50
        anchors.top: lastNameLabel.top

        placeholderText: "<i>Enter Last Name</i>"
        validator: RegExpValidator {regExp: /^[A-Za-z]+/}
    }

    Text {
        id: rfidLabel
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 50
        anchors.top: lastNameLabel.bottom
        anchors.topMargin: 20

        text: qsTr("RFID:")
        color: "white"
        font.bold: true
        font.pixelSize: 20
    }

    MyTextField {
        id: rfidTextInput
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 50
        anchors.top: rfidLabel.top

        placeholderText: "<i>Scan RFID Card</i>"
        //readOnly: true
        validator: RegExpValidator {regExp: /^[0-9]+/}
        text: SerialCom.RFID
    }

    Button {
        id: clearButton
        anchors.left: rfidTextInput.right
        anchors.leftMargin: 200
        anchors.verticalCenter:  rfidLabel.verticalCenter
        width: 25
        height: 25

        buttonText: "X"

        onClicked: {
            if (rfidTextInput.text.length !== 0){
            }
        }
    }

    Text {
        id: promptLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: rfidLabel.bottom
        anchors.topMargin: 30

        color: "white"
        font.pointSize: 15
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Button{
        id: backButton
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 50
        anchors.top: rfidLabel.bottom
        anchors.topMargin: 75
        width: 200
        height: 50

        buttonText: "Back"

        onClicked: {
            SerialCom.stopRFIDThread()
            reEnable()
            root.destroy()
        }
    }

    Button{
        id: doneButton
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 50
        anchors.top: backButton.top
        width: 200
        height: 50

        buttonText: "Next"

        onClicked: {
            if (firstNameTextInput.text.length === 0 ) {
                firstNameTextInput.forceActiveFocus()                
                promptLabel.text = "Please enter a first name"
            }  else if (rfidTextInput.text.length === 0 ){
                promptLabel.text = "Please scan a RFID card"
                rfidTextInput.forceActiveFocus()
            } else if (lastNameTextInput.text.length === 0){
                promptLabel.text = "Please enter a last name"
                lastNameTextInput.forceActiveFocus()
            } else {
                var x
                if (isAddingAdmin){
                    x = SQLManager.addToRoster(rfidTextInput.text, firstNameTextInput.text, lastNameTextInput.text,"Administrators")
                } else {
                    x = SQLManager.updateRoster(root.rfid, rfidTextInput.text,root.firstName, firstNameTextInput.text,root.lastName, lastNameTextInput.text,"Administrators")
                }

                if (x === -2) {
                    promptLabel.text = "Card is assigned to another person. Try another card"
                    rfidTextInput.textFieldFocus = true;
                } else {
                    reEnable()
                    SQLModel.setSqlQuery("SELECT rfid,firstName,lastName,groupName FROM roster")
                    root.destroy() // Only use destroy() when Component is created dynamically in javascript code
                }
            }
        }
    }

    Component.onCompleted: {
        firstNameTextInput.forceActiveFocus()

        if (!root.isAddingAdmin){
            firstNameTextInput.placeholderText = root.firstName
            lastNameTextInput.placeholderText = root.lastName
            rfidTextInput.placeholderText = root.rfid
        }
    }
}
