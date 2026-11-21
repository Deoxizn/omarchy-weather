# My Weather

Weather in the bar. Click it for the 10-day forecast.

## Install

```sh
omarchy plugin add https://github.com/Deoxizn/omarchy-weather.git --enable
omarchy restart shell
```

## Use it

- Click the pill: opens the forecast popup.
- Middle-click: refresh now.
- Right-click: open settings.
- Click the place name in the popup: search for a city.

## Location

It finds your city on its own. To pin one instead:

```sh
omarchy weather location --set "Sierra Vista"
omarchy weather location --set "Malibu" 34.0259,-118.7798
omarchy weather location --clear
```

`--clear` goes back to auto-detect.

## Second city

A second city under the main forecast, with its own 10-day row. Set **Secondary location** to a name (`Tucson`) or `lat,lon` (`32.22,-110.97`): right-click the pill to open the standalone settings popup, or use the bar settings window's Weather tab. Leave it empty for none.

## Settings

```sh
omarchy bar set pizza.dirty.weather unit imperial
omarchy bar set pizza.dirty.weather refreshMinutes 30 --json
omarchy bar set pizza.dirty.weather secondaryLocation Tucson
```

- **unit** — `imperial` or `metric`. Empty means auto: imperial in the US, Liberia, and Myanmar, metric everywhere else.
- **refreshMinutes** — how often it refreshes, default 15. Minimum 1.
- **secondaryLocation** — second city, a name or `lat,lon`. Empty means none.
