context("toxiproxyr.test")

test_that("without proxy", {
  con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                        host = "localhost",
                        port = 5432)
  expect_is(DBI::dbListTables(con), "character")
})
