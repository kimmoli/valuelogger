import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: addPairPage

    property string pairFirst: ""
    property string pairSecondTable: ""

    DialogHeader
    {
        id: dialogHeader
        acceptText: pairSecondTable === "" ? qsTr("Clear pair") : qsTr("Add pair")
        cancelText: qsTr("Cancel")
    }

    SilicaListView
    {
        width: parent.width
        height: parent.height - dialogHeader.height
        anchors.top: dialogHeader.bottom
        clip: true

        VerticalScrollDecorator { flickable: parameters }

        model: parameterList

        delegate: MouseArea
        {
            id: parameterItem
            property bool highlighted: dataTable === pairSecondTable
            enabled: parName !== pairFirst
            height: Theme.itemSizeMedium
            width: parent.width

            onClicked:
            {
                // toggle logic
                if (pairSecondTable === dataTable)
                    pairSecondTable = ""
                else
                    pairSecondTable = dataTable
            }

            Rectangle
            {
                id: bgRect
                width: parent.width
                height: parent.height
                color: parent.highlighted ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) : "transparent"
            }

            Column
            {
                width: parent.width - Theme.paddingMedium
                anchors.verticalCenter: bgRect.verticalCenter
                anchors.left: bgRect.left
                anchors.leftMargin: Theme.paddingLarge

                Label
                {
                    id: parNameLabel
                    text: parName
                    color: parameterItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    opacity: parameterItem.enabled ? 1.0 : 0.6
                }
                Label
                {
                    text: parDescription
                    font.pixelSize: Theme.fontSizeSmall
                    color: parameterItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                    opacity: parameterItem.enabled ? 1.0 : 0.6
                }
            }
        }
    }
}


