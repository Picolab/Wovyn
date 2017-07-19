ruleset wovyn_fwd_module {
  meta {
    provides forward
    configure using protocol = "http://"
                        host = "localhost:8080"
                         eci = ""
                         eid = "fhb"
  }
  global {
    forward = defaction(heartbeat) {
      url = <<#{protocol}#{host}/sky/event/#{eci}/#{eid}/wovyn/heartbeat>>
      http:post(url, json = heartbeat) setting(response)
    }
  }
}
