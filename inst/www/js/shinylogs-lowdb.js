/*!
 * Copyright (c) 2018 dreamRs
 *
 * shinylogs, JavaScript bindings to record
 * everything happens in a Shiny app
 * using Lowdb
 * https://github.com/dreamRs/shinylogs
 *
 * @version 0.0.1
 */
// on unload or not
var logsonunload = false;

// config
var config = document.querySelectorAll('script[data-for="shinylogs"]');

config = JSON.parse(config[0].innerHTML);

//console.log(config);

logsonunload = config.logsonunload;

//console.log(logsonunload);
var re_ex_in = RegExp("^$");

if (config.hasOwnProperty("excludeinput")) {
  re_ex_in = RegExp(config.excludeinput);
}

// lowdb init
var adapter = new LocalStorage("db");

var db = low(adapter);

db.setState({});

// initialize local data storage
db.defaults({
  input: [],
  error: [],
  output: []
}).write();

// User Agent
var ua = window.navigator.userAgent;

// Screen resolution
var screen_res = window.screen.width + "x" + window.screen.height;

// Browser resolution
var w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;

var h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;

var browser_res = w + "x" + h;

// Pixel ratio
var pixel_ratio = window.devicePixelRatio;

// Timestamp browser
var browser_connected = dayjs().format();

// Send browser data
if (logsonunload === false) {
  Shiny.setInputValue(".shinylogs_browserData", {
    user_agent: ua,
    screen_res: screen_res,
    browser_res: browser_res,
    pixel_ratio: pixel_ratio,
    browser_connected: browser_connected
  }, {
    priority: "event"
  });
}

// Shiny input event to not track
var dont_track = [ ".shinylogs_lastInput", ".shinylogs_input", ".shinylogs_error", ".shinylogs_output", ".shinylogs_browserData" ];

var regex_hidden = RegExp("hidden$");

// Track INPUTS
$(document).on("shiny:inputchanged", function(event) {
  //console.log(event);
  if (dont_track.indexOf(event.name) == -1 & regex_hidden.test(event.name) === false & re_ex_in.test(event.name) === false) {
    //console.log(event);
    var lastInput = {
      name: event.name,
      timestamp: dayjs(event.timeStamp).format(),
      value: event.value,
      type: event.inputType,
      binding: event.binding !== null ? event.binding.name : ''
    };
    db.get("input").push(lastInput).write();
    if (logsonunload === false) {
      Shiny.setInputValue(".shinylogs_lastInput:parse_lastInput", lastInput);
      var input_ = db.get("input").value();
      input_ = JSON.stringify(input_);
      Shiny.setInputValue(".shinylogs_input:parse_log", {
        inputs: input_
      }, {
        priority: "event"
      });
    }
  }
});

// Track ERRORS
$(document).on("shiny:error", function(event) {
  //console.log(event);
  if (dont_track.indexOf(event.name) == -1) {
    var lastError = {
      name: event.name,
      timestamp: dayjs(event.timeStamp).format(),
      error: event.error.message
    };
    db.get("error").push(lastError).write();
    if (logsonunload === false) {
      var error_ = db.get("error").value();
      error_ = JSON.stringify(error_);
      Shiny.setInputValue(".shinylogs_error:parse_log", {
        errors: error_
      });
    }
  }
});

// Track OUTPUTs
$(document).on("shiny:value", function(event) {
  //console.log(event);
  var lastOutput = {
    name: event.name,
    timestamp: dayjs(event.timeStamp).format(),
    binding: event.binding.binding.name
  };
  db.get("output").push(lastOutput).write();
  if (logsonunload === false) {
    var output_ = db.get("output").value();
    output_ = JSON.stringify(output_);
    Shiny.setInputValue(".shinylogs_output:parse_log", {
      outputs: output_
    });
  }
});

if (logsonunload === true) {
  window.onbeforeunload = function(e) {
    var e = e || window.event;
    // For IE and Firefox
    if (e) {
      e.returnValue = "Are you sure?";
    }
    var input_ = db.get("input").value();
    input_ = JSON.stringify(input_);
    Shiny.setInputValue(".shinylogs_input:parse_log", {
      inputs: input_
    }, {
      priority: "event"
    });
    var error_ = db.get("error").value();
    error_ = JSON.stringify(error_);
    Shiny.setInputValue(".shinylogs_error:parse_log", {
      errors: error_
    });
    var output_ = db.get("output").value();
    output_ = JSON.stringify(output_);
    Shiny.setInputValue(".shinylogs_output:parse_log", {
      outputs: output_
    });
    Shiny.setInputValue(".shinylogs_browserData", {
      user_agent: ua,
      screen_res: screen_res,
      browser_res: browser_res,
      pixel_ratio: pixel_ratio,
      browser_connected: browser_connected
    });
    return "Are you sure?";
  };
}
