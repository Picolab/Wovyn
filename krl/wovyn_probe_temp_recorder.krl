ruleset wovyn_probe_temp_recorder {
  meta {
    shares __testing
  }
  global {
    __testing = {
      "queries": [ { "name": "__testing" } ],
      "events": [
        { "domain": "probe_temp_recorder", "type": "new_url", "attrs": ["url"] },
        { "domain": "probe_temp_recorder", "type": "new_month_url", "attrs": [ "month", "url" ] }
      ] }
    makeMT = function(ts){
      MST = time:add(ts,{"hours": -7});
      MDT = time:add(ts,{"hours": -6});
      MDT > "2019-11-03T02" => MST |
      MST > "2019-03-10T02" => MDT |
                               MST
    }
  }
  rule set_up_url {
    select when probe_temp_recorder new_url url re#^(http.*)# setting(url)
    fired {
      ent:url := url;
      ent:urlInEffectSince := time:now()
    }
  }
  rule set_up_month_url {
    select when probe_temp_recorder new_month_url
      month re#^(20\d\d-\d\d)$# url re#^(http.*)# setting(month,url)
    fired {
      ent:monthURL := ent:monthURL.defaultsTo({}).put(month,url)
    }
  }
  rule check_for_new_month {
    select when wovyn new_temperature_reading
    pre {
      latest_month = ent:latestMonth.defaultsTo("2019-01")
      this_month = makeMT(event:attr("timestamp")).substr(0,7)
      new_month = this_month > latest_month
      new_url = ent:monthURL{this_month}
    }
    if new_month && new_url then noop()
    fired {
      raise probe_temp_recorder event "new_url" attributes { "url": new_url }
    }
  }
  rule record_probe_temp_to_sheet {
    select when wovyn new_temperature_reading where ent:url
    pre {
      temperatureData = event:attr("readings")
      temperatureF = temperatureData[0]{"temperatureF"}
      timestamp = makeMT(event:attr("timestamp"));
      data = {"timestamp": time:strftime(timestamp, "%F %T"),
              "temperature": temperatureF,
              "tabName": timestamp.substr(0,10)}
    }
    http:post(ent:url,qs=data) setting(response)
    fired {
      ent:lastData := data;
      ent:lastResponse := response;
      ent:latestMonth := timestamp.substr(0,7);
      raise wovyn event "probe_temp_recorded_to_sheet" attributes event:attrs()
    }
  }
}
