# Ici nous avons mis toutes les fonctions du projet
# Ca a pris du temps a organiser

library(RSQLite)
library(ggplot2)

get_conn <- function() {
  dbConnect(SQLite(), "IGEA2_bdd_forages.db")
}

# ajouter forage
ajouter_forage <- function(nom, type, localisation, profondeur, date_creation, coordonnees) {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  if(!type %in% c("Forage","Puits","Source")){
    cat("Type incorrect ! doit etre Forage Puits ou Source\n")
    return()
  }
  
  dbExecute(conn, "INSERT INTO Forages (nom,type,localisation,profondeur,date_creation,coordonnees) VALUES (?,?,?,?,?,?)",
            params=list(nom,type,localisation,profondeur,date_creation,coordonnees))
  
  cat("Forage ajoute !\n")
}

# ajouter analyse
save_analyse <- function(id_forages, ph, conductivite, turbidite, nitrates, commentaires="") {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  ph <- suppressWarnings(as.numeric(ph))
  conductivite <- suppressWarnings(as.numeric(conductivite))
  turbidite <- suppressWarnings(as.numeric(turbidite))
  nitrates <- suppressWarnings(as.numeric(nitrates))
  
  dbExecute(conn, "INSERT INTO Analyses (id_forages,date_analyse,ph,conductivite,turbidite,nitrates,commentaires) 
            VALUES (?,DATE('now'),?,?,?,?,?)", 
            params=list(id_forages,ph,conductivite,turbidite,nitrates,commentaires))
  
  cat("Analyse enregistree\n")
}

# verifier eau
check_conformite <- function(id_forages) {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  res <- dbGetQuery(conn, "SELECT a.*,f.nom FROM Analyses a JOIN Forages f ON a.id_forages=f.id_forages WHERE a.id_forages=? ORDER BY date_analyse DESC LIMIT 1", params=list(id_forages))
  
  if(nrow(res)==0){
    cat("Pas d'analyse pour ce forage\n")
    return()
  }
  
  cat("\n--- Bulletin ---\n")
  cat("Forage:", res$nom,"\n")
  
  # verification rapide
  if(!is.na(res$ph) && (res$ph <6.5 || res$ph >8.5)) cat("pH mauvais\n")
  if(!is.na(res$turbidite) && res$turbidite >5) cat("Turbidite mauvaise\n")
  if(!is.na(res$nitrates) && res$nitrates >50) cat("Nitrates trop haut\n")
  
  cat("Fin du bulletin\n")
}

# historique
voir_historique <- function(id) {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  histo <- dbGetQuery(conn, "SELECT * FROM Analyses WHERE id_forages=?", params=list(id))
  print(histo)
}

# export
export_nonconformes <- function() {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  if(!dir.exists("rapports")) dir.create("rapports")
  
  bad <- dbGetQuery(conn, "SELECT * FROM Analyses a JOIN Forages f ON a.id_forages = f.id_forages WHERE ph<6.5 OR ph>8.5 OR turbidite>5 OR nitrates>50")
  if(nrow(bad)>0){
    write.csv(bad, "rapports/non_conformes.csv", row.names=FALSE)
    cat("Export fait\n")
  } else {
    cat("Rien a exporter\n")
  }
}

# graphiques
faire_graphiques <- function() {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  data <- dbGetQuery(conn, "SELECT f.nom, a.ph, a.turbidite FROM Analyses a JOIN Forages f ON a.id_forages=f.id_forages")
  
  if(nrow(data)==0){
    cat("Pas de donnees pour les graphs\n")
    return()
  }
  
  p <- ggplot(data, aes(x=nom, y=turbidite)) + geom_boxplot()
  print(p)
  cat("Graphique affiche\n")
}