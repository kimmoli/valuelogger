import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: newParamaterPage

    canAccept: false

    property string parameterName: ""
    property string parameterDescription: ""
    property color plotColor: plotColors[0]
    property string pageTitle: "Add"

    onDone:
    {
        console.log("closing: " + result)
        if (result === DialogResult.Accepted)
        {
            parameterName = parNameField.text
            parameterDescription = parDescField.text
            console.log("color set to " + plotColor)
//            plotColor = plotColorLegend.color
        }
    }

    DialogHeader
    {
        id: pageHeader
        title: pageTitle + " parameter"
        acceptText: pageTitle
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
            text: parameterName
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
            text: parameterDescription
            placeholderText: "Enter short description here"
            EnterKey.enabled: true
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.onClicked: parNameField.focus = true
        }
        SectionHeader
        {
            text: "Plot color"
        }

        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 50

            Rectangle
            {
                id: plotColorLegend
                height: 50
                width: 50
                color: plotColor
            }

            Button
            {
                text: "Change"
                anchors.verticalCenter: plotColorLegend.verticalCenter
                onClicked:
                {
                    var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog", { "colors": plotColors })
                    dialog.accepted.connect(function()
                    {
                        console.log("Changed color to " + dialog.color)
                        plotColorLegend.color = dialog.color
                        plotColor = dialog.color
                    })
                }
            }
        }
    }


}
