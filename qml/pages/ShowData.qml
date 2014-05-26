import QtQuick 2.0
import Sailfish.Silica 1.0


Page
{

    id: showDataPage

    property var dataList : []
    property string parName : "Name goes here"
    property string parDescription : "Description goes here"
    property string dataTable : "Data table name here"

    function test(s)
    {
        console.log("test " +s)
    }

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
                remorseAction(qsTr("Deleting"), function()
                {
                    logger.deleteData(dataTable, key)
                    dataListView.model.remove(index)
                }, 2500 )
            }

            function editData()
            {
                var editDialog = pageStack.push(Qt.resolvedUrl("AddValue.qml"),
                                            {"parameterName": parName,
                                             "parameterDescription": parDescription,
                                             "value": value,
                                             "nowDate": Qt.formatDateTime(new Date(timestamp), "yyyy-MM-dd"),
                                             "nowTime": Qt.formatDateTime(new Date(timestamp), "hh:mm:ss")})

                editDialog.accepted.connect( function()
                {
                    console.log("dialog accepted")
                    console.log(" value is " + editDialog.value)
                    console.log(" date is " + editDialog.nowDate)
                    console.log(" time is " + editDialog.nowTime)

                    dataListView.model.setProperty(index, "value", editDialog.value)
                    dataListView.model.setProperty(index, "timestamp", (editDialog.nowDate + " " + editDialog.nowTime))

                    logger.addData(dataTable, key, editDialog.value, (editDialog.nowDate + " " + editDialog.nowTime))
                })
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
                        text: qsTr("Edit")
                        onClicked: editData();
                    }

                    MenuItem
                    {
                        text: qsTr("Remove")
                        onClicked: remove();
                    }
                }
            }

        }
    }
}
