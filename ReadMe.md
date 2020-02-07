Article Summarizer
================

## Text summarization overview

Text mining and natural language processing have been trending topics in
the field of data science. In this project, I build a R application that
can summarize articles of different formats in a few number of
sentences, as well as extracting important keywords from the ariticles.

The are two main categoires in the approaches to text summarization:

  - **Extractive Summarization**: This approach relys on extracting the
    most important phrases or sentences from the text, without
    rephrasing them or creating new words. The goal is to find segments
    of the text that can best represent its overall idea.

  - **Abstractive Summarization**:This method uses more advanced natural
    language processing techniques that generates new sentences or
    phrases that summarize the text.

In this project, I will be focusing on the Extractive summarization
techinque. In particular, I will be using a text ranking algorithms
called
[**LexRank**](https://www.cs.cmu.edu/afs/cs/project/jair/pub/volume22/erkan04a-html/erkan04a.html),
which is an unsupervised text summarization algorithm using graph-based
centrality to score sentences.

## Data Preparation

The aim for the final product is that it can handle a variety types of
article inputs, including articles from the web, or documents from local
computer in common document formats such as pdf, word, or text
documents. This will require different ways of importing data.

### Importing articles from web page

In order to import articles from the web, I use the **xml2** and
**rvest** packages.

``` r
library(xml2)
library(rvest)
```

For example, take this [**news
article**](https://www.nbcchicago.com/news/local/man-charged-in-shooting-on-cta-blue-line-train-near-uic/2214257/)
from NBC Chicago as our article to summarize.

First use the read\_html function reads in the whole web data set.

``` r
webpage <- read_html("https://www.nbcchicago.com/news/local/man-charged-in-shooting-on-cta-blue-line-train-near-uic/2214257/")
```

Next, use the html\_text function to extract only the texts from the web
data.

``` r
web_text <-  rvest::html_text(rvest::html_nodes(webpage, "p"))

# Take a look at first few lines
cat(web_text[1:10], sep = "\n")
```

    ## A convicted felon has been arrested and charged in a shooting that took place on a Chicago Transit Agency Blue Line train near the University of Illinois at Chicago campus, police said Thursday.
    ## Patrick Waldon, 31, of Chicago, faces charges of aggravated battery with a firearm, armed robbery with a firearm, armed habitual criminal and issuance of a warrant, authorities said, one day after the shooting took place. 
    ## Police credited witnesses on the train and the public's help in identifying the man following the shooting. 
    ## 
    ## "The key point in this arrest is this is public initiated," said Interim Police Superintendent Charlie Beck. 
    ## Authorities had released a photo of the suspect moments after the shooting took place, using images captured by CTA cameras.  
    ## "To those who think they can commit crime on @cta, think again. You're on camera and you will be caught," Chicago police spokesman Anthony Guglielmi tweeted. 
    ## In less than 24 hours of the shooting, police said they had identified a suspect. 
    ## "We got multiple calls from the public ID'ing this individual and then we had great cooperation from witnesses at the scene who also identified him," Beck said. 
    ## "This is the key to solving crime, particularly violent crime," he added.

### Importing article from local documents

There are many packages in R that imports files and data. The
**readtext** package is a very versatile package that can reads in
various forms of documents including ‘.csv’, ‘.tab’, ‘.json’, ‘.xml’,
‘.html’, ‘.pdf’, ‘.doc’, ‘.docx’, ‘.rtf’, ‘.xls’, ‘.xlsx’, and others.
This is perfect for our purpose.

Taking this pdf article about black population loss in Chicago that I
got from UIC’s website for example.

``` r
library(readtext)
pdf_text <- readtext("C:/Users/olive/Desktop/Proj/UIC/Text-summarization/today.uic.edu-UIC report examines black population loss in Chicago.pdf")

# Taking a look at the first page
firstp <- gsub("1/3.*","",pdf_text$text)
cat(firstp, sep = "\n")
```

    ##                                                   UIC Today
    ## UIC report examines black population loss in Chicago
    ##     today.uic.edu/uic-report-examines-black-population-loss-in-chicago
    ## Brian Flood
    ## The Great Migration of blacks to Chicago
    ## from the 1920s through the 1950s ushered
    ## in a major period of transformation for the
    ## city.
    ## In contrast, the past three decades are far
    ## removed from that era as Chicago’s black
    ## population has dropped over 350,000
    ## residents since its peak of almost 1.2 million
    ## in 1980.
    ## The dramatic decline has led to an ongoing
    ## national storyline suggesting that black
    ## Chicagoans’ exodus from the city is being
    ## fueled by violence in their neighborhoods.
    ## “This popular narrative overlooks the effects
    ## of government policies that are displacing
    ## black Chicagoans and how these dynamics
    ## are different from neighborhood to
    ## neighborhood,” said Amanda Lewis, director                     “Between the Great Migration and Growing
    ## of the Institute for Research on Race and                 Exodus: The Future of Black Chicago?” is the fourth
    ## Public Policy and professor of African                       installment in the UIC Institute for Research on
    ##                                                                Race and Public Policy’s ongoing series that
    ## American studies and sociology at the
    ##                                                                explores racial justice in the city. Photo: Iván
    ## University of Illinois at Chicago. “The more
    ##                                                                                    Arenas
    ## than 830,000 black Chicagoans still here
    ## make the city an important center of black life and culture in the United States and
    ## reinforces the urgency in ensuring that city policies are designed to address the needs of all
    ## neighborhoods and all Chicagoans.”
    ## 

## Running LexRank

Once we have imported the texts from the articles, we can go ahead and
perform Lexranking.

The LexRank algorithm essentially rank the sentences in the original
text, giving an importance score to each of them. Then, we can get a
summary of the article by extracting the top few sentences with the
highest rankings.

Let’s use the NBC Chicago news as an example. Applying LexRank algorithm
on it:

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

Here we get the top 4 ranked sentences from the article by specifying n
= 4. We created identical docID for all elements in the input vector
because there is only 1 document.

The sentence ID represnet the order in which these sentences appear in
the article. To make it more readable, we also sort the output in the
article order.

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

Here you have it\! The summary of the article in 4 sentences.

## Further Investigation

### Keywords

To take it further, another way to summarize text is to extract keywords
from it. The basic approach for extracting keywords is finding the words
that are most frequently occuring and occur somehow together in a plain
text. There are more sophisticated methods of extracting the keywords
that not only consider their frequency of occurence, but also things
like the type of words (noun, adj, verb) and their interaction with
other words in the article. Here I use the
[**Textrank**](https://cran.r-project.org/web/packages/textrank/vignettes/textrank.html)
algorithm to extract keywords from the article into multi-word phrases.

Let’s use the pdf article we read in earliear this time. Before applying
the textrank algorithm, we first need to annotate the text. **Text
Annotation** in natural language processing is basically a way to label
and break down the raw sentences to make them more understandable to a
machine learning algorithm, and also avoid feeding too much information
into the model that can lead to overfitting. This can be done using the
**udpipe** package in R.

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
    ##                                                                                                                                        sentence
    ## 1 UIC Today UIC report examines black population loss in Chicago today.uic.edu/uic-report-examines-black-population-loss-in-chicago Brian Flood
    ## 2 UIC Today UIC report examines black population loss in Chicago today.uic.edu/uic-report-examines-black-population-loss-in-chicago Brian Flood
    ## 3 UIC Today UIC report examines black population loss in Chicago today.uic.edu/uic-report-examines-black-population-loss-in-chicago Brian Flood
    ## 4 UIC Today UIC report examines black population loss in Chicago today.uic.edu/uic-report-examines-black-population-loss-in-chicago Brian Flood
    ## 5 UIC Today UIC report examines black population loss in Chicago today.uic.edu/uic-report-examines-black-population-loss-in-chicago Brian Flood
    ## 6 UIC Today UIC report examines black population loss in Chicago today.uic.edu/uic-report-examines-black-population-loss-in-chicago Brian Flood
    ##   token_id    token   lemma  upos xpos
    ## 1        1      UIC     UIC PROPN  NNP
    ## 2        2    Today   today PROPN  NNP
    ## 3        3      UIC     UIC PROPN  NNP
    ## 4        4   report  report  NOUN   NN
    ## 5        5 examines examine  VERB  VBZ
    ## 6        6    black   black   ADJ   JJ
    ##                                                   feats head_token_id
    ## 1                                           Number=Sing             4
    ## 2                                           Number=Sing             3
    ## 3                                           Number=Sing             1
    ## 4                                           Number=Sing             5
    ## 5 Mood=Ind|Number=Sing|Person=3|Tense=Pres|VerbForm=Fin             0
    ## 6                                            Degree=Pos             7
    ##    dep_rel deps
    ## 1 compound <NA>
    ## 2 compound <NA>
    ## 3     flat <NA>
    ## 4    nsubj <NA>
    ## 5     root <NA>
    ## 6     amod <NA>
    ##                                                                                                                                                                  misc
    ## 1 SpacesBefore=\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s\\s
    ## 2                                                                                                                                                  SpacesAfter=\\r\\n
    ## 3                                                                                                                                                                <NA>
    ## 4                                                                                                                                                                <NA>
    ## 5                                                                                                                                                                <NA>
    ## 6                                                                                                                                                                <NA>

As you can see, this process breaks down the original article into
pieces of information that the model can more easily read in. Next, we
apply the textrank algorithm. Here I want to find the key phrases that
are a combination of nouns and adjectives:

``` r
library(textrank)
# keywords
keywd <- textrank_keywords(article$lemma,
                          relevant = article$upos %in% c("NOUN", "ADJ"), sep = " ")
keyw <- keywd$keywords
keyw[1:20,]
```

    ##                keyword ngram freq
    ## 1                black     1   15
    ## 2                 city     1   10
    ## 3               report     1    9
    ## 4           population     1    9
    ## 5            professor     1    9
    ## 6               racial     1    8
    ## 7            community     1    7
    ## 8     black population     2    6
    ## 9               policy     1    6
    ## 10            american     1    5
    ## 11           migration     1    4
    ## 12             housing     1    4
    ## 13              public     1    3
    ## 14             ongoing     1    3
    ## 15        unemployment     1    3
    ## 16                such     1    3
    ## 17               white     1    3
    ## 18 assistant professor     2    3
    ## 19    african american     2    3
    ## 20              health     1    2

As you can see, the keywords are summarized by their frequency of
occurence, as well as the thing called ngram, which is basically the
number of co-occuring words in the phrase.

If we are only interested in the key phrases with multiple words, we
could specifiy ngram \> 1:

``` r
keyw %>% filter(ngram > 1)
```

    ##                keyword ngram freq
    ## 1     black population     2    6
    ## 2  assistant professor     2    3
    ## 3     african american     2    3
    ## 4      black community     2    2
    ## 5     ongoing national     2    1
    ## 6        public policy     2    1
    ## 7          city policy     2    1
    ## 8       public housing     2    1
    ## 9     white population     2    1
    ## 10   lower educational     2    1
    ## 11    many area expert     3    1
    ## 12         area expert     2    1
    ## 13   major demographic     2    1
    ## 14  american community     2    1

### Visualization of keywords: Wordcloud

To take it even one more step further, we can use a wordcloud to
visually present the keywords in the article. The bigger the texts are
in the graph, the more important or frequently occuring they are in the
article.

First, I want to make sure that I keep all the multi-word phrases in the
wordcloud. But if the article is too short and there are not that many
phrases left, I add in the other keywords.

``` r
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

library(wordcloud)
wordcloud(words = toplot$keyword, freq = toplot$freq, scale=c(4,0.5),colors = brewer.pal(6, "Dark2"), max.words = 20, min.freq = 1)  
```

![](ReadMe_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

![cloud](https://github.com/Xiaoma7/Text-summarization/blob/master/unnamed-chunk-10-1.png)

## Putting it all together: R shiny app

To combine all the work I did into something more presentable and user
friendly, I built a shiny app that does article summarization using the
methods discussed above. **You can access the app by clicking the link
here** (<https://ruo-ma.shinyapps.io/Article_Summarizer/>).

Please note that I am using a free version of the shiny app server so
there is 25 hour limit on the active time the app can have each month.
Please do not over stay.

### Type of article source

This app allows two types of article sources: 1) Link from the web, 2)
Upload from local computer.

![Mode
selection](https://github.com/Xiaoma7/Text-summarization/blob/master/Capture1.PNG)

If you are using the **Web page** mode, copy and paste the link to
online article into the box:

![Web
Mode](https://github.com/Xiaoma7/Text-summarization/blob/master/Capture1.5.PNG)

In the **Local file upload** mode, click on the “Browse” button and
upload an article from your computer.

![local
mode](https://github.com/Xiaoma7/Text-summarization/blob/master/Capture3.PNG)

Once you are done inputting the article, click on the **Summarize \!**
button to generate the summary sentences and keywords plots for the
article:

![outweb](https://github.com/Xiaoma7/Text-summarization/blob/master/Capture2.PNG)

![outpdf](https://github.com/Xiaoma7/Text-summarization/blob/master/Capture4.PNG)
