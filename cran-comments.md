## Test environments
* local OS Windows 10 install, R 3.6.0
* ubuntu 14.04 (on travis-ci), R 3.5.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* Re-submission to replace \dontrun examples with executable ones.
  Except for RDS one to avoid : 
   - WARNING: Added dependency on R >= 3.5.0 because serialized objects in  serialize/load version 3 cannot be read in older versions of R.
  Thanks! Victor

