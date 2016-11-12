#############################################################################################################################################
# packages
#############################################################################################################################################

require(shiny)
require(leaflet)
require(rgdal)
require(artyfarty)
require(shinythemes)

#############################################################################################################################################
# ui
#############################################################################################################################################


setwd("C:/Users/akruse/Documents/R/thru/shiny")
mydata <- read.table("export01.csv", header = T, sep = "\t")
mydata$jahr <- as.numeric(mydata$jahr)

# ui
shinyUI(
  bootstrapPage(theme = shinytheme("cyborg"),div(class="outer",includeCSS("style.css"),
                                                 
 navbarPage(title="Umweltverschmutzer in Hamburg", inverse = T,
            tabPanel("Karte",
                     sidebarLayout(
                       mainPanel(leafletOutput("thru.map", height = "820")),
                       sidebarPanel(h3("Was geht hier ab?"),
                                    p("Moin! Wie viele Schadstoffe stößt der Industriebetrieb in meiner Nachbarschaft aus? Welche Stoffe sind immer noch in den Abwässern enthalten, die die Kläranlagen verlassen? Antworten auf diese und zahlreiche weitere Fragen erhalten Sie mit Hilfe dieser interaktiven Karte. Wenn Sie auf einen der farbigen Punkte in der Karte klicken, erhalten Sie weitere Informationen zu dem jeweiligen Umweltverschmutzer."),
                                    br(),
                                    selectInput("stoff", "Welcher Schadstoff soll auf der Karte angezeigt werden?", unique(mydata$stoff_name)),
                                    sliderInput("obs", "Zeitraum:",
                                                min = min(mydata$jahr), max = max(mydata$jahr), value = c(min(mydata$jahr),max(mydata$jahr)), 
                                                step = 1, sep = "", ticks = F),
                                    checkboxInput("legende", "Legenden", T),
                                    width = 3
                                    ),
                       position = "right"
                       )
                     ),
            tabPanel("Branchenanteile",
                     fluidPage(
                       titlePanel(""),
                           plotOutput("stoffPlot", height = "800px")

                         )
            ),
            tabPanel("About",
sidebarPanel(
HTML('<p style="text-align:justify"><strong>Allgemeines:</strong> Diese Web-App wurde mit <a href="http://shiny.rstudio.com/", target="_blank">Shiny</a> gebaut.<p style="text-align:justify"><strong>Code:</strong> Den Code für die Shiny-App findet man <a href="https://github.com/kruse-alex", target="_blank">hier</a>.<p style="text-align:justify"><strong>Daten:</strong> Die Daten zur Umweltverschmutzung kommen von <a href="http://www.thru.de", target="_blank">Thru.de</a>. Im Thru.de-Portal finden Sie Schadstoffemissionen von knapp 5.000 Betrieben aufgelistet. Es handelt sich meist um größere Betriebe. Grundsätzlich müsse alle Betriebe über ihre Schadstoffemissionen berichten, die eine Tätigkeit ausüben, die die EU in der europäischen E-PRTR-Verordnung nennt. Dieses Gesetz gilt in allen EU-Staaten seit 2006. Berichtspflichtig sind etwa Kraftwerke, Raffinerien, Chemiebetriebe oder die Lebensmittelindustrie, aber auch Deponien und Kläranlagen. Diese Betriebe müssen aber nur dann über ihre Freisetzungen in Thru.de berichten, wenn sie eine gewisse Größe überschreiten und wenn sie zudem eine beträchtliche Menge eines Schadstoffs in die Umwelt freisetzen oder sehr viel Abfall außerhalb ihres Betriebes entsorgen. Es gibt sowohl Schwellenwerte für Freisetzungen in die Luft, ins Wasser, in den Boden als auch für den Abfluss von Abwasser in externe Kläranlagen. Diese zahlreichen Schwellenwerte sollen dafür sorgen, dass nur große Industriebetriebe im Portal Thru.de enthalten sind, die einen bedeutenden Teil zur Emission von Schadstoffen oder Verbringung von Abfällen beitragen. Die Grenzdaten von Hamburg findet man <a href="http://opendata.esri-de.opendata.arcgis.com/datasets/b2beb2adb4c1466d8a3889472cac1e34_0", target="_blank">hier</a>.<p style="text-align:justify"></p>'),
HTML('<p>Cheers!<br/></p>'),
value="about"
))))))