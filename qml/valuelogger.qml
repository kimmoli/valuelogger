import QtQuick 2.0
import Sailfish.Silica 1.0
import valuelogger.Logger 1.0

//import "pages"
//import "cover"

ApplicationWindow
{
    id: valuelogger

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
                console.log(i + " = " + tmp[i]["name"] + " is " + (tmp[i]["visualize"] == 1 ? true : false))

                parameterList.append({"parName": tmp[i]["name"],
                                         "parDescription": tmp[i]["description"],
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


