library(shiny)
library(ggplot2)
library(bslib)
library(rlang)
library(curl)
library(reshape2)
library(thematic)
library(bsicons)
library(ggridges)

# enlarged auto fonts
# if (is_installed("thematic")) {
#   thematic::thematic_shiny(
#     font = thematic::font_spec("auto", scale = 2, update = TRUE)
#   )
# }
#
# theme <- bs_global_get() %||% bs_theme()
#
#
# rounded <- isTRUE(as.logical(bs_get_variables(theme %||% bslib::bs_theme(), "enable-rounded")))
# pill <- function(...) {
#   shiny::tabPanel(..., class = "p-3 border", class = if (rounded) "rounded")
# }
# tab <- function(...) {
#   shiny::tabPanel(..., class = "p-3 border border-top-0", class = if (rounded) "rounded-bottom")
# }
gradient <- function(theme_color = "primary") {
  bg_color <- paste0("bg-", theme_color)
  bgg_color <- if ("4" %in% theme_version(theme)) {
    paste0("bg-gradient-", theme_color)
  } else {
    paste(bg_color, "bg-gradient")
  }
  bg_div <- function(color_class, ...) {
    display_classes <- paste(
      paste0(".", strsplit(color_class, "\\s+")[[1]]),
      collapse = " "
    )
    div(
      class = "p-3", class = color_class,
      display_classes, ...
    )
  }
  fluidRow(
    column(6, bg_div(bg_color)),
    column(6, bg_div(bgg_color))
  )
}

theme_colors <- c("pri1mary", "secondary", "default", "success", "info", "warning", "danger", "dark")
gradients <- lapply(theme_colors, gradient)

progressBar <- div(
  class="progress",
  div(
    class="progress-bar w-25",
    role="progressbar",
    "aria-valuenow"="25",
    "aria-valuemin"="0",
    "aria-valuemax"="100"
  )
)

bs_table <- function(x, class = NULL, ...) {
  class <- paste(c("table", class), collapse = " ")
  class <- sprintf('class="%s"', class)
  HTML(knitr::kable(x, format = "html", table.attr = class))
}

ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = 'minty'),
  page_navbar(
    title = "ArboTrack - Dashboard",
    collapsible = TRUE,
    inverse = TRUE,
    fillable = "Dashboard",
    layout_column_wrap(
      width = 1/4,
      fill = FALSE,
      value_box(
        "Total Cases",
        uiOutput(("total_cases"), container = h2),
        showcase = bsicons::bs_icon("person"),
        theme_color = "primary"
      ),
      value_box(
        "New Cases",
        uiOutput(("new_cases"), container = h2),
        showcase = bsicons::bs_icon("person"),
        theme_color = "secondary"
      ),
      value_box(
        "Total deaths",
        uiOutput(("total_deaths"), container = h2),
        showcase = bsicons::bs_icon("person"),
        theme_color = "success"
      ),
      value_box(
        "New deaths",
        uiOutput(("new_deaths"), container = h2),
        showcase = bsicons::bs_icon("person"),
        theme_color = "danger"
      )
    ),
    layout_column_wrap(
      width = 1/2,
      class = "mt-3",
      card(
        full_screen = TRUE,
        card_header(
          "Total bill vs tip",
          popover(
            bsicons::bs_icon("gear"),
            radioButtons(
              ("scatter_color"), NULL, inline = TRUE,
              c("none", "sex", "smoker", "day", "time")
            ),
            title = "Add a color variable",
            placement = "top"
          ),
          class = "d-flex justify-content-between align-items-center"
        ),
        plotOutput(("scatterplot"))
      ),
      card(
        full_screen = TRUE,
        class = "bslib-card-table-sm",
        card_header("Tips data"),
        DT::dataTableOutput(("table"))
      ),
    ),
    card(
      full_screen = TRUE,
      class = "mt-3",
      card_header(
        "Tip percentages",
        popover(
          bsicons::bs_icon("gear"),
          radioButtons(
            ("tip_perc_y"), "Split by:", inline = TRUE,
            c("sex", "smoker", "day", "time"), "day"
          ),
          radioButtons(
            ("tip_perc_facet"), "Facet by:", inline = TRUE,
            c("none", "sex", "smoker", "day", "time"), "none"
          ),
          title = "Add a color variable"
        ),
        class = "d-flex justify-content-between align-items-center"
      ),
      plotOutput(("tip_perc"))
    )
    
    
    
  )
)

