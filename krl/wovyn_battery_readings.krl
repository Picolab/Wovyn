ruleset wovyn_battery_readings {
  meta {
    shares __testing, readings, readingsCount, readingsDay
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "readings" },
                               { "name": "readingsCount" } ],
                  "events": [ ] }
    readings = function() {
      ent:batteryReadings
    }
    readingsCount = function() {
      ent:batteryReadings.length()
    }
    readingsDay = function(date) {
      entryMatchesDate = function(e) {
        e{"timestamp"}.substr(0,10) == date
      };
      csvEntry = function(e) {
        time:strftime(e{"timestamp"}, "%F %T") + ","
          + e{"currentVoltage"} + ","
          + e{"healthPercent"}
      };
      ent:batteryReadings.filter(entryMatchesDate).map(csvEntry).join(10.chr())
    }
  }

  // catch and record battery reading
  rule record_battery_reading {
    select when wovyn new_battery_reading
    pre {
      new_reading = event:attrs().put({"timestamp": time:now()})
    }
    always {
     ent:batteryReadings := ent:batteryReadings.defaultsTo([]).append(new_reading)
    }
  }

}
