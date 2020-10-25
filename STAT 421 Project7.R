#########################################################################################

# Goal 1:  Fit a ABM to the best of your ability to the country you have been assigned

########################################################################################


# read in data
data <- read.csv("GlobalCovid19-2020-04-20.csv")
Spain <- data[ data$Country == "Spain" ,  ]

plot(Spain$Date, Spain$Confirmed)
points(Spain$Date, Spain$Deaths, col = "red")
points(Spain$Date, Spain$Recovered, col = "green")

Spain <- Spain[Spain$Confirmed > 0, ]
# Adjust Infected to remove the people who have died and the people who recovered from confirmed
Spain$AdjInfect <- Spain$Confirmed - Spain$Recovered - Spain$Deaths #makes a new column in data frame "Spain"

# Export to Excel to scale Spain
write.csv( Spain, "SpainScale.csv", row.names = TRUE)

#*** Edit in Excel ***#

library(readr)
SpainScale <- read_csv("SpainScale.csv")

SpainScale <- read.csv("SpainScale.csv")



data2 <- read.csv("globalStats4-28.csv", header = T)
Spain2 <- data2[ data2$Country == "Spain", ]




################## being building agent based model

AgentGen1 <- function(nPop1, E0, I0){
  # Create a population of susceptibles
  Agent1 <- data.frame( AgentNo = nPop1,
                        Status = "S",     # SEIRD
                        Mixing = runif( nPop1, 0, 1 ),  # How likely to mix?
                        TimeE = 0,
                        TimeI = 0,
                        stringsAsFactors = FALSE )
  Agent1$Status[1:E0] <- "E"
  Agent1$TimeE[1:E0] <- rbinom(E0, 13, 0.5) + 1
  Agent1$Status[(E0+1):(E0 + I0)] <- "I"
  Agent1$TimeI[(E0+1):(E0+I0)] <- rbinom(I0, 12, 0.5) + 1
  return(Agent1)
}

# Builds a population of Agents
#nPop1 <- 100 # Number additional Agents

ABM1 <- function(Agent1, par1, nTime1){
  nPop1 <- nrow(Agent1)
  Out1 <- data.frame(S = rep(0, nTime1),
                     E  = rep(0, nTime1),
                     I  = rep(0, nTime1),
                     R  = rep(0, nTime1),
                     D  = rep(0, nTime1))

# move peoeple through time
for(k in 1:nTime1){
  StateS1 <- (1:nPop1)[Agent1$Status == "S"] #list of everyone in susceptible state
  StateSE1 <- (1:nPop1)[Agent1$Status == "S" | Agent1$Status == "E"] #grabs people who are in both groups 
  #moving people through time
  for(i in StateS1){
  #Determine whether they like to meet others
  Mix1 <- Agent1$Mixing[ i]
  #How many agents they will meet
  Meet1 <- round(Mix1*par1$MaxMix,0) + 1  #makes sure everyone meets at least 1 person
  #Grab the ones they will meet
  Meet2 <- sample(StateSE1, Meet1, replace = TRUE, prob = Agent1$Mixing[StateSE1])
  for( j in 1:length(Meet2) ){
    #Grab who they will meet
    Meet1a <- Agent1[Meet2[j], ]
    # if exposed change state
    if( Meet1a$Status == "E" ){
      Urand1 <- runif(1,0,1)
      if(Urand1 < par1$S2E){
      Agent1$Status[i] <- "E"
      }
    }
  }

  }
  
  StateE1 <- (1:nPop1)[Agent1$Status == "E"] #get a list of all people who are exposed
  Agent1$TimeE[StateE1] <- Agent1$TimeE[StateE1] + 1 #increment their exposed time
  StateE2 <- (1:nPop1)[Agent1$Status == "E" & Agent1$TimeE > 14]
  Agent1$Status[StateE2] <- "R"
  # grab those who could become sick
  StateE3 <- (1:nPop1)[Agent1$Status == "E" & Agent1$TimeE > 3]
  # randomly assign whether they become sick or not
  for(i in StateE3){
    Urand1 <- runif(1,0,1)
    if(Urand1 < par1$E2I){
      Agent1$Status[i] <- "I"
    }
  }
  
  # update how long they have been sick
  StateI1 <- (1:nPop1)[Agent1$Status == "I"]
  Agent1$TimeI[StateI1] <- Agent1$TimeI[StateI1] + 1
  StateI2 <- (1:nPop1)[Agent1$Status == "I" & Agent1$TimeI > 14]
  Agent1$Status[StateI2] <- "R"
  StateI3 <- (1:nPop1)[Agent1$Status == "I" & Agent1$TimeI < 15]
  Agent1$Status[StateI3] <- ifelse(runif(length(StateI3),0,1) > par1$I2D, "I", "D")
  
  Out1$S[k ] <- length( Agent1$Status[Agent1$Status == "S"]) 
  Out1$E[k ] <- length( Agent1$Status[Agent1$Status == "E"]) 
  Out1$I[k ] <- length( Agent1$Status[Agent1$Status == "I"]) 
  Out1$R[k ] <- length( Agent1$Status[Agent1$Status == "R"]) 
  Out1$D[k ] <- length( Agent1$Status[Agent1$Status == "D"]) 
}
  return(Out1)
}

############################################################################
## this is where we play with parameters to fit the model to the data #####



plot( 1:79, Model1$S, type = "l", col = "purple", ylim = c(0, 600))
lines(1:79, Model1$E, col = "orange")
lines(1:79, Model1$I, col = "red")
lines(1:79, Model1$R, col = "seagreen")
lines(1:79, Model1$D, col = "black")

Agent1 <- AgentGen1(4670, E0 = 5, I0 = 2)
par1 <- data.frame( MaxMix = 5,     #5
                    S2E = 0.03,   #0.02
                    E2I = 0.014,  #0.014
                    I2D = 0.007)  #0.007
Model1 <- ABM1( Agent1, par1, nTime = 79)

plot(1:79, SpainScale$AdjInfect_Scale[1:79], col = "red")
lines(1:79, Model1$I, col = "red")

plot(1:79, SpainScale$Recovered_Scale[1:79], col = "seagreen")
lines(1:79, Model1$R, col = "seagreen")

plot(1:79, SpainScale$Deaths_Scale[1:79], col = "black")
lines(1:79, Model1$D, col = "black")



