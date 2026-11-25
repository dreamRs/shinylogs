# Read a directory containing JSON logs

Read a directory containing JSON logs

## Usage

``` r
read_json_logs(path)
```

## Arguments

- path:

  Path of the directory containing JSON files or a vector of path to
  JSON files.

## Value

a `list` of `data.table`

## Examples

``` r

# Read all JSON in a directory
path_directory <- system.file("extdata/json", package = "shinylogs")
logs <- read_json_logs(path = path_directory)

# Read a single file
single_file <- dir(
  path = system.file("extdata/json", package = "shinylogs"),
  full.names = TRUE
)[1]
logs <- read_json_logs(path = single_file)
```
