import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"


Page
{
    property var dataList : []


    LinePlot
    {
        dataListModel: dataList
        id: plot
        width: parent.width - 2*Theme.paddingLarge
        height: 400
        x: Theme.paddingLarge
    }

}

