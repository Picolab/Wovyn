ruleset wovyn_probe_temp_recorder {
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
  rule record_probe_temp_to_sheet {
    select when wovyn new_temperature_reading where ent:url
    pre {
      temperatureData = event:attr("readings")
      temperatureF = temperatureData[0]{"temperatureF"}
      timestamp = event:attr("timestamp");
      data = {"timestamp": time:strftime(timestamp, "%F %T"),
              "temperature": temperatureF,
              "tabName": timestamp.substr(0,10)}
    }
    http:post(ent:url,qs=data) setting(response)
    fired {
      ent:lastData := data;
      ent:lastResponse := response;
      raise wovyn event "probe_temp_recorded_to_sheet" attributes event:attrs()
    }
  }
}
