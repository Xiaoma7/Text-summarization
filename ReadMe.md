Article Summarizer
================

Text summarization overview
---------------------------

Text mining and natural language processing have been trending topics in the field of data science. In this project, I build a R application that can summarize articles of different formats in a few number of sentences, as well as extracting a number of keywords from the ariticle.

The are two main categoires in the approaches to text summarization:

-   **Extractive Summarization**: This approach relys on extracting the most important phrases or sentences from the text, without rephrasing them or creating new words. The goal is to find segments of the text that can best represent its overall idea.

-   **Abstractive Summarization**:This method uses more advanced natural language processing techniques that generates new sentences or phrases that summarize the text.

In this project, I will be focusing on the Extractive summarization techinque. In particular, I will be using a text ranking algorithms called [**LexRank**](https://www.cs.cmu.edu/afs/cs/project/jair/pub/volume22/erkan04a-html/erkan04a.html), which is an unsupervised text summarization algorithm using graph-based centrality to score sentences.

Data Preparation
----------------

The aim for the final product is that it can handle a variety types of article inputs, including articles from the web, or documents from local computer in common document formats such as pdf, word, or text documents. This will require different ways of importing data.

### Importing articles from web page

In order to import articles from the web, I use the **xml2** and **rvest** packages.

``` r
library(xml2)
library(rvest)
```

For example, take this [**news article**](https://www.nbcchicago.com/news/local/man-charged-in-shooting-on-cta-blue-line-train-near-uic/2214257/) from NBC Chicago as our article to summarize.

First use the read\_html function reads in the whole web data set.

``` r
webpage <- read_html("https://www.nbcchicago.com/news/local/man-charged-in-shooting-on-cta-blue-line-train-near-uic/2214257/")
```

Next, use the html\_text function to extract only the texts from the web data.

``` r
web_text <-  rvest::html_text(rvest::html_nodes(webpage, "p"))

# Take a look at first few lines
cat(web_text[1:5], sep = "\n")
```

    ## A convicted felon has been arrested and charged in a shooting that took place on a Chicago Transit Agency Blue Line train near the University of Illinois at Chicago campus, police said Thursday.
    ## Patrick Waldon, 31, of Chicago, faces charges of aggravated battery with a firearm, armed robbery with a firearm, armed habitual criminal and issuance of a warrant, authorities said, one day after the shooting took place. 
    ## Police credited witnesses on the train and the public's help in identifying the man following the shooting. 
    ## 
    ## "The key point in this arrest is this is public initiated," said Interim Police Superintendent Charlie Beck.

### Importing article from local documents

The readtext package in r is a very versatile package that can reads in various forms of documents including '.csv', '.tab', '.json', '.xml', '.html', '.pdf', '.doc', '.docx', '.rtf', '.xls', '.xlsx', and others. This is perfect for our purpose.

Taking the pdf task assignment document I got for a data scientist interview at UIC for example.

``` r
library(readtext)
pdf_text <- readtext("C:/Users/Ruochen/Desktop/Project/uic/Data Scientist Technical Assignment.pdf")

# Taking a look
cat(pdf_text$text, sep = "\n")
```

    ##                                       Data Scientist, ACER
    ##                                      Technical Assignment
    ##                                         February 5, 2020
    ## Thank you for your continued interest in the Data Scientist, ACER position with the Academic
    ## Computing and Communications Center (ACCC) at the University of Illinois at Chicago (UIC).
    ## During this round, we will ask you to complete a technical assignment.
    ## Technical Assignment
    ## Problem: TL;DR is a common example for text analysis in ML. Your task will be to find an
    ## article that mentions UIC on the web and write an application that produces a coherent
    ## summary in 4-5 sentences.
    ## Assignment Criteria
    ##          The application must read in any UIC article.
    ##          The original article and summary will be compared for accuracy.
    ##          The Search Committee will need to see a ReadMe.md for Usage Instructions and a
    ##           description of your efforts around this and/or any improvements after
    ##           implementation. The Search Committee is looking for insights to your thought
    ##           process, the use of libraries, best coding practices, and flexibility of the application
    ##           for different scenarios rather than making it perfect for this current assignment.
    ##          You may use any language you are comfortable with. (Hint: NLTK library)
    ##          Please send a GitHub with your Jupyter Notebook (https://jupyter.org/try) or Kaggle
    ##           link (https://www.kaggle.com) via email to Sherri Richardson, Human Resource
    ##           Coordinator (sherrir@uic.edu).
    ##           We must receive your completed assignment no later than 5:00pm on Friday,
    ##           February 7, 2020.
    ## If you have any questions or need clarification about the assignment, please feel free to
    ## contact Sherri Richardson at sherrir@uic.edu.
    ## So, what should you expect to happen next? Your submitted technical assignment will be
    ## reviewed. If there is further interest in your candidacy, you will be contacted to schedule
    ## further interviews.
    ## Thank you in advance for your cooperation and continued interest in the Academic
    ## Computing and Communications Center. We look forward to an opportunity for further
    ## discussion of the position.

Running LexRank
---------------

The LexRank algorithm essentially rank the sentences in the original text, giving a importance score to each. We can get a summary of the article by extracting the top few sentences with the highest rankings.

Let's use the NBC Chicago news as an example. Applying LexRank algorithm on it:

``` r
library(lexRankr)
top_4 <- lexRankr::lexRank(web_text,
                           docId = rep(1, length(web_text)),
                           #return 4 summary sentences
                           n = 4,
                           continuous = TRUE)
```

    ## Parsing text into sentences and tokens...DONE
    ## Calculating pairwise sentence similarities...DONE
    ## Applying LexRank...DONE
    ## Formatting Output...DONE

``` r
top_4
```

    ##   docId sentenceId
    ## 1     1        1_1
    ## 2     1       1_15
    ## 3     1        1_3
    ## 4     1       1_26
    ##                                                                                                                                                                                             sentence
    ## 1 A convicted felon has been arrested and charged in a shooting that took place on a Chicago Transit Agency Blue Line train near the University of Illinois at Chicago campus, police said Thursday.
    ## 2                                          According to police, there was an exchange of words between the alleged gunman and the victim, and investigators believed that the shooting was targeted.
    ## 3                                                                                        Police credited witnesses on the train and the public's help in identifying the man following the shooting.
    ## 4                                                                                                          Police said the victim in the shooting was coherent and cooperative in the investigation.
    ##        value
    ## 1 0.06830827
    ## 2 0.06647744
    ## 3 0.06501117
    ## 4 0.06382135

Here we get the top 4 ranked sentences from the article by specifying n = 4. We created identical docID for all elements in the input vector because there is only 1 document.

The sentence ID represnet the order in which these sentences appear in the article. To make it more readable, we also sort the output in the article order.

``` r
library(dplyr)
# making sentence id numeric for sorting
top_4$sentenceId <- as.numeric(gsub("_",".",top_4$sentenceId)) 

summary_text <- top_4 %>% arrange(sentenceId) %>% select(sentence)
colnames(summary_text) <- "Article Summary"
cat(summary_text$`Article Summary`, sep = "\n")
```

    ## A convicted felon has been arrested and charged in a shooting that took place on a Chicago Transit Agency Blue Line train near the University of Illinois at Chicago campus, police said Thursday.
    ## According to police, there was an exchange of words between the alleged gunman and the victim, and investigators believed that the shooting was targeted.
    ## Police said the victim in the shooting was coherent and cooperative in the investigation.
    ## Police credited witnesses on the train and the public's help in identifying the man following the shooting.

Here you have it! The summary of the article in 4 sentences.

Further Investigation
---------------------

### Keywords

To take it further, another way to summarize text is to extract keywords from it. The basic approach for extracting keywords is finding the words that are most frequently occuring and occur somehow together in a plain text. There are more sophisticate methods of extracting the keywords that not only consider their frequency of occurence, but also things like the type of words (noun, adj, verb) and their interaction with other words in the article. Here I use the [**Textrank**](https://cran.r-project.org/web/packages/textrank/vignettes/textrank.html) algorithm to extract keywords from the article into multi-word phrases.

Let's use the pdf article we read in earliear this time. Before applying the textrank algorithm, we first need to annotate the text. **Text Annotation** in natural language processing is basically a way to label and break down the raw sentences to make it more understandable to a machine learning algorithm, and also avoid feeding too much information into the model that can lead to overfitting. This can be done using the **udpipe** package in R.

``` r
library(udpipe)
tagger <- udpipe_download_model("english")
tagger <- udpipe_load_model(tagger$file_model)
article <- as.data.frame(udpipe_annotate(tagger, pdf_text$text))
head(article)
```

    ##   doc_id paragraph_id sentence_id
    ## 1   doc1            1           1
    ## 2   doc1            1           1
    ## 3   doc1            1           1
    ## 4   doc1            1           1
    ## 5   doc1            1           1
    ## 6   doc1            1           1
    ##                                                     sentence token_id
    ## 1 Data Scientist, ACER Technical Assignment February 5, 2020        1
    ## 2 Data Scientist, ACER Technical Assignment February 5, 2020        2
    ## 3 Data Scientist, ACER Technical Assignment February 5, 2020        3
    ## 4 Data Scientist, ACER Technical Assignment February 5, 2020        4
    ## 5 Data Scientist, ACER Technical Assignment February 5, 2020        5
    ## 6 Data Scientist, ACER Technical Assignment February 5, 2020        6
    ##        token      lemma  upos xpos       feats head_token_id  dep_rel deps
    ## 1       Data       data PROPN  NNP Number=Sing             2 compound <NA>
    ## 2  Scientist  scientist PROPN  NNP Number=Sing             7 compound <NA>
    ## 3          ,          , PUNCT    ,        <NA>             2    punct <NA>
    ## 4       ACER       Acer PROPN  NNP Number=Sing             2     flat <NA>
    ## 5  Technical  technical   ADJ   JJ  Degree=Pos             7     amod <NA>
    ## 6 Assignment assignment  NOUN   NN Number=Sing             7 compound <NA>
    ##                                                                                                                                         misc
    ## 1            SpacesBefore=\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s
    ## 2                                                                                                                              SpaceAfter=No
    ## 3                                                                                                                                       <NA>
    ## 4          SpacesAfter=\\r\\n\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s
    ## 5                                                                                                                                       <NA>
    ## 6 SpacesAfter=\\r\\n\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s

As you can see, this process breaks down the original article into pieces of information that the model can more easily read in. Next, we apply the textrank algorithm. Here I want to find the key phrases that are a combination of nouns and adjectives:

``` r
library(textrank)
# keywords
keywd <- textrank_keywords(article$lemma,
                          relevant = article$upos %in% c("NOUN", "ADJ"), sep = " ")
keyw <- keywd$keywords
keyw
```

    ##                      keyword ngram freq
    ## 1                 assignment     1    8
    ## 2       technical assignment     2    4
    ## 3                    further     1    3
    ## 4                     search     1    2
    ## 5  Acer technical assignment     3    1
    ## 6                       Acer     1    1
    ## 7                     common     1    1
    ## 8                       text     1    1
    ## 9                   coherent     1    1
    ## 10                    coding     1    1
    ## 11      resource coordinator     2    1
    ## 12               coordinator     1    1

As you can see, the keywords are summarized by their frequency of occurence, as well as the thing called ngram, which is basically the number of co-occuring words in the phrase.

If we are only interested in the key phrases with multiple words, we could specifiy ngram &gt; 1:

``` r
keyw %>% filter(ngram > 1)
```

    ##                     keyword ngram freq
    ## 1      technical assignment     2    4
    ## 2 Acer technical assignment     3    1
    ## 3      resource coordinator     2    1

### Visualization of keywords: Wordcloud

To take it even one more step further, we can use a wordcloud to visually present the keywords in the article. The bigger the texts are in the graph, the more important or frequently occuring they are in the article.

``` r
library(wordcloud)
wordcloud(words = keyw$keyword, freq = keyw$freq, scale=c(4,0.5),colors = brewer.pal(6, "Dark2"), max.words = 20, min.freq = 1)
```

![](ReadMe_files/figure-markdown_github/unnamed-chunk-10-1.png)

Putting it all together: R shiny app
------------------------------------

To combine all the work I did into something more presentable and user friendly, I built a shiny app that does article summarization using the methods discussed above. You can access the app by clicking the link **here** (<https://ruo-ma.shinyapps.io/Article_Summarizer/>).

Please note that I am using a free version of the shiny app server so there is 25 hour limit on the active time the app can have each month. Please do not over stay.

### Type of article source

This app allows two types of article sources: 1) Link from the web, 2) Upload from local computer.

![Mode selection](C:/Users/Ruochen/Desktop/Project/uic/Text-summarization-master/Capture1.png)

If you are using the **Web page** mode, copy and paste the link to online article into the box:

![Web Mode](C:/Users/Ruochen/Desktop/Project/uic/Text-summarization-master/Capture1.5.png)

In the **Local file upload** mode, click on the "Browse" button and upload an article from your computer.

![local mode](C:/Users/Ruochen/Desktop/Project/uic/Text-summarization-master/Capture3.png)

Once you are done inputting the article, click on the **Summarize !** button to generate the summary sentences and keywords plots for the article:

![outweb](C:/Users/Ruochen/Desktop/Project/uic/Text-summarization-master/Capture2.png)

![outpdf](C:/Users/Ruochen/Desktop/Project/uic/Text-summarization-master/Capture4.png)
