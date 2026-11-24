import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "pizza.dirty.weather"

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function refresh() {
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  // Shape contract for shell.summon/hide/toggle routing (Bar.findPanelWidget
  // requires open/close/opened on the bar-widget root). Open maps to the
  // panel's hotkey path so summoning suppresses the center hover reveal,
  // matching what the old per-plugin IpcHandler did.
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.openFromHotkey) panelLoader.item.openFromHotkey()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

  // Forwarded so this widget can stand in for the panel as the bar's popout
  // identity: Bar.requestPopout prefers closeForPopoutSwitch over close, and
  // KeyboardPanel reads popoutSwitchClosing back off its owner.
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  // Write the weather settings the same way the bar's settings window
  // does: updateEntryInline replaces rather than merges, so the existing
  // settings are copied first and the patch applied on top. The shell.json
  // write comes back through the bar as the same value, so the bar's
  // window and the standalone popup stay in sync: both write to the same
  // layout entry. The id is the manifest id, pizza.dirty.weather, which
  // is now also this widget's moduleName (renamed from omarchy.weather).
  function setWeather(patch) {
    if (!root.bar || !root.bar.shell || typeof root.bar.shell.updateEntryInline !== "function") return false
    var entry = { id: "pizza.dirty.weather" }
    var current = root.settings || {}
    for (var key in current) if (key !== "id") entry[key] = current[key]
    for (var patchName in patch) entry[patchName] = patch[patchName]
    root.settings = entry
    return root.bar.shell.updateEntryInline("pizza.dirty.weather", entry)
  }

  // Standalone settings: right-click the weather widget opens the
  // WeatherSettings window. It is the same controls as the bar's settings
  // window Weather tab, so the plugin is usable on its own (stock bar, no
  // Nyxiri bar), where there is no bar settings window.
  property bool settingsOpen: false

  function toggleSettings() {
    root.settingsOpen = !root.settingsOpen
  }

  visible: panelLoader.item && panelLoader.item.label !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  // The standalone settings window, one per bar surface. It opens on
  // right-click and closes from its own Close button or Escape.
  WeatherSettings {
    bar: root.bar
    hostWidget: root
    visible: root.settingsOpen
    screen: {
      var window = root.QsWindow.window
      return window ? window.screen : null
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: panelLoader.item ? panelLoader.item.label : ""
    labelText: panelLoader.item && panelLoader.item.reportTempNum !== "" && !root.vertical ? panelLoader.item.reportTempNum + panelLoader.item.tempUnit : ""
    // Fixed 72px, not measured: the icon + temp run fills the stock 54px
    // slot edge to edge ("no padding at the ends"), so 72 leaves ~7px of
    // pill past the glyphs on each side and still covers a 3-digit temp.
    // The 120px test proved slotSize drives the width; the measured
    // TextMetrics versions never showed a change, so no measuring here.
    slotSize: panelLoader.item && panelLoader.item.reportTempNum !== "" && !root.vertical ? 72 : Style.bar.statusSlot
    // Tooltip suppressed because the panel is the detail view.
    tooltipText: ""

    onPressed: function(b) {
      if (!root.bar) return
      // Right-click opens the standalone settings window; it no longer
      // sends the weather-status notification.
      if (b === Qt.RightButton) { root.toggleSettings(); return }
      else if (b === Qt.MiddleButton) root.refresh()
      else root.togglePanel()
    }
  }
}
