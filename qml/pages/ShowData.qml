import QtQuick 2.0
import Sailfish.Silica 1.0


Page
{

    id: page

    property var dataList : []
    property string parName : "Name goes here"

    PageHeader
    {
        id: pageHeader
        title: parName
    }

    ListView
    {
        model: dataList

        width: parent.width
        height: parent.height - pageHeader.height
        anchors.top: pageHeader.bottom
        clip: true

        delegate: ListItem
        {
            contentHeight: Theme.itemSizeSmall

            Row
            {
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.paddingMedium
                width: parent.width - 3*Theme.paddingMedium
                spacing: width - timestampLabel.width - valueLabel.width

                Label
                {
                    id: timestampLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: timestamp
                }
                Label
                {
                    id: valueLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: value
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeExtraLarge
                }
            }
        }
    }
}
