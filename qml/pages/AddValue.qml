import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: page

    canAccept: false

    property string parameterName: "value"
    property string parameterDescription: "value"
    property string value: "value"
    property string nowDate: "2014-01-01"
    property string nowTime: "00:00:00"

    Component.onCompleted:
    {
        var tmp = new Date()
        updateDateTime(Qt.formatDateTime(tmp, "yyyy-MM-dd"), Qt.formatDateTime(tmp, "hh:mm:ss"))
    }

    function updateDateTime (newDate, newTime)
    {
        nowDate = Qt.formatDateTime(new Date(newDate), "yyyy-MM-dd")
        nowTime = Qt.formatDateTime(new Date(newDate + " " + newTime), "hh:mm:ss")

        console.log("date " + nowDate + " time " + nowTime)

        dateNow.text = Qt.formatDateTime(new Date(nowDate), "dd.MM.yyyy") + " " + Qt.formatDateTime(new Date(nowDate + " " + nowTime), "hh:mm")

        console.log("dateNow " + dateNow.text)
    }

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            value = valueField.text
        }
    }

    DialogHeader
    {
        id: pageHeader
        title: "Add new value"
        acceptText: "Add"
        cancelText: "Cancel"
    }

    Column
    {
        id: col
        spacing: Theme.paddingSmall
        width: page.width
        anchors.top: pageHeader.bottom

        Label
        {
            text: parameterName
            width: parent.width
            x: Theme.paddingLarge
            font.bold: true
        }
        Label
        {
            text: parameterDescription
            width: parent.width
            x: Theme.paddingLarge
            color: Theme.secondaryColor
        }

        SectionHeader
        {
            text: "Timestamp"
        }

        Row
        {
            x: Theme.paddingLarge
            width: parent.width - 2*Theme.paddingLarge

            Label
            {
                id: dateNow
                text: "unknown"
                width: parent.width - modifyDateButton.width - modifyTimeButton.width
                anchors.verticalCenter: parent.verticalCenter
            }

            IconButton
            {
                id: modifyDateButton
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "image://theme/icon-lock-calendar"
                onClicked:
                {
                    console.log("modifyDateButton clicked")

                    var dialogDate = pageStack.push(pickerDate, { date: new Date(nowDate) })
                           dialogDate.accepted.connect(function()
                           {
                               console.log("You chose: " + dialogDate.dateText)

                               updateDateTime(dialogDate.dateText, nowTime)
                           })
                }
                Component
                {
                    id: pickerDate
                    DatePickerDialog {}
                }

            }
            IconButton
            {
                id: modifyTimeButton
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "image://theme/icon-m-time-date"
                onClicked:
                {
                    console.log("modifyTimeButton clicked")

                    console.log("hour " + Qt.formatDateTime(new Date(nowDate + " " + nowTime), "hh"))
                    console.log("minute " + Qt.formatDateTime(new Date(nowDate + " " + nowTime), "mm"))

                    var dialogTime = pageStack.push(pickerTime, {
                                                        hour: Qt.formatDateTime(new Date(nowDate + " " + nowTime), "hh"),
                                                        minute: Qt.formatDateTime(new Date(nowDate + " " + nowTime), "mm")})
                          dialogTime.accepted.connect(function()
                          {
                              console.log("You chose: " + dialogTime.timeText)

                              updateDateTime(nowDate, dialogTime.timeText + ":00")
                          })

                }
                Component
                {
                    id: pickerTime
                    TimePickerDialog {}
                }

            }
        }

        SectionHeader
        {
            text: "Value"
        }

        TextField
        {
            id: valueField
            focus: true
            width: parent.width
            label: "Value"
            font.pointSize: Theme.fontSizeExtraLarge
            color: Theme.primaryColor
            placeholderText: "Enter new value here"
            onTextChanged: page.canAccept = text.length > 0
            inputMethodHints: Qt.ImhDigitsOnly
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: page.accept()
        }

    }


}
