import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: newParamaterPage

    canAccept: false

    property string parameterName: "value"
    property string parameterDescription: "value"

    onDone:
    {
        console.log("closing: " + result)
        if (result === DialogResult.Accepted)
        {
            parameterName = parNameField.text
            parameterDescription = parDescField.text
        }
    }

    DialogHeader
    {
        id: pageHeader
        title: "Add new parameter"
        acceptText: "Add"
        cancelText: "Cancel"
    }

    Column
    {
        id: col
        spacing: Theme.paddingLarge
        width: newParamaterPage.width
        anchors.top: pageHeader.bottom

        TextField
        {
            id: parNameField
            focus: true
            width: parent.width
            label: "Parameter name"
            placeholderText: "Enter parameter name here"
            onTextChanged: newParamaterPage.canAccept = text.length > 0
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.onClicked: parDescField.focus = true
        }
        TextField
        {
            id: parDescField
            width: parent.width
            label: "Description"
            placeholderText: "Enter short description here"
            EnterKey.enabled: true
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.onClicked: parNameField.focus = true
        }
    }


}
