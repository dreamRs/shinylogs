# Read a directory containing RDS logs

Read a directory containing RDS logs

## Usage

``` r
read_rds_logs(path)
```

## Arguments

- path:

  Path of the directory containing RDS files or a vector of path to RDS
  files.

## Value

a `list` of `data.table`

## Examples

``` r
if (FALSE) { # \dontrun{
# Read all RDS in a directory
logs <- read_rds_logs(path = "path/to/directory")

# Read a single file
logs <- read_rds_logs(path = "path/to/log.rds")
} # }
```