server <- function(input, output, session) {
  # Scatter plot
  output$scatter_plot <- renderPlot({
    ggplot(tips, aes(x = total_bill, y = tip)) +
      geom_point() +
      geom_smooth(method = "lm", se = TRUE, color = "blue") +
      labs(x = "Total Bill", y = "Tip") +
      theme_minimal()
  })
  
  # Tabela de dados
  output$table_data <- renderDataTable({
    datatable(
      tips,
      style = "auto",
      options = list(
        pageLength = 5,
        dom = "tp", # Controle de elementos (apenas tabela e paginação)
        autoWidth = TRUE
      ),
      class = "table-striped table-hover"
    )
  })
  
  # Density plot
  output$density_plot <- renderPlot({
    ggplot(tips, aes(x = tip / total_bill, fill = day)) +
      geom_density(alpha = 0.5) +
      facet_wrap(~day) +
      labs(x = "Tip Percentage", y = "Density") +
      theme_minimal()
  })
  
  tips_data <- reactive({
    d <- tips
    #d <- d[d$total_bill >= input$total_bill[1] & d$total_bill <= input$total_bill[2], ]
    #d <- d[d$time %in% input$time, ]
    d
  })
  
  output$table <- DT::renderDataTable({
    DT::datatable(tips_data(), fillContainer = TRUE, rownames = FALSE)
  })
  
  output$scatterplot <- renderPlot({
    validate(need(
      nrow(tips_data()) > 0,
      "No tips match the current filter. Try adjusting your filter settings."
    ))
    color <-  if (input$scatter_color != "none") sym(input$scatter_color)
    ggplot(tips_data(), aes(x = total_bill, y = tip, color = !!color)) +
      geom_point() +
      geom_smooth() +
      labs(x = NULL, y = NULL)
  })
  
  output$tip_perc <- renderPlot({
    validate(need(
      requireNamespace("ggridges", quietly = TRUE),
      "Please install the ggridges package to see this plot."
    ))
    validate(need(
      requireNamespace("ggridges", quietly = TRUE),
      "Please install the ggridges package to see this plot."
    ))
    p <- ggplot(tips_data(), aes(x = tip / total_bill, y = !!sym(input$tip_perc_y))) +
      ggridges::geom_density_ridges(scale = 0.9) +
      coord_cartesian(clip = "off") +
      labs(x = NULL, y = NULL)
    
    if (input$tip_perc_facet != "none") {
      p <- p + facet_wrap(vars(!!sym(input$tip_perc_facet)))
    }
    
    p
  })
  
  output$total_cases <- renderUI({
    nrow(tips_data())
  })
  
  output$new_cases<- renderUI({
    nrow(tips_data())
  })
  
  output$total_deaths<- renderUI({
    nrow(tips_data())
  })
  
  output$new_deaths<- renderUI({
    nrow(tips_data())
  })
  
  output$average_bill <- renderUI({
    if (nrow(tips_data()) == 0) return(HTML("&ndash;"))
    scales::dollar(mean(tips_data()$total_bill))
  })
  
  output$average_tip <- renderUI({
    if (nrow(tips_data()) == 0) return(HTML("&ndash;"))
    d <- tips_data()
    scales::percent(mean(d$tip / d$total_bill))
  })
  
  observeEvent(input$reset, {
    updateSliderInput(session, "total_bill", value = range(tips$total_bill))
    updateCheckboxGroupInput(session, "time", selected = c("Lunch", "Dinner"))
  })
}

shinyApp(ui, server)
ins

