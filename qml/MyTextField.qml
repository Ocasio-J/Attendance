import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id:root
    property alias placeholderText:textField.placeholderText
    property alias mode: textField.echoMode
    property alias readOnly: textField.readOnly
    property alias text: textField.text
    property alias validator: textField.validator
    property alias acceptableInput: textField.acceptableInput

    implicitWidth: textField.implicitWidth
    implicitHeight: textField.implicitHeight

    TextField {
        id: textField
        font.pixelSize: 20
        maximumLength: 30
        validator: RegExpValidator { regExp: /^[A-Za-z0-9]+/ }

        style: TextFieldStyle {
            textColor: "white"
            placeholderTextColor: "darkgrey"
            background: Rectangle{
                color: "#80141414"
                border.color: textField.acceptableInput ? "seagreen" : "tomato"
                border.width: 2
                radius: 5
            }
        }
    }
}
