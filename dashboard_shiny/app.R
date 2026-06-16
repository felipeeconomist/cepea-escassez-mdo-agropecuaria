# Dashboard — Mercado de Trabalho Rural e Urbano (PNAD Contínua)
# App Shiny destinado a ser exportado como app estático (Shinylive) e publicado
# no GitHub Pages. Ver README.md nesta pasta para o passo a passo de export.
setwd("C:\\Users\\felip\\Downloads\\Cepea\\MDO\\dashboard_shiny")
library(shiny)
library(plotly)

# ---- Dados -------------------------------------------------------------

data_wide <- read.csv("data/data_wide.csv", stringsAsFactors = FALSE,
                       fileEncoding = "UTF-8", check.names = FALSE)
labels_df  <- read.csv("data/labels.csv", stringsAsFactors = FALSE,
                        fileEncoding = "UTF-8")

ano_min <- min(data_wide$Ano)
ano_max <- max(data_wide$Ano)

ufs <- unique(data_wide$UF)
ufs <- c("Brasil", sort(ufs[ufs != "Brasil"]))

# Lista de choices agrupada por categoria (gera <optgroup> no selectInput),
# preservando a ordem de grupo já definida em labels.csv.
grupos_ordenados <- unique(labels_df$grupo)
choices_indicador <- lapply(grupos_ordenados, function(g) {
  sub <- labels_df[labels_df$grupo == g, ]
  sub <- sub[order(sub$label), ]
  setNames(as.list(sub$variavel), sub$label)
})
names(choices_indicador) <- grupos_ordenados

# Paleta para até 3 séries simultâneas
cores_series <- c("#2e6b3e", "#b5651d", "#3b6ea5")

# ---- UI ------------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Projeto de Escassez de Mão de Obra na Agropecuária"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("indicador", "Variáveis (até 3)",
                      choices = choices_indicador, selected = "Pessoas",
                      multiple = TRUE,
                      options = list(maxItems = 3, plugins = list("remove_button"))),
      selectInput("uf", "Localização", choices = ufs, selected = "Brasil"),
      sliderInput("anos", "Período",
                  min = ano_min, max = ano_max,
                  value = c(ano_min, ano_max), step = 1, sep = "")
    ),
    mainPanel(
      plotlyOutput("grafico", height = "480px")
    )
  )
)

# ---- Server ----------------------------------------------------------------

server <- function(input, output, session) {

  dados_filtrados <- reactive({
    df <- data_wide[data_wide$UF == input$uf &
                       data_wide$Ano >= input$anos[1] &
                       data_wide$Ano <= input$anos[2], ]
    df[order(df$Ano), ]
  })

  output$grafico <- renderPlotly({
    df          <- dados_filtrados()
    indicadores <- input$indicador

    validate(need(length(indicadores) > 0, "Selecione ao menos uma variável."))

    p <- plot_ly()
    for (i in seq_along(indicadores)) {
      var  <- indicadores[i]
      meta <- labels_df[labels_df$variavel == var, ]
      y    <- df[[var]]

      p <- p %>% add_trace(
        x = df$Ano, y = y,
        type = "scatter", mode = "lines+markers",
        name = meta$label,
        line = list(color = cores_series[i], width = 2.5),
        marker = list(size = 6, color = cores_series[i]),
        hovertemplate = paste0("<b>%{x}</b><br>", meta$label, ": %{y:,.0f}<extra></extra>")
      )
    }

    titulo <- if (length(indicadores) == 1) {
      paste0(labels_df[labels_df$variavel == indicadores, "label"], " — ", input$uf)
    } else {
      paste0("Comparação de variáveis — ", input$uf)
    }

    p %>% layout(
      title = titulo,
      xaxis = list(title = "Ano", dtick = 1, tickformat = "d"),
      yaxis = list(title = "Valor", separatethousands = TRUE),
      hovermode = "closest",
      legend = list(orientation = "h", y = -0.2),
      margin = list(t = 50, r = 20, l = 60, b = 60)
    )
  })
}

shinyApp(ui, server)
