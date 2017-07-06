ruleset wovyn_battery_readings {
  meta {
    shares __testing, readings
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "readings" } ],
                  "events": [ ] }
    readings = function() {
      ent:batteryReadings
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
