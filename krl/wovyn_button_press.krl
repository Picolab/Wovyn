ruleset wovyn_button_press {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }

  // catch and record button presses
  rule record_button_press {
    select when wovyn quadButton
    pre {
      data = event:attrs()["genericThing"]["data"]["button"][0];
      button = data["color"];
      status = data["statusText"];
      time = data["pressTime"];
    }
    fired {
      ent:lastHeartbeat := event:attrs();
      ent:lastTimestamp := time:now();
      raise wovyn event "buttonTriggered"
        attributes {"button": button, "status": status, "time": time}
    } 
  }

  // act on button
  rule button_forwarder {
    select when wovyn buttonTriggered
    pre {
      button = event:attr("button");
      status = event:attr("statusText");
      time = event:attr("pressTime");
    }
    send_directive("Button Data", event:attrs());
    fired {
      
    } 
  }
}
