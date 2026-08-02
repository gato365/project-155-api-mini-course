library(shiny)
library(httr2)

weather_label <- function(code) {
  labels <- c(
    `0` = "Clear sky", `1` = "Mainly clear", `2` = "Partly cloudy",
    `3` = "Overcast", `45` = "Fog", `48` = "Rime fog",
    `51` = "Light drizzle", `53` = "Drizzle", `55` = "Heavy drizzle",
    `61` = "Light rain", `63` = "Rain", `65` = "Heavy rain",
    `71` = "Light snow", `73` = "Snow", `75` = "Heavy snow",
    `80` = "Rain showers", `81` = "Rain showers", `82` = "Heavy showers",
    `95` = "Thunderstorm", `96` = "Thunderstorm with hail",
    `99` = "Thunderstorm with hail"
  )
  answer <- unname(labels[as.character(code)])
  ifelse(is.na(answer), paste("Weather code", code), answer)
}

geocode_city <- function(city) {
  response <- request("https://geocoding-api.open-meteo.com/v1/search") |>
    req_url_query(name = city, count = 1, language = "en", format = "json") |>
    req_perform() |>
    resp_body_json(simplifyVector = TRUE)

  if (is.null(response$results) || NROW(response$results) == 0) {
    stop(sprintf("No location found for “%s”.", city), call. = FALSE)
  }
  response$results[1, , drop = FALSE]
}

get_city_weather <- function(city) {
  place <- geocode_city(city)
  request_url <- request("https://api.open-meteo.com/v1/forecast") |>
    req_url_query(
      latitude = place$latitude,
      longitude = place$longitude,
      current = "temperature_2m,relative_humidity_2m,weather_code",
      daily = "temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code",
      temperature_unit = "fahrenheit",
      precipitation_unit = "inch",
      timezone = "auto",
      past_days = 7,
      forecast_days = 1
    )

  result <- request_url |> req_perform() |> resp_body_json()
  region <- if ("admin1" %in% names(place) && !is.na(place$admin1[[1]])) place$admin1[[1]] else ""
  location <- paste0(place$name[[1]], if (nzchar(region)) paste0(", ", region) else "")

  current <- data.frame(
    City = location,
    Temperature = paste0(result$current$temperature_2m, " °F"),
    Humidity = paste0(result$current$relative_humidity_2m, "%"),
    Conditions = weather_label(result$current$weather_code),
    Updated = result$current$time,
    check.names = FALSE
  )

  history <- data.frame(
    City = location,
    Date = as.Date(unlist(result$daily$time)),
    High = unlist(result$daily$temperature_2m_max),
    Low = unlist(result$daily$temperature_2m_min),
    Precipitation = unlist(result$daily$precipitation_sum),
    Conditions = weather_label(unlist(result$daily$weather_code)),
    check.names = FALSE
  )
  names(history)[3:5] <- c("High (°F)", "Low (°F)", "Precipitation (in)")

  list(current = current, history = history, url = request_url$url)
}

