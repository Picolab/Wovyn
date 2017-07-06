ruleset wovyn_battery {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }
  rule receive_heartbeat {
    select when wovyn heartbeat
    pre {
      sensor_data = event:attrs()
      battery = sensor_data{["specificThing","battery"]}
      health = { "healthPercent": sensor_data{["genericThing","healthPercent"]} }
      combined = battery.put(health)
    }
    always {
      ent:lastBattery := combined;
      raise wovyn event "new_battery_reading" attributes combined
    }
  }
}
