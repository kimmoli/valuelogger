/*
	Original Copyright (c) 2013 Jussi Sainio
 
	Modified to support multiple lines for valuelogger 2014 Kimmo Lindholm

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.valuelogger.Logger 1.0

Item
{
    id: chart
    width: parent.width
    height: parent.height

    property var dataListModel: null
    property var parInfoModel: null
    property string column: "value"

    property real min : 0.0
    property real max : 1.0

    property int fontSize: Theme.fontSizeTiny
    property bool fontBold: true

    property date xstart : new Date()
    property date xend : new Date()

    function distanceX(p1, p2)
    {
        return Math.max(p1.x, p2.x) - Math.min(p1.x, p2.x)
    }
    function distanceY(p1, p2)
    {
        return Math.max(p1.y, p2.y) - Math.min(p1.y, p2.y)
    }

    function getMinMax(data)
    {
        var last = data.length - 1;
        var first = 0;

        var s = new Date(data[0]["timestamp"])

        if (s.getTime() < xstart.getTime())
            xstart = s

        s = new Date(data[data.length-1]["timestamp"])

        if (s.getTime() > xend.getTime())
            xend = s

        first = 0;
        last = data.length - 1;

        for (var i = first; i <= last; i++)
        {
            var l = data[i]

            if (l[column] > max)
                max = l[column];

            if (l[column] < min)
                min = l[column];
        }
    }

    function updateVerticalScale()
    {

        var m = (((max-min))/canvas.height)*pinchZoom.deltaY

        max = max - m/2
        min = min + m/2

        var d = (((max-min))/canvas.height)*pinchMove.movementY

        max = max + d
        min = min + d

        valueMax.text = max.toFixed(2)
        valueMin.text = min.toFixed(2)

        var n = valueMiddle.count + 1
        for (var midIndex=0; midIndex<valueMiddle.count; midIndex++) {
            valueMiddle.itemAt(midIndex).text = (min+(((max-min)/n)*(midIndex+1))).toFixed(2)
        }
    }

    function updateHorizontalScale()
    {
        var mm = (((xstart.getTime() - xend.getTime()))/canvas.width)*pinchZoom.deltaX

        var t = new Date()
        t.setTime(xstart.getTime() - Math.floor(mm))
        xstart = t

        var u = new Date()
        u.setTime(xend.getTime() + Math.floor(mm))
        xend = u

        var dd = (((xstart.getTime() - xend.getTime()))/canvas.width)*pinchMove.movementX

        t = new Date()
        t.setTime(xstart.getTime() + Math.floor(dd))
        xstart = t

        u = new Date()
        u.setTime(xend.getTime() + Math.floor(dd))
        xend = u

        xStart.text = Qt.formatDateTime(xend, "dd.MM.yyyy hh:mm")
        xEnd.text = Qt.formatDateTime(xstart, "dd.MM.yyyy hh:mm")
    }

    function updateGraph()
    {
        // assign some timestamp which is in range as start/end default for further expanding
        xstart = new Date(dataListModel[0][0]["timestamp"])
        xend = new Date(dataListModel[0][0]["timestamp"])

        min = 99999999.9
        max = -99999999.9

        for (var n=0; n<dataListModel.length; n++)
            getMinMax(dataListModel[n])

        updateVerticalScale()
        updateHorizontalScale()
    }

    onWidthChanged: sizeChangedTimer.restart()

    onHeightChanged: sizeChangedTimer.restart()

    Timer
    {
        id: sizeChangedTimer
        interval: 0
        repeat: false
        onTriggered: updateGraph()
    }

    Text
    {
        id: xStart
        color: Theme.primaryColor
        font.pixelSize: fontSize
        font.bold: fontBold
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: parent.top
        text: "unk"
    }

    Text
    {
        id: xEnd
        color: Theme.primaryColor
        font.pixelSize: fontSize
        font.bold: fontBold
        anchors.left: parent.left
        anchors.top: parent.top
        horizontalAlignment: Text.AlignRight
        text: "unk"
    }

    Text
    {
        id: valueMax
        color: Theme.primaryColor
        width: 50
        font.pixelSize: fontSize
        font.bold: fontBold
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall
        anchors.top: xEnd.bottom
        text: "unk"
    }

    Text
    {
        id: valueMin
        color: Theme.primaryColor
        width: 50
        font.pixelSize: fontSize
        font.bold: fontBold
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall
        anchors.bottom: parent.bottom
        text: "unk"
    }

    Repeater
    {
        id: valueMiddle
        model:4

        Text
        {
            color: Theme.primaryColor
            font.pixelSize: fontSize
            font.bold: fontBold
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            text: "unk"
            y: valueMin.y + (index+1)*(valueMax.y + valueMax.height - valueMin.y)/5
            z: 10
        }
    }

    ListView
    {
        x: 150
        y: 150
        z: 11
        height: fontSize*1.2*10
        id: legend
        model: parInfoModel

        delegate: ListItem
        {
            contentHeight: fontSize*2

            Row
            {
                id: legendRow
                height: fontSize*2
                spacing: 10
                Rectangle
                {
                    id: legendColor
                    width: 30
                    height: 3
                    color: plotcolor
                }
                Text
                {
                    text: name
                    color: Theme.primaryColor
                    font.pointSize: fontSize
                    font.bold: fontBold
                    anchors.verticalCenter: legendColor.verticalCenter
                }
            }
        }

        Behavior on opacity
        {
            FadeAnimation {}
        }

        onOpacityChanged:
        {
            if (opacity == 1.0)
                legendVisibility.start()
        }

        Timer
        {
            id: legendVisibility
            interval: 2000
            running: true
            onTriggered:  legend.opacity = 0.0
        }

    }

    Repeater
    {
        model: 7
        delegate: Rectangle
        {
            x: index * parent.width/6
            width: 1
            anchors.top: valueMax.bottom
            anchors.bottom: valueMin.top
            opacity: 0.3
        }
    }

    Repeater
    {
        model: 6
        delegate: Rectangle
        {
            y: valueMin.y + index*(valueMax.y + valueMax.height - valueMin.y)/5 + height
            width: parent.width
            height: 1
            opacity: 0.3
        }
    }

    Item
    {
        id: canvas
        width: parent.width
        anchors.top: valueMax.bottom
        anchors.bottom: valueMin.top

        PinchArea
        {
            id: pinchZoom
            anchors.fill: canvas

            property real iX
            property real iY
            property real deltaX : 0
            property real deltaY : 0

            property point lv1
            property point lv2

            property bool scaleInX

            onPinchFinished:
            {
            }
            onPinchStarted:
            {
                iX = distanceX(pinch.point1, pinch.point2)
                iY = distanceY(pinch.point1, pinch.point2)

                scaleInX = (iX > iY)
            }
            onPinchUpdated:
            {
                if (pinch.point1 !== pinch.point2)
                {
                    lv1 = pinch.point1
                    lv2 = pinch.point2
                }

                if (scaleInX)
                {
                    var dX = distanceX(lv1, lv2) - iX
                    iX = distanceX(lv1, lv2)
                    deltaX += dX
                }
                else
                {
                    var dY = distanceY(lv1, lv2) - iY
                    iY = distanceY(lv1, lv2)
                    deltaY += dY
                }

                updateGraph()
            }

            MouseArea
            {
                property real iX
                property real iY
                property real movementX : 0
                property real movementY : 0

                id: pinchMove
                anchors.fill: parent

                onClicked: legend.opacity = 1.0

                onPressed:
                {
                    plotDraggingActive = true
                    iX = mouseX
                    iY = mouseY
                }
                onDoubleClicked:
                {
                    movementX = 0
                    movementY = 0
                    pinchZoom.deltaX = 0
                    pinchZoom.deltaY = 0

                    updateGraph()
                }
                onPositionChanged:
                {
                    var dX = mouseX - iX
                    iX = mouseX
                    movementX += dX
                    var dY = mouseY - iY
                    iY = mouseY
                    movementY += dY

                    updateGraph()
                }
                onReleased: plotDraggingActive = false
            }
        }

        Repeater
        {
            model: dataListModel
            delegate: Graph
            {
                anchors.fill: parent
                minValue: min
                maxValue: max
                minTime: xstart
                maxTime: xend
                data: modelData
                lineWidth: Math.max(Math.min(Math.round(Theme.paddingSmall/2), width/modelData.length), 2)
                color: parInfoModel.get(index).plotcolor
            }
        }
    }
}
