# setwd("C:/Users/12149/Desktop/shiny")
# 加载需要的库
library(shiny)
library(ggplot2)
library(dplyr)
library(readxl)
library(readr)

# 创建UI
ui <- fluidPage(
  sidebarPanel(
    p("这是一个绘制简单折线图的Shiny,输入文件格式：",strong("行为样本,列为变量")),
    actionButton("loadExample", "加载示例数据"),
    tableOutput("view"),
    fileInput("file", "上传你的文件", accept = c(".xlsx", ".csv")),
    selectInput("variable", "选择变量:", NULL),
    textInput("title", "输入折线图的标题:", "Line_Plot"),
    numericInput("titleSize", "输入标题的字体大小:", 14, min = 1, max = 50),
    numericInput("xSize", "输入x轴的字体大小:", 14, min = 1, max = 50),
    numericInput("ySize", "输入y轴的字体大小:", 14, min = 1, max = 50),
  ),
  mainPanel(
    plotOutput("linePlot"),
    selectInput("format", "选择导出的图片格式:", choices = c("png", "pdf")),
    downloadButton("downloadPlot", "下载折线图")
  )
)

# 创建server函数
server <- function(input, output,session) {
  data <- reactive({
    if (input$loadExample) {
      df <- read_excel("C:/Users/12149/Desktop/shiny/折线图/data/example.xlsx")  # 这里使用mtcars数据集作为示例，你可以替换为你自己的数据
    }else {
      req(input$file)
      df <- switch(tolower(tools::file_ext(input$file$datapath)),
                   "csv" = read_csv(input$file$datapath),
                   "xlsx" = read_excel(input$file$datapath))
      }
    
    observeEvent(input$loadExample, {
      data()  # 加载示例数据
    })
    
    updateSelectInput(session, "variable", choices = names(df)[-1])
    return(df)
  })

  # 折线图
  output$linePlot <- renderPlot({
    req(data(), input$variable)
    df <- data()
    ggplot(df, aes_string(x = names(df)[1], y = input$variable)) +
      geom_line(aes(group = 1)) +
      geom_point() +
      theme_bw()+
      ggtitle(input$title)+
      theme(plot.title = element_text(hjust = 0.5,size = input$titleSize),
            axis.title.x = element_text(size = input$xSize),
            axis.title.y = element_text(size = input$ySize))
  })
  # 下载图片
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste("line_plot_", Sys.Date(), ".", input$format, sep = "")
    },
    content = function(file) {
      plot <- {
        req(data(), input$variable)
        df <- data()
        ggplot(df, aes_string(x = names(df)[1], y = input$variable)) +
          geom_line(aes(group = 1)) +
          geom_point() +
          theme_bw()+
          ggtitle(input$title)+
          theme(plot.title = element_text(hjust = 0.5,size = input$titleSize),
                axis.title.x = element_text(size = input$xSize),
                axis.title.y = element_text(size = input$ySize))
      }
      switch(input$format,
             "png" = png(file, width = 800, height = 600,res = 150),
             "pdf" = pdf(file, width = 10, height = 7.5))
      print(plot)
      dev.off()
    }
  )

  # 展示实例数据的前6行  
  output$view <- renderTable({
    head(data(),6)
  })
}
# 运行shiny应用
shinyApp(ui = ui, server = server)