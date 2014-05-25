import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page
{
    id: drawDataPage
    property var dataList : []
    property var parInfo : null

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    PageHeader
    {
        id: ph
        title: "Plot"
    }

    LinePlot
    {
        dataListModel: dataList
        parInfoModel: parInfo
        id: plot
        width: parent.width - Theme.paddingLarge
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge/2
        anchors.top: ph.bottom
        anchors.bottom: parent.bottom
    }
}

