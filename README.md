# toxiproxyr.test

[![Linux Build Status](https://travis-ci.org/richfitz/toxiproxyr.test.svg?branch=master)](https://travis-ci.org/richfitz/toxiproxyr.test)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/richfitz/toxiproxyr.test?svg=true)](https://ci.appveyor.com/project/richfitz/toxiproxyr.test)

This repo exists to show how to use [toxiproxy](https://toxiproxy.io) and [toxiproxyr](https://github.com/richfitz/toxiproxyr) for continuous integration.

## Configuring a project to use toxiproxyr

The key bits needed are:

* Add `toxiproxyr` to your [`DESCRIPTION`](DESCRIPTION)

```
Suggests:
    testthat,
    toxiproxyr
Remotes: richfitz/toxiproxyr
```

The `Remotes` entry will be needed until `toxiproxyr` is on CRAN.  `toxiproxyr` is added to `Suggests:` only because it is needed only in tests.

* Add an entry to [`.Rbuildignore`](.Rbuildignore) to ignore some files that are needed on the continuous integration server

```
^\.toxiproxy$
```

* Configure [`.travis.yml`](.travis.yml) to start toxiproxy before running your tests

```yaml
before_script:
  - Rscript -e 'toxiproxyr:::toxiproxy_start_ci(".toxiproxy")'
```

The path `.toxiproxy` here can be anything but must match what you use in `.Rbuildignore`

* Configure [`appveyor.yml`](appveyor.yml)

```
build_script:
  - travis-tool.sh install_deps
  - Rscript -e 'toxiproxyr:::toxiproxy_start_ci(".toxiproxy")'
```

The first line of this is in the standard appveyor template.

* Use toxiproxyr in your tests

A full example is given in [tests/testthat/test-package.R](tests/testthat/test-package.R).  There are several things to note here

1. Begin any test block that uses `toxiproxy` with `skip_if_not_installed("toxiproxyr")` because `toxiproxyr` is only a `Suggests` package
2. Follow this with `toxiproxyr::skip_if_no_toxiproxy_server()` which will skip tests if toxiproxy server is running (such as on CRAN)
3. If you create a proxy `tox` in a test block, consider adding `on.exit(tox$destroy())` to ensure that it is removed at the end of the test block, even if it fails

After that, things continue much as normal.

## What the steps above do

The `.toxiproxy` directory will hold a copy of the `toxiproxy` server binary; that is downloaded by the `toxiproxyr:::toxiproxy_start_ci` function.  It then starts a copy of the server and saves the log into the `.toxiproxy` directory.

The `toxiproxyr:::toxiproxy_start_ci` function looks two environment variables to control its behaviour:

* `TOXIPROXY_PORT`: port to run toxiproxy on (default: 8474)
* `TOXIPROXY_VERSION`: version of toxiproxy run run (default: 2.0.0)

You can set these via your continuous integration's environment variables settting if you need them to be set differently
