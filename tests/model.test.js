"use strict"

const assert = require("node:assert/strict")
const test = require("node:test")
const Model = require("../Model.js")

// Build an Open-Meteo daily report with `count` future days starting
// tomorrow, each with a distinct max/min so the cap is observable.
function openMeteoReport(count, today) {
  var time = []
  var max = []
  var min = []
  var code = []
  var base = new Date(today + "T12:00:00")
  for (var i = 0; i <= count; i++) {
    var d = new Date(base)
    d.setDate(d.getDate() + i)
    time.push(d.toISOString().slice(0, 10))
    max.push(20 + i)
    min.push(10 + i)
    code.push(0)
  }
  return {
    daily: { time: time, temperature_2m_max: max, temperature_2m_min: min, weather_code: code },
    current: { temperature_2m: 22, apparent_temperature: 21, relative_humidity_2m: 40, wind_speed_10m: 10, weather_code: 0, is_day: 1 }
  }
}

test("openMeteoForecastDays returns ten future days, not three", () => {
  var days = Model.openMeteoForecastDays(openMeteoReport(12, "2026-11-12"), "2026-11-12")
  assert.equal(days.length, 10)
  assert.equal(days[0].date, "2026-11-13")
  assert.equal(days[9].date, "2026-11-22")
  assert.equal(days[0].maxtempC, "21")
  assert.equal(days[9].maxtempC, "30")
})

test("openMeteoForecastDays returns fewer when the feed is short", () => {
  var days = Model.openMeteoForecastDays(openMeteoReport(4, "2026-11-12"), "2026-11-12")
  assert.equal(days.length, 4)
})

test("wttrNextForecastDays caps at ten", () => {
  var report = { weather: [] }
  var base = new Date("2026-11-12T12:00:00")
  for (var i = 0; i < 12; i++) {
    var d = new Date(base)
    d.setDate(d.getDate() + i + 1)
    report.weather.push({ date: d.toISOString().slice(0, 10) })
  }
  assert.equal(Model.wttrNextForecastDays(report, "2026-11-12").length, 10)
})

test("buildForecastDays prefers Open-Meteo and returns ten", () => {
  var days = Model.buildForecastDays({ weather: [] }, openMeteoReport(12, "2026-11-12"), "2026-11-12")
  assert.equal(days.length, 10)
  assert.equal(days[0].date, "2026-11-13")
})

test("parseSecondaryLocation takes a place name", () => {
  assert.deepEqual(Model.parseSecondaryLocation("Tucson"), { name: "Tucson", latitude: null, longitude: null })
  assert.deepEqual(Model.parseSecondaryLocation("  Tucson, AZ  "), { name: "Tucson, AZ", latitude: null, longitude: null })
})

test("parseSecondaryLocation takes coordinates", () => {
  assert.deepEqual(Model.parseSecondaryLocation("32.22,-110.97"), { name: "", latitude: 32.22, longitude: -110.97 })
  assert.deepEqual(Model.parseSecondaryLocation(" 32.2217 , -110.9265 "), { name: "", latitude: 32.2217, longitude: -110.9265 })
})

test("parseSecondaryLocation returns unset for empty", () => {
  assert.deepEqual(Model.parseSecondaryLocation(""), { name: "", latitude: null, longitude: null })
  assert.deepEqual(Model.parseSecondaryLocation("   "), { name: "", latitude: null, longitude: null })
  assert.deepEqual(Model.parseSecondaryLocation(null), { name: "", latitude: null, longitude: null })
})

test("wttrLocationQuery covers the secondary shapes", () => {
  assert.equal(Model.wttrLocationQuery("Tucson", null, null), "Tucson")
  assert.equal(Model.wttrLocationQuery("", 32.22, -110.97), "32.22,-110.97")
  assert.equal(Model.wttrLocationQuery("", null, null), "")
})

test("the manifest id is pizza.dirty.weather", () => {
  const manifest = JSON.parse(require("fs").readFileSync(require("path").join(__dirname, "..", "manifest.json"), "utf8"))
  assert.equal(manifest.id, "pizza.dirty.weather")
})
