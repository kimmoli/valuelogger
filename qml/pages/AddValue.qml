import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: addValuePage

    canAccept: false

    property string parameterName: "value"
    property string parameterDescription: "value"
    property string pageTitle: "value"  /* Add or Edit*/
    property string value: "value"
    property string nowDate: "value"
    property string nowTime: "value"

    Component.onCompleted:
    {
        /* Check are we adding new, or editing existing one */
        if (nowDate == "value" && nowTime == "value" && value == "value")
        {
            var tmp = new Date()
            updateDateTime(Qt.formatDateTime(tmp, "yyyy-MM-dd"), Qt.formatDateTime(tmp, "hh:mm:ss"))
            pageTitle = qsTr("Add")
        }
        else
        {
            updateDateTime(nowDate, nowTime)
            valueField.text = value
            pageTitle = qsTr("Edit")
        }
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
            value = valueField.text.replace(",",".")
        }
    }

    DialogHeader
    {
        id: pageHeader
        title: pageTitle + qsTr(" value")
        acceptText: pageTitle
        cancelText: qsTr("Cancel")
    }

    Column
    {
        id: col
        spacing: Theme.paddingSmall
        width: addValuePage.width
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
            text: qsTr("Timestamp")
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
                               // use date, as dateText return varies
                               var d = dialogDate.date
                               updateDateTime(Qt.formatDateTime(new Date(d), "yyyy-MM-dd"), nowTime)
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
            text: qsTr("Value")
        }

        TextField
        {
            id: valueField
            focus: true
            width: parent.width
            label: qsTr("Value")
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.primaryColor
            placeholderText: qsTr("Enter new value here")
            onTextChanged: addValuePage.canAccept = text.length > 0
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegExpValidator { regExp: /-?\d+([,|\.]?\d+)?/ }
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: addValuePage.accept()
        }

    }


}
