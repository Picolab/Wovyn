ruleset wovyn_version {
  meta {
    shares __testing, version
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "version" } ],
                  "events": [ ] }
    version = function() {
      { "make": ent:make, "model": ent:model, "firmwareVersion": ent:firmwareVersion }
    }
  }
  rule check_version {
    select when wovyn heartbeat
    pre {
      specificThing = event:attr("specificThing");
      make = specificThing{"make"};
      model = specificThing{"model"};
      firmwareVersion = specificThing{"firmwareVersion"};
    }
    if make != ent:make || model != ent:model || firmwareVersion != ent:firmwareVersion
      then noop();
    fired {
      raise wovyn event "thing_changed" attributes event:attrs;
      raise wovyn event "firmware_updated" attributes
        version().put("new_firmwareVersion", firmwareVersion)
        if make == ent:make && model == ent:model;
      ent:make := make;
      ent:model := model;
      ent:firmwareVersion := firmwareVersion;
    }
  }
}
