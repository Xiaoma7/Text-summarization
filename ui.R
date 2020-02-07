library(xml2)
library(rvest)
library(lexRankr)
library(textrank)
library(udpipe)
library(wordcloud)
library(dplyr)
library(readtext)
library(shiny)
library(DT)

shinyUI(fluidPage(
  tags$head(tags$style(type="text/css", "
             #loadmessage {
               position: fixed;
               top: 0px;
               left: 0px;
               width: 100%;
               padding: 5px 0px 5px 0px;
               text-align: center;
               font-weight: bold;
               font-size: 100%;
               color: #000000;
               background-color: #CCFF66;
               z-index: 105;
             }
              #doit{background-color:orange}
          ")), 
  titlePanel("Article Summarizer"),
  sidebarLayout(
      sidebarPanel(
      radioButtons(
        "Articlesource",
        "Select the source of your article:",
        c("Web page", "Local file upload"),
        inline = TRUE
      ),
      conditionalPanel(
        condition = "input.Articlesource == 'Local file upload'",
         fileInput("fileRequest", 
                   "Upload article here (pdf, word or text documents):",
                   accept = c(".pdf", ".docx", ".txt")
                   )
      ),
      conditionalPanel(
        condition = "input.Articlesource == 'Web page'",
        textInput("url", "Copy and paste link to aritcle here")
      ),
      actionButton("doit", "Summarize !")
    ),
    mainPanel(
      conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                       tags$div("Loading...",id="loadmessage")),
      tags$h3("1. Article summary sentences:"),
      DT::dataTableOutput('summary'),
      tags$h3("2. Keywords plot:"),
      plotOutput("plot")
      )
 
  )
))

