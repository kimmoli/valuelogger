import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground
{
    Image
    {
        id: im
        source: "/usr/share/icons/hicolor/86x86/apps/harbour-valuelogger.png"
        anchors.top: parent.top
        anchors.topMargin: (parent.height - im.height - label.height - label.anchors.topMargin) / 2
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Label
    {
        id: label
        anchors.top: im.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Value logger"
    }
    Label
    {
        id: par
        visible: lastDataAddedIndex != -1
        anchors.top: label.bottom
        font.pixelSize: Theme.fontSizeTiny
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: parameterList.get(lastDataAddedIndex).parName
    }

    CoverActionList   /* Courtesy of http://sailfishdev.tumblr.com/post/86418219502/dynamic-coverpage */
    {
        enabled: lastDataAddedIndex != -1

        CoverAction
        {
            iconSource: coverIconLeft
            onTriggered: coverLeftClicked()
        }
        CoverAction
        {
            iconSource: coverIconRight
            onTriggered: coverRightClicked()
        }
    }
}
