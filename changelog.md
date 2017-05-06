# 0.5.4 - 2017-05-05
## enhancements
added support for rspec 3.6.0

# 0.5.3 - 2017-01-11
## enhancements
printing summary of rspec to output not STDOUT (thanks @trevorcreech / #68)
removing some development dependencies

# 0.5.2 - 2016-10-03
## bugfixes
supports versions > 3.5.0  (thanks @y-yagi / #65)

# 0.5.1 - 2016-9-30
## enhancements
better failure message for multiple failures in one test (thanks @JonRowe / #62)

# 0.5.0 - 2016-8-8
drop support for rspec 3.2, added support for 3.4, 3.5

# 0.4.6 - 2016-8-8
## bugfixes
failure message was off by 1 (thanks @anthonywoo, @vgrigoruk / #57)
## enhancements
add the `exceptions_to_hard_fail` options (thanks @james-dominy, @ShockwaveNN / #59)
add retry reporter & api for accessing retry from reporter (thanks @tdeo / #54)

# 0.4.5 - 2015-11-4
## enhancements
retry can be called programmatically (thanks, @dwbutler / #45)

# 0.4.4 - 2015-9-9
## bugfixes
fix gem permissions to be readable (thanks @jdelStrother / #42)

# 0.4.3 - 2015-8-29
## bugfixes
will retry on children of exceptions in the `exceptions_to_retry` list
(thanks @dwbutler! #40, #41)

## enhancements
setting `config.display_try_failure_messages` (and `config.verbose_retry`) will
spit out some debug information about why an exception is being retried
(thanks @mmorast, #24)

# 0.4.2 - 2015-7-10
## bugfixes
setting retry to 0 will still run tests (#34)

## enhancements
can set env variable RSPEC_RETRY_RETRY_COUNT to override anything specified in
code (thanks @sunflat, #28, #36)

# 0.4.1 - 2015-7-9
## bugfixes
rspec-retry now supports rspec 3.3. (thanks @eitoball, #32)

## dev changes
include travis configuration for testing rspec 3.2.* and 3.3.*
(thanks @eitoball, #31)
