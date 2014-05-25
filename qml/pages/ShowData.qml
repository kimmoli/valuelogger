import QtQuick 2.0
import Sailfish.Silica 1.0


Page
{

    id: showDataPage

    property var dataList : []
    property string parName : "Name goes here"
    property string dataTable : "kukkuu"

    PageHeader
    {
        id: pageHeader
        title: parName
    }

    ListView
    {
        id: dataListView

        model: dataList

        width: parent.width
        height: parent.height - pageHeader.height
        anchors.top: pageHeader.bottom
        clip: true

        delegate: ListItem
        {
            id: dataItem
            contentHeight: Theme.itemSizeSmall
            menu: contextMenu

            ListView.onRemove: animateRemoval(dataItem)

            function remove()
            {
                console.log("Deleting...")
                remorseAction("Deleting", function()
                {
                    logger.deleteData(dataTable, timestamp)
                    dataListView.model.remove(index)
                }, 2500 )
            }

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

            Component
            {
                id: contextMenu
                ContextMenu
                {
                    MenuItem
                    {
                        text: "Remove"
                        onClicked: remove()
                    }
                }
            }

        }
    }
}
