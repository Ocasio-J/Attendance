import QtQuick 2.5

Rectangle {
    id: dialogBox

    property alias text: dialogLabel.text
    property alias leftButtonText: leftButton.buttonText
    property alias rightButtonText: rightButton.buttonText

    signal leftButtonClicked
    signal rightButtonClicked

    color: "#E6000000"

    MouseArea { id: inputBlockerMA; anchors.fill: parent }

    Rectangle {
        id: dialogView
        anchors { centerIn: parent }
        width: 400
        height: 200
        radius: 15
        border { color: "dodgerBlue"; width: 3 }
        color: "#90000000"

        Text {
            id: dialogLabel
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 40 }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font { pointSize: 15 }
            color: "white"
        }

        Row {
            id: buttonsRow
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 40 }
            spacing: 20

            Button {
                id: leftButton
                width: 100
                height: 50
                buttonText: "Cancel"
                onClicked: leftButtonClicked()
            }

            Button {
                id: rightButton
                width: 100
                height: 50
                visible: buttonText.length
                onClicked: rightButtonClicked()
            }
        }
    }
}
