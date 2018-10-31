ruleset wovyn_recorder {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ { "domain": "recorder", "type": "new_url", "attrs": ["url"] } ] }
  }
  rule set_up_url {
    select when recorder new_url
    pre {
      url = event:attr("url")
    }
    if url then noop();
    fired {
      ent:url := url
    }
  }
  rule record_co2_level_to_sheet {
    select when wovyn co2_level_recorded
    pre {
      ts = time:strftime(event:attr("timestamp"), "%F %T");
      data = {"timestamp": ts, "concentration": event:attr("concentration")}
    }
    if ent:url then http:post(ent:url,qs=data) setting(response)
    fired {
      ent:lastData := data;
      ent:lastResponse := response;
      raise wovyn event "co2_level_recorded_to_sheet" attributes event:attrs()
    }
  }
}