ui <- fluidPage(
  tags$head(
    tags$title("City Weather Lab"),
    tags$style(HTML("
      body { background:#f5f7ff; color:#172033; }
      .container-fluid { max-width:1100px; padding:2rem; }
      .hero { background:linear-gradient(135deg,#312e81,#2563eb); color:white;
              padding:2rem; border-radius:18px; margin-bottom:1.5rem; }
      .hero h1 { margin-top:0; font-weight:800; }
      .panel-card { background:white; padding:1.5rem; border-radius:14px;
                    box-shadow:0 8px 28px rgba(30,41,59,.08); margin-bottom:1.5rem; }
      .btn-primary { background:#4f46e5; border-color:#4f46e5; font-weight:700; }
      details { background:white; border:1px solid #c7d2fe; border-radius:12px;
                padding:1rem 1.25rem; margin-top:1.5rem; }
      summary { color:#3730a3; cursor:pointer; font-size:1.05rem; font-weight:700; }
      .table { margin-top:1rem; } th { background:#3730a3; color:white; }
      .question { border-left:5px solid #f59e0b; background:#fffbeb;
                  padding:1rem 1.25rem; border-radius:8px; margin-bottom:1.5rem; }
      .url-box { overflow-wrap:anywhere; background:#eef2ff; padding:.8rem;
                 border-radius:8px; font-family:monospace; margin-top:.75rem; }
    ")),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('copy-url', function(value) {
        navigator.clipboard.writeText(value);
        var button = document.getElementById('copy_url');
        button.textContent = 'Copied!';
        setTimeout(function(){ button.textContent = 'Copy API URL'; }, 1400);
      });
    "))
  ),
  div(class = "hero",
      h1("City Weather Lab"),
      p("Compare current and recent weather using the Open-Meteo API.")),
  div(class = "question",
      strong("Motivating question: "),
      "How does weather compare across the cities you chose? Make a prediction before requesting the data."),
  div(class = "panel-card",
      textAreaInput(
        "cities", "Cities", rows = 3, width = "100%",
        value = "San Luis Obispo, Boston",
        placeholder = "Enter cities separated by commas or new lines"
      ),
      actionButton("get_weather", "Get Weather Data", class = "btn-primary"),
      actionButton("copy_url", "Copy API URL", disabled = "disabled"),
      helpText("Tip: enter 2–5 cities for an easy comparison."),
      uiOutput("request_url")
  ),
  uiOutput("status"),
  div(class = "panel-card",
      h2("Current weather comparison"),
      tableOutput("current_table")),
  tags$details(
    tags$summary("Show historical data (past 7 days)"),
    tableOutput("history_table")
  )
)

server <- function(input, output, session) {
  weather <- eventReactive(input$get_weather, {
    cities <- trimws(unlist(strsplit(input$cities, "[,\\n]+")))
    cities <- unique(cities[nzchar(cities)])
    validate(need(length(cities) > 0, "Enter at least one city."))
    validate(need(length(cities) <= 5, "Please compare no more than five cities at once."))

    withProgress(message = "Requesting weather data", value = 0, {
      results <- lapply(seq_along(cities), function(i) {
        incProgress(1 / length(cities), detail = cities[[i]])
        tryCatch(get_city_weather(cities[[i]]), error = function(e) e)
      })
    })

    errors <- vapply(results, inherits, logical(1), what = "error")
    error_messages <- vapply(results[errors], conditionMessage, character(1))
    validate(need(!all(errors), paste(error_messages, collapse = " ")))
    list(
      data = results[!errors],
      errors = error_messages,
      current = do.call(rbind, lapply(results[!errors], `[[`, "current")),
      history = do.call(rbind, lapply(results[!errors], `[[`, "history")),
      urls = vapply(results[!errors], `[[`, character(1), "url")
    )
  }, ignoreNULL = TRUE)

  output$status <- renderUI({
    x <- weather()
    if (!length(x$errors)) return(NULL)
    div(class = "alert alert-warning", paste(x$errors, collapse = " "))
  })

  output$current_table <- renderTable(weather()$current, striped = TRUE, hover = TRUE)
  output$history_table <- renderTable(weather()$history, striped = TRUE, hover = TRUE)

  output$request_url <- renderUI({
    urls <- weather()$urls
    shinyjs <- sprintf("document.getElementById('copy_url').removeAttribute('disabled');")
    tags$div(
      tags$script(HTML(shinyjs)),
      tags$strong("Investigate before copying:"),
      tags$p("What endpoint and query parameters do you recognize?"),
      tags$div(class = "url-box", urls[[1]])
    )
  })

  observeEvent(input$copy_url, {
    req(weather())
    session$sendCustomMessage("copy-url", weather()$urls[[1]])
  })
}

shinyApp(ui, server)
