# City Weather Lab

This Shiny app is the student capstone: enter up to five comma- or line-separated cities, compare current temperature, humidity, and conditions, then expand the seven-day historical table.

## Run

```r
install.packages(c("shiny", "httr2"))
shiny::runApp("shiny-weather-app")
```

The app uses Open-Meteo and does not require an API key.
