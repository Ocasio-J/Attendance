import QtQuick 2.5

Rectangle {
    id: myButton

    property alias buttonText: text.text
    signal clicked

    radius: 50
    color: !enabled ? "gray"
                    : mouseArea.pressed ? "seagreen"
                                        : mouseArea.containsMouse ? "#ff5032"
                                                                  : "tomato"

    Keys.onReturnPressed: clicked()

    Text {
        id: text
        anchors { fill: parent }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color:"white"
        font { pointSize: 15; bold: true }
    }

    MouseArea{
        id: mouseArea
        enabled: myButton.enabled
        anchors { fill: parent }
        hoverEnabled: true
        onClicked: myButton.clicked()
    }
}
