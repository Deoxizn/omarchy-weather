import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Standalone weather settings. A floating layer-shell window with the
// same controls as the bar's settings window Weather tab, for when the
// weather plugin runs on its own (stock Omarchy bar, no Nyxiri bar),
// where there is no bar settings window to open. Opened by
// Shift+right-clicking the weather widget (a plain right-click sends the
// weather-status notification); the widget's toggleSettings() flips it.
// The one control writes through hostWidget.setWeather(), which is the
// same updateEntryInline the bar's window uses, so the two stay in sync:
// both write to the same weather layout entry. When the bar IS installed,
// the bar's settings window is the primary UI and this is just an
// alternate door into the same settings.
PanelWindow {
  id: popup

  // `bar` is passed from the widget (the bar the widget sits on, Nyxiri
  // or stock); `hostWidget` is the weather widget root, which owns the
  // settings and the write mechanism.
  property var bar: null
  property var hostWidget: null

  // A real layer-shell surface, not a popup: it takes keyboard focus
  // natively, so the secondary location field just works. Floating: it
  // reserves no bar space, and the mask limits input to the window body
  // so clicks outside it pass through to the windows below.
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "pizza.dirty.weather-settings"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  // Close is named closeSettings, not close: PanelWindow is a QQuickWindow
  // and already has a close() method, which this must not shadow.
  function closeSettings() {
    if (hostWidget) hostWidget.settingsOpen = false
  }

  // ---------------------------------------------------------------- settings

  function weatherSetting(name, fallback) {
    return hostWidget ? hostWidget.setting(name, fallback) : fallback
  }

  function setWeather(patch) {
    if (hostWidget) hostWidget.setWeather(patch)
  }

  // ------------------------------------------------------------------- ui

  component SectionLabel: Text {
    color: Qt.darker(popup.bar.foreground, 1.35)
    font.family: popup.bar.fontFamily
    font.pixelSize: Style.font.title
    font.bold: true
    font.letterSpacing: 0.4
    textFormat: Text.PlainText
    topPadding: Style.space(16)
    bottomPadding: Style.spacing.md
  }

  // Sub-headers under a section (Secondary location): one step smaller
  // than a section header, still bigger than the old caption labels, with
  // room under them too.
  component SubLabel: Text {
    color: Qt.darker(popup.bar.foreground, 1.4)
    font.family: popup.bar.fontFamily
    font.pixelSize: Style.font.body
    font.bold: true
    textFormat: Text.PlainText
    bottomPadding: Style.spacing.sm
  }

  component BodyText: Text {
    color: popup.bar.foreground
    font.family: popup.bar.fontFamily
    font.pixelSize: Style.font.bodySmall
    textFormat: Text.PlainText
    verticalAlignment: Text.AlignVCenter
  }

  // Text input in a popup does not take keyboard focus on click by itself:
  // the click selects text but no cursor appears and keys go nowhere.
  // Stock panels force focus explicitly, deferred: forcing focus
  // synchronously during the press can run before the click has activated
  // the popup window, so it lands nowhere. This defers it the same way,
  // and lets the press through so cursor placement and selection keep
  // working. The field owns its text and only syncs from `settingText`
  // when the saved value actually changes, so typing is never clobbered
  // by an unrelated layout write. It commits on its own: 400ms after the
  // last keystroke, and immediately on Enter or focus loss, so typing
  // sticks however the window is left.
  component FocusField: TextField {
    signal commit(string value)

    property string settingText: ""
    onSettingTextChanged: {
      if (settingText !== text) text = settingText
      lastCommitted = settingText
    }

    property string lastCommitted: ""

    Component.onCompleted: lastCommitted = text

    function commitNow() {
      commitTimer.stop()
      if (text === lastCommitted) return
      lastCommitted = text
      commit(text)
    }

    Timer {
      id: commitTimer
      interval: 400
      onTriggered: commitNow()
    }

    onTextChanged: commitTimer.restart()
    onEditingFinished: commitNow()

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      onPressed: function(mouse) {
        mouse.accepted = false
        var field = parent
        Qt.callLater(function() { field.forceActiveFocus() })
      }
    }
  }

  Shortcut {
    sequence: "Escape"
    enabled: popup.visible
    onActivated: popup.closeSettings()
  }

  // The window body: a fixed-size surface centered on its screen. The
  // PanelWindow itself spans the screen (transparent) and the mask limits
  // input to this body, so clicks outside it pass through.
  BorderSurface {
    id: windowBody
    anchors.centerIn: parent
    width: Style.space(560)
    height: Style.space(600)
    radius: Style.cornerRadius
    color: popup.bar.background
    borderSpec: Border.flat(popup.bar.foreground, 1)

    Column {
      anchors.fill: parent
      anchors.margins: Style.spacing.md
      spacing: Style.spacing.sm

      Flickable {
        id: scrollArea
        width: parent.width
        height: parent.height - closeButton.height - parent.spacing
        contentWidth: width
        contentHeight: body.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
          id: body
          width: scrollArea.width
          spacing: Style.space(16)

          SectionLabel { text: "WEATHER" }

          // The weather fork's secondary location is a widget setting;
          // a name ("Tucson") or "lat,lon". Empty means no secondary.
          SubLabel { text: "Secondary location" }

          FocusField {
            width: body.width
            settingText: popup.weatherSetting("secondaryLocation", "")
            placeholderText: "Tucson"
            foreground: popup.bar.foreground
            font.family: popup.bar.fontFamily
            font.pixelSize: Style.font.body
            onCommit: function(value) { popup.setWeather({ secondaryLocation: value }) }
          }

          Text {
            width: body.width
            text: "A second city shown under the main forecast. Leave empty for none."
            color: Qt.darker(popup.bar.foreground, 1.4)
            font.family: popup.bar.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }
        }
      }

      Button {
        id: closeButton
        width: parent.width
        text: "Close"
        bordered: true
        foreground: popup.bar.foreground
        onClicked: popup.closeSettings()
      }

      BodyText {
        width: body.width
        text: "Right-click the pill sends the weather notification; Shift+right-click opens this window."
        color: Qt.darker(popup.bar.foreground, 1.4)
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }
    }
  }

  // Input goes only to the window body; the rest of the fullscreen surface
  // is transparent to the pointer.
  mask: Region { item: windowBody }
}
