import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"


Page
{
    property var dataList : []

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    LinePlot
    {
        dataListModel: dataList
        id: plot
        width: parent.width - 2*Theme.paddingLarge
        height: parent.height - 2*Theme.paddingLarge
        anchors.centerIn: parent
    }
}

