# My Weather

Weather pill with a detail popup. A fork of stock `omarchy.weather`,
renamed `devi.weather`.

## Install

```sh
omarchy plugin add https://github.com/Deoxizn/omarchy-weather.git --enable
omarchy restart shell
```

If you installed it from local files instead of GitHub, remove it first so
it tracks the repo:

```sh
omarchy plugin remove devi.weather
omarchy plugin add https://github.com/Deoxizn/omarchy-weather.git --enable
```

## Location

The main location is automatic: your network's city, detected by
geo.omarchy.org. To pin a place instead:

```sh
omarchy weather location --set "Sierra Vista"
omarchy weather location --set "Malibu" 34.0259,-118.7798
omarchy weather location --clear   # back to auto-detect
```

The pin is saved to `~/.local/state/omarchy/settings/weather.json`. You
can also click the location name in the popup to search for a city. If
geo.omarchy.org is unreachable, the widget falls back to wttr.in's own
IP lookup.

## Forecast

The popup shows a 10-day forecast in one horizontal row: one column per
day, with the day, the condition icon, and the high above the low. The
high sits above the low because three-digit temps don't fit side by side
in a narrow column.

Click the pill to open the popup. Middle-click refreshes. Right-click
sends the full weather as a notification.

## Secondary location

A second city shown under the main forecast, with its own temperature
and 10-day row. Set it in the Nyxiri settings card, **Appearance** tab,
**WEATHER** section, **Secondary location** field: a name (`Tucson`) or
`lat,lon` (`32.22,-110.97`). Leave it empty for no secondary location.

It fetches on its own, so a slow second city never blocks the main view.

## Settings

```sh
omarchy bar set devi.weather unit imperial
omarchy bar set devi.weather refreshMinutes 30 --json
omarchy bar set devi.weather secondaryLocation Tucson
```

- **unit** — `imperial` or `metric`. Empty means automatic: imperial for
  the US, Liberia, and Myanmar, metric everywhere else.
- **refreshMinutes** — how often the weather refreshes, default 15.
  Minimum 1.
- **secondaryLocation** — a second city, a name or `lat,lon`. Empty means
  none.

## Tests

```sh
./test.sh
```

`Model.js` is pure logic (location parsing, forecast math, unit and
temperature helpers) and is exercised by real node tests; the QML is
checked structurally.
