import QtQuick
import qs.Commons
import qs.Ui

// Horizontal forecast: one compact column per day (day abbrev, icon, hi,
// lo stacked), laid out in a single row. The columns share the width
// evenly, so ten days fit the popup. Hi sits above lo because Arizona
// three-digit temps ("102° 98°") don't fit side by side in a narrow
// column. Used for the main forecast and the secondary one.
// `panel` is the weather Panel, which owns dayAbbrev/dayIcon/bareTempForDay.
Row {
  id: root
  required property var days
  required property var panel

  spacing: Style.space(4)

  Repeater {
    model: root.days

    Column {
      required property var modelData
      width: (root.width - root.spacing * (root.days.length - 1)) / Math.max(1, root.days.length)
      spacing: Style.space(2)

      Text {
        textFormat: Text.PlainText
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.panel.dayAbbrev(modelData.date).toUpperCase()
        color: Qt.darker(root.panel.bar.foreground, 1.4)
        font.family: root.panel.bar.fontFamily
        font.pixelSize: Style.font.caption
        font.letterSpacing: 1
      }

      Text {
        textFormat: Text.PlainText
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.panel.dayIcon(modelData)
        color: root.panel.bar.foreground
        font.family: root.panel.bar.fontFamily
        font.pixelSize: Style.font.display
      }

      Text {
        textFormat: Text.PlainText
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.panel.bareTempForDay(modelData, "max")
        color: root.panel.bar.foreground
        font.family: root.panel.bar.fontFamily
        font.pixelSize: Style.font.body
      }

      Text {
        textFormat: Text.PlainText
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.panel.bareTempForDay(modelData, "min")
        color: Qt.darker(root.panel.bar.foreground, 1.5)
        font.family: root.panel.bar.fontFamily
        font.pixelSize: Style.font.body
      }
    }
  }
}
