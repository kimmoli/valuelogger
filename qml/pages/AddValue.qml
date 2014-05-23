import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: page

    canAccept: false

    property string parameterName: "value"
    property string parameterDescription: "value"
    property string value: "value"

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            value = valueField.text
        }
    }

    DialogHeader
    {
        id: pageHeader
        title: "Add new value"
        acceptText: "Add"
        cancelText: "Cancel"
    }

    Column
    {
        id: col
        spacing: Theme.paddingLarge
        width: page.width
        anchors.top: pageHeader.bottom

        Label
        {
            text: parameterName
            width: parent.width
            x: Theme.paddingLarge
            font.bold: true
        }
        Label
        {
            text: parameterDescription
            width: parent.width
            x: Theme.paddingLarge
            color: Theme.secondaryColor
        }

        TextField
        {
            id: valueField
            focus: true
            width: parent.width
            label: "Value"
            placeholderText: "Enter new value here"
            onTextChanged: page.canAccept = text.length > 0
            inputMethodHints: Qt.ImhDigitsOnly
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: page.accept()
        }
    }


}
