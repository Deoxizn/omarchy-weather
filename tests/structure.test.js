"use strict"

const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")

function read(name) {
  return fs.readFileSync(path.join(__dirname, "..", name), "utf8")
}

test("the manifest declares the Nyxiri weather bar widget", () => {
  const manifest = JSON.parse(read("manifest.json"))
  assert.equal(manifest.id, "pizza.dirty.weather")
  assert.deepEqual(manifest.kinds, ["bar-widget"])
  assert.equal(manifest.entryPoints.barWidget, "BarWidget.qml")
  assert.equal(manifest.barWidget.allowMultiple, false)
})

test("the widget writes weather settings through updateEntryInline", () => {
  const widget = read("BarWidget.qml")
  // The bar's settings window writes to the same entry id, so the two
  // stay in sync. The id is the manifest id, pizza.dirty.weather, which
  // is also this widget's moduleName since the Hexciri rename.
  assert.match(widget, /function setWeather\(patch\)/)
  assert.match(widget, /var entry = \{ id: "pizza\.dirty\.weather" \}/)
  assert.match(widget, /root\.bar\.shell\.updateEntryInline\("pizza\.dirty\.weather", entry\)/)
  assert.match(widget, /for \(var key in current\) if \(key !== "id"\) entry\[key\] = current\[key\]/)
  assert.match(widget, /for \(var patchName in patch\) entry\[patchName\] = patch\[patchName\]/)
})

test("right-click opens the standalone settings window", () => {
  const widget = read("BarWidget.qml")
  assert.match(widget, /property bool settingsOpen: false/)
  assert.match(widget, /function toggleSettings\(\)/)
  assert.match(widget, /root\.settingsOpen = !root\.settingsOpen/)
  assert.match(widget, /WeatherSettings \{/)
  assert.match(widget, /visible: root\.settingsOpen/)
  assert.match(widget, /if \(b === Qt\.RightButton\) \{ root\.toggleSettings\(\); return \}/)
  // Right-click no longer sends the weather-status notification.
  assert.doesNotMatch(widget, /omarchy-weather-status/)
  // Left-click still toggles the forecast panel, middle-click refreshes.
  assert.match(widget, /else if \(b === Qt\.MiddleButton\) root\.refresh\(\)/)
  assert.match(widget, /else root\.togglePanel\(\)/)
})

test("the standalone settings window mirrors the Weather tab", () => {
  const settings = read("WeatherSettings.qml")
  assert.match(settings, /PanelWindow \{/)
  assert.match(settings, /WlrLayershell\.namespace: "pizza\.dirty\.weather-settings"/)
  assert.match(settings, /SectionLabel \{ text: "WEATHER" \}/)
  assert.match(settings, /SubLabel \{ text: "Secondary location" \}/)
  assert.match(settings, /settingText: popup\.weatherSetting\("secondaryLocation", ""\)/)
  assert.match(settings, /placeholderText: "Tucson"/)
  assert.match(settings, /onCommit: function\(value\) \{ popup\.setWeather\(\{ secondaryLocation: value \}\) \}/)
  assert.match(settings, /A second city shown under the main forecast\. Leave empty for none\./)
  assert.match(settings, /function weatherSetting\(name, fallback\)/)
  assert.match(settings, /hostWidget \? hostWidget\.setting\(name, fallback\) : fallback/)
  assert.match(settings, /function setWeather\(patch\)/)
  assert.match(settings, /hostWidget\.setWeather\(patch\)/)
  assert.match(settings, /text: "Close"/)
  assert.match(settings, /sequence: "Escape"/)
  assert.match(settings, /mask: Region \{ item: windowBody \}/)
})
