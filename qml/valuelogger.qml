import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.valuelogger.Logger 1.0

ApplicationWindow
{
    id: valuelogger

    property var plotColors:[ "#ffffff", "#ff0080", "#ff8000", "#ffff00", "#00ff00",
                              "#00ff80", "#00ffff", "#0000ff", "#8000ff", "#ff00ff" ]

    property int lastDataAddedIndex: -1


    initialPage: Qt.resolvedUrl("pages/Valuelogger.qml") //Component { Valuelogger { } }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property string coverIconLeft: "image://theme/icon-cover-new"
    property string coverIconRight: "../icon-cover-plot.png"

    function coverLeftClicked()
    {
        if ((lastDataAddedIndex != -1) && (lastDataAddedIndex < parameterList.count))
        {
            console.log("Adding value to index " + lastDataAddedIndex)

            var dialog = pageStack.push(Qt.resolvedUrl("pages/AddValue.qml"),
                                        {"parameterName": parameterList.get(lastDataAddedIndex).parName,
                                         "parameterDescription": parameterList.get(lastDataAddedIndex).parDescription })

            dialog.accepted.connect(function()
            {
                console.log("dialog accepted")
                console.log(" value is " + dialog.value)
                console.log(" date is " + dialog.nowDate)
                console.log(" time is " + dialog.nowTime)

                logger.addData(parameterList.get(lastDataAddedIndex).dataTable, "", dialog.value, dialog.nowDate + " " + dialog.nowTime)

                valuelogger.deactivate()
            })
            dialog.rejected.connect(function()
            {
                console.log("Dialog rejected")
                valuelogger.deactivate()
            })

            valuelogger.activate()
        }
        else
            console.log("This should never happen")
    }

    function coverRightClicked()
    {
        console.log("showing data from " + parameterList.get(lastDataAddedIndex).parName)

        var l = []

        parInfo.clear()
        parInfo.append({"name": parameterList.get(lastDataAddedIndex).parName,
                        "plotcolor": parameterList.get(lastDataAddedIndex).plotcolor})
        l.push(logger.readData(parameterList.get(lastDataAddedIndex).dataTable))

        pageStack.push(Qt.resolvedUrl("pages/DrawData.qml"), {"dataList": l, "parInfo": parInfo})

        valuelogger.activate()
    }

    Logger
    {
        id: logger

        Component.onCompleted:
        {
            var tmp = logger.readParameters()

            for (var i=0 ; i<tmp.length; i++)
            {
                console.log(i + " = " + tmp[i]["name"] + " is " + tmp[i]["plotcolor"] )

                parameterList.append({"parName": tmp[i]["name"],
                                         "parDescription": tmp[i]["description"],
                                         "plotcolor": tmp[i]["plotcolor"],
                                         "dataTable": tmp[i]["datatable"],
                                         "visualize": (tmp[i]["visualize"] == 1 ? true : false),
                                         "visualizeChanged": false})
            }
        }
    }

    ListModel
    {
        id: parameterList
    }

    ListModel
    {
        id: parInfo
    }
}


