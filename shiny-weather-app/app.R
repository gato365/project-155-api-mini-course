library(shiny)
library(httr2)
library(ggplot2)

# One color per city, assigned in the order cities are entered (max 5).
# Palette validated for colorblind safety on a white chart surface.
city_palette <- c("#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4")

plot_choices <- c(
  "Daily high temperature (°F)" = "High (°F)",
  "Daily low temperature (°F)" = "Low (°F)",
  "Daily precipitation (in)" = "Precipitation (in)"
)

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
  div(class = "panel-card",
      h2("Weather trends, past 7 days"),
      p("Each point is one day of data from the Open-Meteo API: the past seven days ",
        "plus today, for every city you requested. Use the dropdown to switch which ",
        "measurement is shown on the y-axis."),
      selectInput("plot_var", "Variable on the y-axis", choices = plot_choices, width = "320px"),
      plotOutput("history_plot", height = "440px")),
  tags$details(
    tags$summary("Show historical data (past 7 days)"),
    plotOutput("history_plot", height = "360px"),
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
  output$history_plot <- renderPlot({
    history <- weather()$history
    city_names <- unique(history$City)
    colors <- grDevices::hcl.colors(length(city_names), "Dark 3")

    # Create the same city-by-date comparison used in Session 4.
    plot(
      range(history$Date), range(history[["High (°F)"]], na.rm = TRUE),
      type = "n", xlab = "Date", ylab = "Daily High (°F)",
      main = "Daily Highs Across Selected Cities"
    )
    for (i in seq_along(city_names)) {
      rows <- history$City == city_names[[i]]
      lines(history$Date[rows], history[["High (°F)"]][rows], col = colors[[i]], lwd = 2)
    }
    legend("topright", legend = city_names, col = colors, lwd = 2, bty = "n")
  })

  output$history_plot <- renderPlot({
    history <- weather()$history
    var <- input$plot_var
    var_label <- names(plot_choices)[plot_choices == var]

    history$City <- factor(history$City, levels = unique(history$City))
    colors <- setNames(city_palette[seq_len(nlevels(history$City))], levels(history$City))
    date_range <- format(range(history$Date), "%b %d")

    base_theme <- theme_minimal(base_size = 15) +
      theme(
        plot.title = element_text(face = "bold", size = 17, color = "#172033"),
        plot.subtitle = element_text(color = "#52514e", margin = margin(b = 12)),
        plot.caption = element_text(color = "#898781"),
        axis.title.y = element_text(color = "#52514e", margin = margin(r = 8)),
        axis.text = element_text(color = "#52514e"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "#e1e0d9", linewidth = 0.4),
        legend.position = if (nlevels(history$City) > 1) "bottom" else "none",
        legend.title = element_blank(),
        legend.text = element_text(color = "#172033")
      )

    p <- ggplot(history, aes(x = Date, y = .data[[var]]))

    if (var == "Precipitation (in)") {
      p <- p +
        geom_col(aes(fill = City), position = position_dodge2(padding = 0.2),
                 width = 0.8) +
        scale_fill_manual(values = colors) +
        scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.05)))
    } else {
      p <- p +
        geom_line(aes(color = City), linewidth = 0.9) +
        geom_point(aes(color = City), size = 2.6) +
        scale_color_manual(values = colors)
    }

    p +
      scale_x_date(date_breaks = "1 day", date_labels = "%b %d") +
      labs(
        title = var_label,
        subtitle = paste0(
          paste(levels(history$City), collapse = ", "),
          " · ", date_range[1], "–", date_range[2]
        ),
        caption = "Source: Open-Meteo forecast API (past 7 days + today)",
        x = NULL,
        y = var_label
      ) +
      base_theme
  }, res = 96)

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
