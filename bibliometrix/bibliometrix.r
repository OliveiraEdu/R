# SCRIPT PARA O PACKAGE "BIBLIOMETRIX"

## START

# Field tags ---------------------------------------------------------------
link <- "http://www.bibliometrix.org/documents/Field_Tags_bibliometrix.pdf"
download.file(link, "FieldTags.pdf")


# Carregar pacote -----------------------------------------------------------
ifelse ( !require(bibliometrix),
         install.packages (
           "bibliometrix", 
           dependencies=TRUE), "Pacote carregado" ) # instalar pacote
                                                    #se necessário

require(bibliometrix)


# Carregar bases de dados ---------------------------------------------------
## Bibitex
WoSA <- "savedrecs.bib"

WoSB <- "savedrecs(2).bib"

WoSC <- "savedrecs(3).bib"

WoSD <- "savedrecs_D.bib"

WoSE <- "savedrecs_E.bib"

Scopus <- "scopus(2).csv"

pubmed <- "pubmed-OpenScienc-set(1).txt"

## Data-frame
WoSA_df <- convert2df( 
   WoSA, 
   dbsource = "wos", 
   format = "bibtex" )
head(WoSA_df["TC"])

WoSB_df <- convert2df( 
  WoSB, 
  dbsource = "wos", 
  format = "bibtex" )
head(WoSB_df["TC"])

WoSC_df <- convert2df(
  WoSC,
  dbsource = "wos",
  format = "bibtex" )
head(WoSC_df["TC"])

WoSD_df <- convert2df( 
  WoSD, 
  dbsource = "wos", 
  format = "bibtex" )

WoSE_df <- convert2df( 
  WoSE, 
  dbsource = "wos", 
  format = "bibtex" )

Scopus_df <- convert2df( 
  Scopus, 
  dbsource = "scopus", 
  format = "csv" )

head(Scopus_df["TC"])

pubmed_df <- convert2df( 
  pubmed, 
  dbsource = "pubmed", 
  format = "pubmed" )

head(pubmed_df["TC"])


# Criar objeto com as bases unificadas -------------------------------------
M <- mergeDbSources( #WoSA_df, 
                     WoSB_df,
                     WoSC_df,
                     WoSD_df, 
                     WoSE_df, 
                     Scopus_df,
                     pubmed_df,
                     remove.duplicated = TRUE)

head(M["TC"])

# Criar arquivo *.csv a partir do objeto M (bases WoS e Scopus) ------------
# write.csv(M, "dataset.csv")

# Criar arquivo .RData
save(M, file = "SLR_6.RData")
##END
               
# Biblioshiny --------------------------------------------------------------
biblioshiny() # necessita que o package "bibliometrix" 
              # esteja carregado (linha 17)


