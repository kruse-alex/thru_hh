#############################################################################################################################################
# packages
#############################################################################################################################################

require(shiny)
require(leaflet)
require(rgdal)
require(ggplot2)
require(artyfarty)
require(dplyr)
require(data.table)
require(scales)

#############################################################################################################################################
# server
#############################################################################################################################################

shinyServer(
  function(input, output, session){
    
    setwd("C:/Users/akruse/Documents/R/thru/shiny")
    mydata <- read.table("export01.csv", header = T, sep = "\t")
    mydata$jahresfracht <- format(mydata$jahresfracht, scientific = F)
    mydata$jahresfracht <- round(as.numeric(mydata$jahresfracht, 0))
    hhshape <- readOGR(dsn = ".", layer = "HH_ALKIS_Landesgrenze")
    
    observe({

      # filter on stoff
      mydata <- filter(mydata, stoff_name == paste(input$stoff))
      mydata <- filter(mydata, jahr <= max(input$obs) & jahr >= min(input$obs))
      mydata <- mydata %>% group_by(name) %>% summarise(jahresfracht = sum(jahresfracht),
                                                        x = wgs84_x[1],
                                                        y = wgs84_y[1],
                                                        Taetigkeit = Taetigkeit[1],
                                                        Umweltkompartiment = Umweltkompartiment[1])
  
      
      # color palette
      pal <- colorNumeric(
        palette = "Reds",
        domain = mydata$jahresfracht
        )
      
      # create pop up
      popup <- paste0("<strong>Unternehmen: </strong>", 
                            mydata$name,
                      "<br><strong>Tätigkeit: </strong>", 
                      mydata$Taetigkeit,
                      "<br><strong>Umweltkompartiment: </strong>", 
                      mydata$Umweltkompartiment,
                      "<br><strong>Jahresfracht: </strong>", 
                      mydata$jahresfracht)
      
      # map
      output$thru.map <-  renderLeaflet({
        
        thru.map <- leaflet(mydata) %>% 
          setView(lng =  9.993682, lat = 53.551085, zoom = 11) %>%
          addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>')
        thru.map %>% 
          clearShapes() %>%
          addPolygons(data = hhshape, stroke = T, smoothFactor = 0.2, fillOpacity = 0.2, color = "blue", weight = 2) %>%
          addCircles(lng = mydata$x, lat = mydata$y, popup = popup, fillOpacity = 100, color = pal(mydata$jahresfracht), stroke = F, radius = 200)
      })
      
      output$stoffPlot <- renderPlot({
        
        setwd("C:/Users/akruse/Documents/R/thru/shiny")
        check <- read.table("export01.csv", header = T, sep = "\t")
        check$jahresfracht <- format(check$jahresfracht, scientific = F)
        check$jahresfracht <- round(as.numeric(check$jahresfracht, 0))
        
        check <- check %>% group_by(branchengruppe, stoff_name) %>% summarise(jahresfracht = sum(jahresfracht))
        check <- filter(check, jahresfracht > 0)
        
        ggplot(check, aes(x = stoff_name, y = jahresfracht, fill = branchengruppe)) +
          geom_bar(position = "fill", stat = "identity") +
          coord_flip() +
          theme_monokai_full() +
          scale_y_continuous(labels = percent) +
          theme(text = element_text(size=20)) +
          xlab("") +
          ylab("") +
          theme(legend.title=element_blank(), legend.position="bottom") +
          ggtitle("Branchenanteile Schadstoffe (für Hamburg)")
      })
      
    })
    
    
    # dynamic legend
    observe({
      
      mydata <- filter(mydata, stoff_name == paste(input$stoff))
      mydata <- filter(mydata, jahr <= max(input$obs) & jahr >= min(input$obs))
      mydata <- mydata %>% group_by(name) %>% summarise(jahresfracht = sum(jahresfracht),
                                                        x = wgs84_x[1],
                                                        y = wgs84_y[1],
                                                        Taetigkeit = Taetigkeit[1],
                                                        Umweltkompartiment = Umweltkompartiment[1])
    
      proxy <- leafletProxy("thru.map", data = mydata)
      
      proxy %>% clearControls()
      if (input$legende) {
        
        # color palette
        pal <- colorNumeric(
          palette = "Reds",
          domain = mydata$jahresfracht)
        
        proxy %>% addLegend(position = "bottomright", title = "Gesamtfracht",
                            pal = pal, values = ~jahresfracht)
        
        }
      })
    })