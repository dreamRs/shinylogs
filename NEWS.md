# shinylogs 0.2.1

* `track_usage()` has new arguments:
  + `app_name`: explicitly set application's name, thanks to [@PaulC91](https://github.com/PaulC91)
  + `what`: elements to record between `"session"`, `"input"`, `"output"` and `"error"`.


# shinylogs 0.2.0

* Timestamp is now recorded in microseconds (fix [#6](https://github.com/dreamRs/shinylogs/issues/6)).
* Added `store_googledrive()` to store logs as json in Google drive.
* Added `store_custom()` to use a custom function to deal with logs generated.
* Use [{packer}](https://github.com/JohnCoene/packer) to manage JavaScript assets.


# shinylogs 0.1.7

* Fix a bug when used with {shinymanager} (fix [#2](https://github.com/dreamRs/shinylogs/issues/2)).


# shinylogs 0.1.6

* `use_tracking` is now exported to load dependencies directly in UI, usefull for big applications.
* Ability to print logs recorded in the console.


# shinylogs 0.1.5

* First release : Track and record the use of applications and the user's interactions with 'Shiny' inputs. Allow to save inputs clicked, output generated and eventually errors.
