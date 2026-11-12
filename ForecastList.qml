import QtQuick
import qs.Commons
import qs.Ui

// Vertical forecast list: one row per day, icon + day name on the left,
// hi/lo on the right. Used for the main forecast and the secondary one.
// `panel` is the weather Panel, which owns dayName/dayIcon/bareTempForDay.
Column {
  id: root
  required property var days
  required property var panel

  spacing: Style.space(8)

  Repeater {
    model: root.days

    Item {
      required property var modelData
      width: root.width
      height: dayContent.height

      Row {
        id: dayContent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(10)

        Text {
          textFormat: Text.PlainText
          anchors.verticalCenter: parent.verticalCenter
          text: root.panel.dayIcon(modelData)
          color: root.panel.bar.foreground
          font.family: root.panel.bar.fontFamily
          font.pixelSize: Style.font.display
        }

        Text {
          textFormat: Text.PlainText
          anchors.verticalCenter: parent.verticalCenter
          text: root.panel.dayName(modelData.date).toUpperCase()
          color: Qt.darker(root.panel.bar.foreground, 1.4)
          font.family: root.panel.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 1
        }
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(6)

        Text {
          textFormat: Text.PlainText
          text: root.panel.bareTempForDay(modelData, "max")
          color: root.panel.bar.foreground
          font.family: root.panel.bar.fontFamily
          font.pixelSize: Style.font.body
        }
        Text {
          textFormat: Text.PlainText
          text: root.panel.bareTempForDay(modelData, "min")
          color: Qt.darker(root.panel.bar.foreground, 1.5)
          font.family: root.panel.bar.fontFamily
          font.pixelSize: Style.font.body
        }
      }
    }
  }
}
