import QtQuick 2.0
import Sailfish.Silica 1.0
import valuelogger.Logger 1.0

//import "pages"
//import "cover"

ApplicationWindow
{
    id: valuelogger

    property var plotColors:[ "#ffffff", "#ff0080", "#ff8000", "#ffff00", "#00ff00",
                              "#00ff80", "#00ffff", "#0000ff", "#8000ff", "#ff00ff" ]


    initialPage: Qt.resolvedUrl("pages/Valuelogger.qml") //Component { Valuelogger { } }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")

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
                                         "visualize": (tmp[i]["visualize"] == 1 ? true : false) })
            }
        }
    }

    ListModel
    {
        id: parameterList
    }


}


