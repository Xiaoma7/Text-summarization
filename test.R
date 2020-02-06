article <- read_html("https://towardsdatascience.com/r-packages-for-text-analysis-ad8d86684adb")
a_text <- rvest::html_text(rvest::html_nodes(article, "p"))

top_4 <- lexRankr::lexRank(a_text,
                           docId = rep(1, length(a_text)),
                           #return 4 summary sentences
                           n = 4,
                           continuous = TRUE)

# text rank key words: https://www.r-bloggers.com/an-overview-of-keyword-extraction-techniques/
# https://www.hvitfeldt.me/blog/tidy-text-summarization-using-textrank/

library(udpipe)
tagger <- udpipe_download_model("english")
tagger <- udpipe_load_model(tagger$file_model)
article <- as.data.frame(udpipe_annotate(tagger, a_text))

# keywords
keyw <- textrank_keywords(article$lemma,
                          relevant = article$upos %in% c("NOUN", "ADJ"))
keyw <- subset(keyw$keywords,  freq > 2)

# word cloud
library(wordcloud)
wordcloud(words = keyw$keyword, freq = keyw$freq, scale=c(4,0.5),colors = brewer.pal(6, "Dark2"))


# add loading text: https://stackoverflow.com/questions/17325521/r-shiny-display-loading-message-while-function-is-running
