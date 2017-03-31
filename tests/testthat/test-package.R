context("toxiproxyr.test")

## This is what typical tests in the package might look like:
test_that("without proxy", {
  con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                        host = "localhost",
                        port = 5432)
  expect_is(DBI::dbListTables(con), "character")
})

test_that("with proxy", {
  ## Don't continue of toxiproxyr (the package) is not installed
  skip_if_not_installed("toxiproxyr")

  ## Don't continue if toxiproxy server is not running
  toxiproxyr::skip_if_no_toxiproxy_server()

  ## Create a proxy pointing at the server, and ensure (via on.exit)
  ## that it is removed at the end of this test block)
  tox <- toxiproxyr::toxiproxy_create("slow_sql", upstream = 5432)
  on.exit(tox$destroy())

  ## Create a postgres connection over our proxy:
  con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                        host = tox$listen_host,
                        port = tox$listen_port)

  ## Can access database via proxy:
  expect_is(DBI::dbListTables(con), "character")

  ## Can slow down the connection:
  dt <- 0.5
  safety <- 0.95
  expect_gt(
    tox$with(toxiproxyr::latency(dt * 1000),
             system.time(DBI::dbListTables(con), FALSE)[["elapsed"]]),
    dt * safety)

  ## Somewhat annoyingly, this does not work.  It works well with
  ## RPostgres, but that is not on CRAN and complicates the
  ## installation on appveyor considerably.
  ##
  ##   expect_error(tox$with_down(DBI::dbListTables(con)))
})
