#Assignment One

rm(list=ls())

library(tidyverse)
library(tidycensus)
library(ipumsr)

#Getting data from IPUMS API

    #set_ipums_api_key("paste-your-key-here", save = TRUE) #Sets your personal key and saves it
    
    tst <- get_metadata_nhgis("time_series_tables") #This gives you a list of the time series tables that you can get
    
    ***[Question 2]***
    
    #data_names <- c("A00","A57","B57","B18","CL6","B69") #These are the tables we are using

    data_ext<- define_extract_nhgis(
                  description = "ECON 691",
                  time_series_tables =  list(
                      tst_spec("A00", "state"),
                      tst_spec("A57", "state"),
                      tst_spec("B57", "state"),
                      tst_spec("B18", "state"),
                      tst_spec("CL6", "state"),
                      tst_spec("BX3", "state")
                  )
                )
    
    ts<-submit_extract(data_ext)
    wait_for_extract(ts)
    filepath <- download_extract(ts)
    
    dat <- read_nhgis(filepath)

#Basic Clan of data
    
    dat2 <- dat %>%
      select(STATEFP, ends_with(c("1970", "1980", "1990", "2000", "2010", "105", "2020", "205"))) %>%
      filter(!is.na(STATEFP)) %>%
      pivot_longer(!STATEFP, names_to = "series", values_to = "estimate") %>%
      mutate(series = str_replace(series, "105", "2010"),
             series = str_replace(series, "205", "2020"),
             year = substr(series, 6, nchar(series)),
             series = substr(series, 1, 5)) %>%
      distinct(STATEFP, series, year, .keep_all = TRUE) %>%
      filter(!is.na(estimate)) %>%
      pivot_wider(id_cols = c(STATEFP, year), names_from = series, values_from = estimate) %>%
      select(-B18AE)  %>%
      mutate(und18 = rowSums(across(B57AA:B57AD)) / A00AA,
             over65 = rowSums(across(B57AP:B57AR)) / A00AA,
             white = [insert code here], #White Population
             black = [insert code here], #Black Population
             asian = [insert code here], #Asian Population
             other = [insert code here], #Something other than the above including multi-race
             lessHS = (BX3AA + BX3AB + BX3AC + BX3AG + BX3AH + BX3AI) / A00AA,
             HSCOL =  [insert code here], #12th Grade and some college
             UNGRD =  [insert code here], #4 years of college or Bach Degree
             ADVDG =  [insert code here], #More than 4 years or advanced degree
             POV =  [insert code here]) %>% #Share of population under Poverty Line
      select(STATEFP, year, A00AA, und18:POV) %>%
      rename("TOTPOP" = "A00AA")
 
    #Obtain Census Map Data
    
    ***[Question 4A]***
    
    cen.stat <- get_acs(geography = "state", 
                        survey = "acs5",
                        variables = "B01003_001E", 
                        year = 2020,
                        geometry = TRUE)
    
    cen.map <- cen.stat %>%
      select([Insert what is needed to keep only the GEOID, Name, and geometry]) 
    
    #Join the data and Map it
    
    core <- [Main Data] %>%
      left_join(., [Other Data], by = [Common Vector in Quotation Marks])   
    
    
    #Non-Race Variable
    
    ggplot(core) +
      geom_sf(aes(fill = [Your Vector])) +
      scale_fill_gradient2(low = "white", high = "blue", na.value = NA, 
                           name = [Name for Legend inside quotation marks],
                           limits = c(0, .5)) +
      theme_bw()+
      theme(axis.ticks = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            legend.position = "bottom") +
      labs(title = "Percentage of Population [Insert What You Are Graphing] Across the Decades") +
      facet_wrap(~ year)
    
    #Race Variable
    
    ggplot(core) +
      geom_sf(aes(fill = [Your Vector])) +
      scale_fill_gradient2(low = "white", high = "blue", na.value = NA, 
                           name = [Name for Legend inside quotation marks],
                           limits = c(0, 1)) +
      theme_bw()+
      theme(axis.ticks = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            legend.position = "bottom") +
      labs(title = "Percentage of Population [Insert What You Are Graphing] Across the Decades") +
      facet_wrap(~ year)
    