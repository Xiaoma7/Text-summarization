

shinyServer(function(input, output, session ){
  session$onSessionEnded(stopApp)
  
  article <- reactive({
    if (input$Articlesource == "Local file upload") {
      readtext(input$fileRequest$datapath)      
    } else {
      read_html(input$url)
    }

  })
  
  tagger <- udpipe_download_model("english")
  tagger <- udpipe_load_model(tagger$file_model)
  
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
                                relevant = article$upos %in% c("NOUN", "ADJ"), sep = " ")
      
      keyw <- keywd$keywords
      
      try(multi <- keyw %>% filter(ngram > 1), silent = T) # In case there are no multi-word keywords
      single <- keyw %>% filter(ngram == 1) %>% arrange(desc(freq)) # sort by descending freq
      
      if (sum(keyw$ngram > 1) > 0) {
        if (nrow(multi) >= 20) { # if more than 20 multi phrase keywords, plot only these
          toplot <- multi
        } else if (nrow(multi) < 20 & nrow(keyw) >= 20) { # Fill in with most frequent singles until reach 20
          nfill <- 20 - nrow(multi) # need to fill in this number of singles
          toplot <- rbind(multi, single[1:nfill,])
        } else if (nrow(multi) < 20 & nrow(keyw) < 20) { # use all multi and single keywords
          toplot <- keyw  
        }
      } else { # if there is no multi-phrase at all...
        toplot <- keyw
      }

    })

    wordcloud(words = toplot$keyword, freq = toplot$freq, scale=c(4,0.5),colors = brewer.pal(6, "Dark2"), max.words = 20, min.freq = 1) 
  })
  
})



