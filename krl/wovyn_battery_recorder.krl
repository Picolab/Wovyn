ruleset wovyn_battery_recorder {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ { "domain": "recorder", "type": "new_url", "attrs": ["url"] } ] }
  }
  rule set_up_url {
    select when recorder new_url url re#^(http.*)# setting(url)
    fired {
      ent:url := url;
      ent:urlInEffectSince := time:now()
    }
  }
  rule record_battery_levels_to_sheet {
    select when wovyn new_battery_reading where ent:url
    pre {
      ts = time:strftime(time:now(), "%F %T");
      data = {"timestamp": ts,
              "voltage": event:attr("currentVoltage"),
              "health": event:attr("healthPercent")}
    }
    http:post(ent:url,qs=data) setting(response)
    fired {
      ent:lastData := data;
      ent:lastResponse := response;
      raise wovyn event "battery_levels_recorded_to_sheet" attributes event:attrs()
    }
  }
}
