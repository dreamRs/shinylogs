# Use Google Drive as storage mode

All logs will be written in the same file.

## Usage

``` r
store_googledrive(path)
```

## Arguments

- path:

  Path to folder on Drive where to send logs.

## Value

A list that can be used in
[`track_usage()`](https://dreamrs.github.io/shinylogs/reference/track_usage.md).

## Note

See the {gargle} package to manage authentication, and especially [this
vignette from {gargle}
package](https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html)
to manage the process.

## Examples

``` r
if (FALSE) { # \dontrun{
# In your global, manage Google Drive access
drive_auth(path = "/path/to/your/service-account-token.json")
# see https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html
# to manage your token securely

# Then in server, use:
track_usage(storage_mode = store_googledrive(path = "my-logs/"))

# you may have to share my-logs/ folder with your service account

} # }
```
