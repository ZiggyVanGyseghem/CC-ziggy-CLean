# InfluxDB Flux Queries (Time-Series Aggregations)

This file documents the Flux 2.0 queries configured for the automated InfluxDB dashboard and time-series visualization.

---

## 1. 1-Hour Moving Mean Average

Calculates the mean average joystick magnitude over the past 1 hour in 5-minute aggregation windows.

```flux
from(bucket: "sensor_data")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "joystick")
  |> filter(fn: (r) => r["_field"] == "magnitude")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> yield(name: "mean_1h")
```

---

## 2. 24-Hour Moving Mean Average

Calculates the mean average joystick magnitude over the past 24 hours in 1-hour aggregation windows.

```flux
from(bucket: "sensor_data")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "joystick")
  |> filter(fn: (r) => r["_field"] == "magnitude")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
  |> yield(name: "mean_24h")
```
