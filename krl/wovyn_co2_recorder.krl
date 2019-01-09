ruleset wovyn_co2_recorder {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ { "domain": "co2_recorder", "type": "new_url", "attrs": ["url"] } ] }
  }
  rule set_up_url {
    select when co2_recorder new_url url re#^(http.*)# setting(url)
    fired {
      ent:url := url;
      ent:urlInEffectSince := time:now()
    }
  }
  rule record_co2_level_to_sheet {
    select when wovyn co2_level_recorded where ent:url
    pre {
      ts = time:strftime(event:attr("timestamp"), "%F %T");
      data = {"timestamp": ts, "concentration": event:attr("concentration")}
    }
    http:post(ent:url,qs=data) setting(response)
    fired {
      ent:lastData := data;
      ent:lastResponse := response;
      raise wovyn event "co2_level_recorded_to_sheet" attributes event:attrs()
    }
  }
}
