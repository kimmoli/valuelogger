import QtQuick 2.0
import Sailfish.Silica 1.0

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

            var datatable = logger.addParameterEntry("", dialog.parameterName, dialog.parameterDescription, true, dialog.plotColor)

            parameterList.append({"parName": dialog.parameterName,
                                  "parDescription": dialog.parameterDescription,
                                  "visualize": true,
                                  "plotcolor": logger.colorToString(dialog.plotColor),
                                  "dataTable": datatable,
                                  "visualizeChanged": false})
        } )
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
                                              "year": "2014",
                                              "name": "Value Logger",
                                              "imagelocation": "/usr/share/icons/hicolor/86x86/apps/harbour-valuelogger.png"} )
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
                        logger.deleteParameterEntry(parName, dataTable)
                        parameters.model.remove(index)
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

                        logger.addParameterEntry(dataTable, dialog.parameterName, dialog.parameterDescription, visualize, dialog.plotColor)

                        parameters.model.setProperty(index, "parName", dialog.parameterName)
                        parameters.model.setProperty(index, "parDescription", dialog.parameterDescription)
                        parameters.model.setProperty(index, "plotcolor", logger.colorToString(dialog.plotColor))
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
                        width: parent.width - parSwitch.width - addValueButton.width
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

                    IconButton
                    {
                        id: addValueButton
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-add"
                        onClicked:
                        {
                            console.log("clicked add value button")

                            var dialog = pageStack.push(Qt.resolvedUrl("AddValue.qml"),
                                                        {"parameterName": parName,
                                                         "parameterDescription": parDescription })

                            dialog.accepted.connect(function()
                            {
                                console.log("dialog accepted")
                                console.log(" value is " + dialog.value)
                                console.log(" date is " + dialog.nowDate)
                                console.log(" time is " + dialog.nowTime)

                                logger.addData(dataTable, "", dialog.value, dialog.nowDate + " " + dialog.nowTime)
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
                                    dataList.append( {"key":tmp[i]["key"], "value": tmp[i]["value"], "timestamp": tmp[i]["timestamp"]} )
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
                                                 parameterList.get(a).plotcolor)

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

            ListModel
            {
                id: parInfo
            }
        }
    }

}


