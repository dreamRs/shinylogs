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


// config
var config = document.querySelectorAll('script[data-for="shinylogs"]');

if (config.length > 0) {
  config = JSON.parse(config[0].innerHTML);
} else {
  config = {logsonunload: false};
}

//console.log(config);

var logsonunload = config.logsonunload;

//console.log(logsonunload);
var inputRE = RegExp("^$");

if (config.hasOwnProperty("exclude_input_regex")) {
  inputRE = RegExp(config.exclude_input_regex);
}

//Initialize localForage instance
var logsinputs = localforage.createInstance({
  name: "inputs", storeName: config.sessionid
});
var logsoutputs = localforage.createInstance({
  name: "outputs", storeName: config.sessionid
});
var logserrors = localforage.createInstance({
  name: "errors", storeName: config.sessionid
});


// ** session infos **//
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
var dontTrack = [ ".shinylogs_lastInput", ".shinylogs_input", ".shinylogs_error", ".shinylogs_output", ".shinylogs_browserData" ];
if (config.hasOwnProperty("exclude_input_id")) {
  dontTrack = dontTrack.concat(config.exclude_input_id);
}

var hiddenRE = RegExp("hidden$");

// Track INPUTS
$(document).on("shiny:inputchanged", function(event) {
  //console.log(event);
  if (dontTrack.indexOf(event.name) == -1 & hiddenRE.test(event.name) === false & inputRE.test(event.name) === false) {
    //console.log(event);
    var ts = dayjs(event.timeStamp).format();
    var alea = Math.floor(Math.random() * 10000);
    var lastInput = {
      name: event.name,
      timestamp: ts,
      value: event.value,
      type: event.inputType,
      binding: event.binding !== null ? event.binding.name : ''
    };
    Shiny.setInputValue(".shinylogs_lastInput:parse_lastInput", lastInput);
    logsinputs.setItem(ts + '_' + alea, lastInput).then(function(value) {
      if (logsonunload === false) {
        logsinputs.getItems(null, function(err, value) {
          Shiny.setInputValue(".shinylogs_input:parse_log", {inputs: JSON.stringify(value)});
        });
      }
    });
  }
});

// Track ERRORS
$(document).on("shiny:error", function(event) {
  //console.log(event);
  var ts = dayjs(event.timeStamp).format();
  var alea = Math.floor(Math.random() * 10000);
  var lastError = {
    name: event.name,
    timestamp: ts,
    error: event.error.message
  };
  logserrors.setItem(ts + '_' + alea, lastError).then(function(value) {
    if (logsonunload === false) {
      logserrors.getItems(null, function(err, value) {
        Shiny.setInputValue(".shinylogs_error:parse_log", {errors: JSON.stringify(value)});
      });
    }
  });
});

// Track OUTPUTs
$(document).on("shiny:value", function(event) {
  //console.log(event);
  var ts = dayjs(event.timeStamp).format();
  var alea = Math.floor(Math.random() * 10000);
  var lastOutput = {
    name: event.name,
    timestamp: ts,
    binding: event.binding.binding.name
  };
  logsoutputs.setItem(ts + '_' + alea, lastOutput).then(function(value) {
    if (logsonunload === false) {
      logsoutputs.getItems(null, function(err, value) {
        Shiny.setInputValue(".shinylogs_output:parse_log", {outputs: JSON.stringify(value)});
      });
    }
  });
});

if (logsonunload === true) {
  window.onbeforeunload = function(e) {
    var e = e || window.event;
    // For IE and Firefox
    if (e) {
      e.returnValue = "Are you sure?";
    }
    logsoutputs.getItems(null, function(err, value) {
      Shiny.setInputValue(".shinylogs_output:parse_log", {outputs: JSON.stringify(value)});
    });
    logserrors.getItems(null, function(err, value) {
      Shiny.setInputValue(".shinylogs_error:parse_log", {errors: JSON.stringify(value)});
    });
    logsinputs.getItems(null, function(err, value) {
      Shiny.setInputValue(".shinylogs_input:parse_log", {inputs: JSON.stringify(value)});
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
