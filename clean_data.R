library(tidyverse)
library(lubridate)
library(feather)

url <- 'https://datos.estadisticas.pr/dataset/5152cd0a-1193-47a4-82a1-c6bf0ff1c1c3/resource/b0595321-48b1-4292-8535-b1da0ca46a68/download/cusersjadian-arcedesktopincidencia_enero_2012-marzo_2018.csv'

raw_data <- read_csv(url)

raw_data %>%
    filter(POINT_X < 1000, POINT_Y < -60) %>%
    filter(POINT_X > 15) %>%
    mutate(Fecha = mdy_hm(Fecha),
           incident_timestamp = make_datetime(
               year = year(Fecha),
               month = month(Fecha),
               day = day(Fecha),
               hour = hour(Hora),
               min = minute(Hora))) %>%
    rename(incident_time = Hora,
           crime_code = Delito,
           crime_desc = Delitos_code,
           police_area = `Area Policiaca`,
           latitude = POINT_X,
           longitude = POINT_Y,
           incident_date = Fecha,
           location = Location) %>%
    mutate(crime_code = as.factor(crime_code),
           police_area = as.factor(police_area)) ->
    data

data %>%
    select(- incident_timestamp) ->
    spatial_data

data %>%
    select(- latitude, - longitude, - location) %>%
    filter(!is.na(incident_timestamp)) ->
    time_series_data

data -> full_data

data_saver <- function(.tbl, file_name){
    write_csv(x = .tbl, paste0('data/', file_name, '.csv'))
    write_feather(x = .tbl, paste0('data/', file_name, '.feather'))
}

data_saver(spatial_data, file_name = 'spatial_data')
data_saver(time_series_data, file_name = 'time_series_data')
data_saver(full_data, file_name = 'all_data')