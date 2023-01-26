libraries <- read_csv("mini_project_dc_libraries/data/libraries.csv") |>
  janitor::clean_names()

libraries |>
  select(name, address, phone, url = web_url, type, latitude, longitude, ward, psa) |>
  write_csv("mini_project_dc_libraries/data/libraries.csv")

library_resources <- read_csv("mini_project_dc_libraries/data/library_resource_usage.csv") |>
  janitor::clean_names()

keys <- library_resources |>
  distinct(name) |>
  filter(name != "Library Express") |>
  arrange(name) |>
  bind_cols(libraries |> distinct(name) |> arrange(name)) |>
  rename(a = 1, b = 2)

library_resources |>
  select(name, fiscal_year, computer_sessions, wifi_use, gate_count) |>
  mutate(name = case_when(
    name == keys$a[[1]] ~ keys$b[[1]],
    name == keys$a[[2]] ~ keys$b[[2]],
    name == keys$a[[3]] ~ keys$b[[3]],
    name == keys$a[[4]] ~ keys$b[[4]],
    name == keys$a[[5]] ~ keys$b[[5]],
    name == keys$a[[6]] ~ keys$b[[6]],
    name == keys$a[[7]] ~ keys$b[[7]],
    name == keys$a[[8]] ~ keys$b[[8]],
    name == keys$a[[9]] ~ keys$b[[9]],
    name == keys$a[[10]] ~ keys$b[[10]],
    name == keys$a[[11]] ~ keys$b[[11]],
    name == keys$a[[12]] ~ keys$b[[12]],
    name == keys$a[[13]] ~ keys$b[[13]],
    name == keys$a[[14]] ~ keys$b[[14]],
    name == keys$a[[15]] ~ keys$b[[15]],
    name == keys$a[[16]] ~ keys$b[[16]],
    name == keys$a[[17]] ~ keys$b[[17]],
    name == keys$a[[18]] ~ keys$b[[18]],
    name == keys$a[[19]] ~ keys$b[[19]],
    name == keys$a[[20]] ~ keys$b[[20]],
    name == keys$a[[21]] ~ keys$b[[21]],
    name == keys$a[[22]] ~ keys$b[[22]],
    name == keys$a[[23]] ~ keys$b[[23]],
    name == keys$a[[24]] ~ keys$b[[24]],
    name == keys$a[[25]] ~ keys$b[[25]],
    name == keys$a[[26]] ~ keys$b[[26]],
    TRUE ~ name,
  )) |>
  write_csv("mini_project_dc_libraries/data/library_resource_usage.csv")
