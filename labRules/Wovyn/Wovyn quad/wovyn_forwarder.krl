ruleset wovyn_forwarder {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
    ip = "34.194.35.179" // was using DNS ec2.bruceatbyu.com
    sky_event = <<http://#{ip}:3000/sky/event/>>
  }

  rule forward_quad_heartbeat {
    select when wovyn heartbeat
      where property{"name"} == "Wovyn_0EC86F"
    pre {
      sensor_data = event:attrs.delete("_headers")
    }
    http:post(sky_event+"cixthvab70000y8qy8wu3js6g/fhb/wovyn/heartbeat",
      json = sensor_data) setting(response)
    always {
      ent:latestQuadResponse := response
    }
  }
  rule forward_co2_heartbeat {
    select when wovyn heartbeat
      where property{"name"} == "Wovyn_2BD53F"
    pre {
      sensor_data = event:attrs.delete("_headers")
    }
    http:post(sky_event+"cj20snsmr0002ekqy92q64z3c/fhb/wovyn/heartbeat",
      json = sensor_data) setting(response)
    always {
      ent:latestCO2Response := response
    }
  }
  rule forward_lux_heartbeat {
    select when wovyn light
      where event:attr("property"){"name"} == "Wovyn_104485"
    pre {
      sensor_data = event:attrs.delete("_headers")
    }
    http:post(sky_event+"cjka862ob0x3qe6qy65bvzlvn/fhb/wovyn/light",
      json = sensor_data) setting(response)
    always {
      ent:latestLuxResponse := response
    }
  }
}
