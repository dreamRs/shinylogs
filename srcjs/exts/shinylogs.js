import "shiny";
import * as dayjs from "dayjs";
import localforage from "localforage";
import { extendPrototype } from "localforage-getitems";
extendPrototype(localforage);

(function() {
  // config
  var config = document.querySelectorAll('script[data-for="shinylogs"]');

  if (config.length > 0) {
    config = JSON.parse(config[0].innerHTML);
  } else {
    config = { logsonunload: false, what: ["session", "input", "output", "error"] };
  }

  // console.log(config);

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

  // Send browser data if shiny initialized
  if (typeof(window.Shiny) !== "undefined" && !!window.Shiny.setInputValue) {
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
  }

  // Send browser data when shiny is connected
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
  if (config.what.indexOf("input") > -1) {
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
  }

  // Track ERRORS
  if (config.what.indexOf("error") > -1) {
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
  }

  // Track OUTPUTs
  if (config.what.indexOf("output") > -1) {
    $(document).on("shiny:value", function(event) {
      //console.log(event);
      var ts = dayjs(event.timeStamp).format("YYYY-MM-DD HH:mm:ss.SSSZZ");
      var outputId = "output" + generateId();
      try {
        var bindingName = event.binding.binding.name;
      } catch(e) {
        var bindingName = "";
      };
      var lastOutput = {
        name: event.name,
        timestamp: ts,
        binding: bindingName
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
  }

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
