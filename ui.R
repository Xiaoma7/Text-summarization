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
  titlePanel("Article Summarizer"),
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        "Articlesource",
        "Select source of the article:",
        c("Web page", "Local file upload"),
        inline = TRUE
      ),
      conditionalPanel(
        condition = "input.Articlesource == 'Local file upload'",
         fileInput("fileRequest", 
                   "Input article here",
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
      #conditionalPanel()
      DT::dataTableOutput('summary'),
      plotOutput("plot")
      )
 
  )
))

