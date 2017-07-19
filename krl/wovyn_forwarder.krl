ruleset wovyn_forwarder {
  rule forward_quad_heartbeat {
    select when wovyn heartbeat
      where propery{"name"} == "Wovyn_0EC86F"
    pre {
      sensor_data = event:attrs()
    }
    http:post("http://HOST/sky/event/ECI/fhb/wovyn/heartbeat",
      json = sensor_data) setting(response)
    always {
      ent:latestQuadResponse := response
    }
  }
  rule forward_co2_heartbeat {
    select when wovyn heartbeat
      where propery{"name"} == "Wovyn_2BD53F"
    pre {
      sensor_data = event:attrs()
    }
    http:post("http://HOST/sky/event/ECI/fhb/wovyn/heartbeat",
      json = sensor_data) setting(response)
    always {
      ent:latestCO2Response := response
    }
  }
}
