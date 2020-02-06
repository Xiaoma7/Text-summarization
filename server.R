

shinyServer(function(input, output, session ){
  session$onSessionEnded(stopApp)
  
  article <- reactive({
    if (input$Articlesource == "Local file upload") {
      readtext(input$fileRequest$datapath)      
    } else {
      read_html(input$url)
    }

  })

v <- reactiveValues(dorender = F)

observeEvent(input$doit, {
  v$dorender <- input$doit
})

observeEvent(input$Articlesource, {
  v$dorender <- F
  # clear output when input mode is switched
})
  
  output$summary <- DT::renderDataTable({
    if (v$dorender == F) return()
   
    isolate({
    if (input$Articlesource == "Local file upload") {
      a_text <- article()$text
    } else {
      a_text <-  rvest::html_text(rvest::html_nodes(article(), "p"))
    }
    top_4 <- lexRankr::lexRank(a_text,
                               docId = rep(1, length(a_text)),
                               #return 4 summary sentences
                               n = 4,
                               continuous = TRUE)
    top_4$sentenceId <- as.numeric(gsub("_",".",top_4$sentenceId))

    summary_text <- top_4 %>%arrange(sentenceId) %>% select(sentence)
    colnames(summary_text) <- "Article Summary"
    })
    
    return(summary_text)
    
  })
  
  tagger <- udpipe_download_model("english")
  tagger <- udpipe_load_model(tagger$file_model)
  
  output$plot <- renderPlot({
    if (v$dorender == F) return()
    
    isolate({
      if (input$Articlesource == "Local file upload") {
        a_text <- article()$text
      } else {
        a_text <-  rvest::html_text(rvest::html_nodes(article(), "p"))
      }

      article <- as.data.frame(udpipe_annotate(tagger, a_text))
      
      # keywords
      keywd <- textrank_keywords(article$lemma,
                                relevant = article$upos %in% c("NOUN", "ADJ"))
      keyw <- subset(keywd$keywords, ngram > 1 & freq >1)
      
      # In case article too short, expand the keyword criteria
      if (nrow(keyw) < 5) {
      keyw <- subset(keywd$keywords, freq > 1 )
      }
    })
    
    wordcloud(words = keyw$keyword, freq = keyw$freq, scale=c(4,0.5), colors = brewer.pal(6, "Dark2"), max.words = 100)
    
  })
  
})

