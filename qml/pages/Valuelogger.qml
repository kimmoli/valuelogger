import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page
{
    id: mainPage

    function addParameter(index, oldParName, oldParDesc, oldPlotColor)
    {
        var dialog = pageStack.push(Qt.resolvedUrl("NewParameter.qml"))

        dialog.accepted.connect(function()
        {
            console.log("dialog accepted")
            console.log(dialog.parameterName)
            console.log(dialog.parameterDescription)
            console.log(dialog.plotColor)

            var datatable = logger.addParameterEntry("", dialog.parameterName, dialog.parameterDescription, true, dialog.plotColor, "")

            parameterList.append({"parName": dialog.parameterName,
                                  "parDescription": dialog.parameterDescription,
                                  "visualize": true,
                                  "plotcolor": logger.colorToString(dialog.plotColor),
                                  "dataTable": datatable,
                                  "pairedTable": "",
                                  "visualizeChanged": false})
        } )
    }

    Messagebox
    {
        id: messagebox
    }

    SilicaFlickable
    {
        anchors.fill: parent

        PullDownMenu
        {
            MenuItem
            {
                text: qsTr("About...")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"),
                                          { "version": logger.version,
                                              "year": "2014-2015",
                                              "name": "Value Logger",
                                              "imagelocation": "/usr/share/icons/hicolor/86x86/apps/harbour-valuelogger.png"} )
            }

            MenuItem
            {
                text: qsTr("Export to CSV")
                onClicked:
                {
                    messagebox.showMessage(qsTr("Exported to:") + "<br>" + logger.exportToCSV(), 2500)
                }
            }
        }

        contentHeight: column.height

        Column
        {
            id: column

            width: mainPage.width
            spacing: Theme.paddingLarge

            PageHeader
            {
                title: "Value Logger"
            }

            Button
            {

                text: qsTr("Add new parameter")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: addParameter()
            }
        }

        ListView
        {
            id: parameters
            width: parent.width
            height: 6*Theme.itemSizeMedium
            clip: true

            VerticalScrollDecorator { flickable: parameters }

            model: parameterList

            anchors.top: column.bottom

            delegate: ListItem
            {
                id: parameterItem
                menu: contextMenu
                contentHeight: Theme.itemSizeMedium

                ListView.onRemove: animateRemoval(parameterItem)

                function remove()
                {
                    remorseAction(qsTr("Deleting"), function()
                    {
                        // remove this from parameters where it is paired to
                        for (var i=0 ; i<parameters.model.count; i++)
                        {
                            var tmp = parameters.model.get(i)
                            if (tmp.pairedTable === dataTable)
                            {
                                parameters.model.setProperty(i, "pairedTable", "")
                                logger.setPairedTable(tmp.dataTable, "")
                            }
                        }

                        logger.deleteParameterEntry(parName, dataTable)
                        parameters.model.remove(index)
                        lastDataAddedIndex = -1
                    })
                }

                function editParameter()
                {
                    var dialog = pageStack.push(Qt.resolvedUrl("NewParameter.qml"),
                                                {"parameterName": parName,
                                                    "parameterDescription": parDescription,
                                                    "plotColor": plotcolor,
                                                    "pageTitle": qsTr("Edit")})

                    dialog.accepted.connect(function()
                    {
                        console.log("EDIT dialog accepted")
                        console.log(dialog.parameterName)
                        console.log(dialog.parameterDescription)
                        console.log(dialog.plotColor)

                        logger.addParameterEntry(dataTable, dialog.parameterName, dialog.parameterDescription, visualize, dialog.plotColor, pairedTable)

                        parameters.model.setProperty(index, "parName", dialog.parameterName)
                        parameters.model.setProperty(index, "parDescription", dialog.parameterDescription)
                        parameters.model.setProperty(index, "plotcolor", logger.colorToString(dialog.plotColor))
                    } )
                }

                function pairParameter()
                {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddPair.qml"),
                                                {"pairFirstTable": dataTable,
                                                 "pairSecondTable": pairedTable})

                    dialog.accepted.connect(function()
                    {
                        console.log("Add pair dialog accepted")
                        console.log(dialog.pairSecondTable)
                        logger.setPairedTable(dataTable, dialog.pairSecondTable)
                        parameters.model.setProperty(index, "pairedTable", dialog.pairSecondTable)
                    } )
                }

                Row
                {
                    width: parent.width - Theme.paddingMedium

                    Switch
                    {
                        id: parSwitch
                        checked: visualize
                        onCheckedChanged:
                        {
                            parameterList.setProperty(index, "visualize", checked)
                            parameterList.setProperty(index, "visualizeChanged", true)
                        }
                    }

                    Column
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - parSwitch.width - addValueButton.width - pairIcon.width
                        Label
                        {
                            id: parNameLabel
                            text: parName
                            color: parameterItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label
                        {
                            text: parDescription
                            font.pixelSize: Theme.fontSizeSmall
                            color: parameterItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                        }
                    }
                    Image
                    {
                        id: pairIcon
                        source: "image://theme/icon-m-link"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 48
                        height: 48
                        opacity: (pairedTable === "") ? 0.0 : 0.9
                    }

                    IconButton
                    {
                        id: addValueButton
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-add"
                        onClicked:
                        {
                            console.log("clicked add value button")

                            lastDataAddedIndex = index

                            var dialog = pageStack.push(Qt.resolvedUrl("AddValue.qml"),
                                                        {"parameterName": parName,
                                                         "parameterDescription": parDescription })

                            if (pairedTable !== "")
                            {
                                console.log("this is a paired parameter")
                                var paired_parName = "ERROR"
                                var paired_parDescription = "ERROR"

                                for (var i=0; i<parameterList.count; i++)
                                {
                                    var tmp = parameterList.get(i)
                                    if (tmp.dataTable === pairedTable)
                                    {
                                        paired_parName = tmp.parName
                                        paired_parDescription = tmp.parDescription
                                        console.log("found " + tmp.parName + " " + tmp.parDescription)
                                        break
                                    }
                                }

                                var pairdialog = pageStack.pushAttached(Qt.resolvedUrl("AddValue.qml"),
                                                           {"nowDate": dialog.nowDate,
                                                            "nowTime": dialog.nowTime,
                                                            "parameterName": paired_parName,
                                                            "parameterDescription": paired_parDescription,
                                                            "paired": true})

                                pairdialog.accepted.connect(function()
                                {
                                    console.log("paired dialog accepted")
                                    console.log(" value is " + pairdialog.value)
                                    console.log(" annotation is " + pairdialog.annotation)
                                    console.log(" date is " + pairdialog.nowDate)
                                    console.log(" time is " + pairdialog.nowTime)

                                    logger.addData(pairedTable, "", pairdialog.value, pairdialog.annotation, pairdialog.nowDate + " " + pairdialog.nowTime)

                                })
                            }

                            dialog.accepted.connect(function()
                            {
                                console.log("dialog accepted")
                                console.log(" value is " + dialog.value)
                                console.log(" annotation is " + dialog.annotation)
                                console.log(" date is " + dialog.nowDate)
                                console.log(" time is " + dialog.nowTime)

                                logger.addData(dataTable, "", dialog.value, dialog.annotation, dialog.nowDate + " " + dialog.nowTime)
                            })
                        }
                    }
                }

                Component
                {
                    id: contextMenu
                    ContextMenu
                    {
                        MenuItem
                        {
                            text: qsTr("Show raw data")
                            onClicked:
                            {
                                var tmp = logger.readData(dataTable)

                                dataList.clear()

                                for (var i=0 ; i<tmp.length; i++)
                                {
                                    console.log(i + " = " + tmp[i]["timestamp"] + " = " + tmp[i]["value"])
                                    dataList.append( {"key":tmp[i]["key"],
                                                        "value": tmp[i]["value"],
                                                        "annotation": tmp[i]["annotation"],
                                                        "timestamp": tmp[i]["timestamp"]} )
                                }
                                pageStack.push(Qt.resolvedUrl("ShowData.qml"),
                                               { "parName": parName,
                                                 "parDescription": parDescription,
                                                 "dataList": dataList,
                                                 "dataTable": dataTable} );
                            }
                        }

                        MenuItem
                        {
                            text: qsTr("Edit")
                            onClicked: editParameter()
                        }

                        MenuItem
                        {
                            text: qsTr("Pair")
                            onClicked: pairParameter()
                        }

                        MenuItem
                        {
                            text: qsTr("Remove")
                            onClicked: remove()
                        }
                    }
                }
                ListModel
                {
                    id: dataList
                }

            }
        }


        Button
        {
            text: qsTr("Plot selected")
            enabled: parameterList.count > 0

            onClicked:
            {
                console.log("there is " + parameterList.count + " items in list.")

                var l = []
                parInfo.clear()

                for (var a=0; a<parameterList.count; a++)
                {
                    /* Save changes if visualize touched */
                    if (parameterList.get(a).visualizeChanged)
                        logger.addParameterEntry(parameterList.get(a).dataTable,
                                                 parameterList.get(a).parName,
                                                 parameterList.get(a).parDescription,
                                                 parameterList.get(a).visualize,
                                                 parameterList.get(a).plotcolor,
                                                 parameterList.get(a).pairedTable)

                    if (parameterList.get(a).visualize)
                    {
                        console.log("showing data from " + parameterList.get(a).parName)
                        parInfo.append({"name": parameterList.get(a).parName,
                                        "plotcolor": parameterList.get(a).plotcolor})
                        l.push(logger.readData(parameterList.get(a).dataTable))
                    }
                }

                if (l.length > 0 && l.length < 10)
                {
                    pageStack.push(Qt.resolvedUrl("DrawData.qml"), {"dataList": l, "parInfo": parInfo})
                }
                else
                    console.log("ERROR: None or too many plots selected")

            }
            anchors.top: parameters.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

}


