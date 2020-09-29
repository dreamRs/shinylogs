/*!
 * Copyright (c) 2019 dreamRs
 *
 * shinylogs, JavaScript bindings to record
 * everything happens in a Shiny app
 * using LocalForage
 * https://github.com/dreamRs/shinylogs
 *
 * @version 0.0.2
 */

/*jshint
  jquery: true
*/
/*global localforage, dayjs, Shiny */

(function() {
  // config
  var config = document.querySelectorAll('script[data-for="shinylogs"]');

  if (config.length > 0) {
    config = JSON.parse(config[0].innerHTML);
  } else {
    config = { logsonunload: false };
  }

  //console.log(config);

  var logsonunload = config.logsonunload;

  //console.log(logsonunload);
  var inputRE = RegExp("^$");

  if (config.hasOwnProperty("exclude_input_regex")) {
    inputRE = RegExp(config.exclude_input_regex);
  }

  // Initialize localForage instance
  var logsinputs = localforage.createInstance({
    name: "inputs",
    storeName: config.sessionid
  });
  var logsoutputs = localforage.createInstance({
    name: "outputs",
    storeName: config.sessionid
  });
  var logserrors = localforage.createInstance({
    name: "errors",
    storeName: config.sessionid
  });

  // Generate unique ID (from nanoid/non-secure)
  var url = "bjectSymhasOwnPropf0123456789ABCDEFGHIJKLMNQRTUVWXYZvdfgiklquvxz";
  function generateId(size) {
    size = size || 21;
    var id = "";
    while (0 < size--) {
      id += url[(Math.random() * 64) | 0];
    }
    return id;
  }

  // ** session infos **//
  // User Agent
  var ua = window.navigator.userAgent;
  // Screen resolution
  var screen_res = window.screen.width + "x" + window.screen.height;
  // Browser resolution
  var w =
    window.innerWidth ||
    document.documentElement.clientWidth ||
    document.body.clientWidth;
  var h =
    window.innerHeight ||
    document.documentElement.clientHeight ||
    document.body.clientHeight;
  var browser_res = w + "x" + h;
  // Pixel ratio
  var pixel_ratio = window.devicePixelRatio;
  // Timestamp browser
  var browser_connected = dayjs().format("YYYY-MM-DD HH:mm:ss.SSSZZ");

  // Send browser data
  if (logsonunload === false) {
    $(document).on("shiny:connected", function() {
      Shiny.setInputValue(
        ".shinylogs_browserData",
        {
          user_agent: ua,
          screen_res: screen_res,
          browser_res: browser_res,
          pixel_ratio: pixel_ratio,
          browser_connected: browser_connected
        },
        {
          priority: "event"
        }
      );
    });
  }

  // Shiny input event to not track
  var dontTrack = [
    ".shinylogs_lastInput",
    ".shinylogs_input",
    ".shinylogs_error",
    ".shinylogs_output",
    ".shinylogs_browserData",
    ".shinymanager_timeout"
  ];

  if (config.hasOwnProperty("exclude_input_id")) {
    dontTrack = dontTrack.concat(config.exclude_input_id);
  }

  var hiddenRE = RegExp("hidden$");

  // Track INPUTS
  $(document).on("shiny:inputchanged", function(event) {
    //console.log(event);
    if (
      (dontTrack.indexOf(event.name) == -1) &
      (hiddenRE.test(event.name) === false) &
      (inputRE.test(event.name) === false) &
      (event.inputType != "shiny.password")
    ) {
      //console.log(event); "shiny.password"
      var ts = dayjs(event.timeStamp).format("YYYY-MM-DD HH:mm:ss.SSSZZ");
      var inputId = "input" + generateId();
      var lastInput = {
        name: event.name,
        timestamp: ts,
        value: event.value,
        type: event.inputType,
        binding: event.binding !== null ? event.binding.name : ""
      };
      Shiny.setInputValue(".shinylogs_lastInput:parse_lastInput", lastInput);
      logsinputs.setItem(inputId, lastInput).then(function(value) {
        if (logsonunload === false) {
          logsinputs.getItems(null, function(err, value) {
            Shiny.setInputValue(".shinylogs_input:parse_logInput", {
              inputs: value
            });
          });
        }
      });
    }
  });

  // Track ERRORS
  $(document).on("shiny:error", function(event) {
    //console.log(event);
    var ts = dayjs(event.timeStamp).format("YYYY-MM-DD HH:mm:ss.SSSZZ");
    var errorId = "error" + generateId();
    var lastError = {
      name: event.name,
      timestamp: ts,
      error: event.error.message
    };
    logserrors.setItem(errorId, lastError).then(function(value) {
      if (logsonunload === false) {
        logserrors.getItems(null, function(err, value) {
          Shiny.setInputValue(".shinylogs_error:parse_logInput", {
            errors: value
          });
        });
      }
    });
  });

  // Track OUTPUTs
  $(document).on("shiny:value", function(event) {
    //console.log(event);
    var ts = dayjs(event.timeStamp).format("YYYY-MM-DD HH:mm:ss.SSSZZ");
    var outputId = "output" + generateId();
    var lastOutput = {
      name: event.name,
      timestamp: ts,
      binding: event.binding.binding.name
    };
    logsoutputs.setItem(outputId, lastOutput).then(function(value) {
      if (logsonunload === false) {
        logsoutputs.getItems(null, function(err, value) {
          Shiny.setInputValue(".shinylogs_output:parse_logInput", {
            outputs: value
          });
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
        Shiny.setInputValue(".shinylogs_output:parse_logInput", {
          outputs: value
        });
      });
      logserrors.getItems(null, function(err, value) {
        Shiny.setInputValue(".shinylogs_error:parse_logInput", {
          errors: value
        });
      });
      logsinputs.getItems(null, function(err, value) {
        Shiny.setInputValue(".shinylogs_input:parse_logInput", {
          inputs: value
        });
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
})();

