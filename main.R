# main.R - Programme principal - Gestion des Forages
# IGEA 2 - Projet Informatique

source("fonctions.R")  # Chargement des fonctions
source("init_db.R")    # On s'assure que la BD existe (exécuté une seule fois)

cat("\n")
cat("==========================================\n")
cat("   GESTION DES FORAGES & QUALITÉ DE L'EAU\n")
cat("          IGEA 2 - Projet Informatique\n")
cat("==========================================\n\n")

menu_principal <- function() {
  repeat {
    cat("\n--- MENU PRINCIPAL ---\n")
    cat("1. Ajouter un nouveau forage\n")
    cat("2. Enregistrer une analyse de qualité\n")
    cat("3. Vérifier la conformité d'un forage\n")
    cat("4. Voir l'historique d'un forage\n")
    cat("5. Lister tous les forages\n")
    cat("6. Exporter les analyses non conformes (CSV)\n")
    cat("7. Visualisations graphiques\n")
    cat("8. Quitter\n\n")
    
    choix <- readline("Votre choix (1-8) : ")
    
    if (choix == "1") {
      cat("\n--- Ajout d'un forage ---\n")
      nom <- readline("Nom du forage : ")
      type <- readline("Type (Forage/Puits/Source) : ")
      loc <- readline("Localisation : ")
      prof <- as.numeric(readline("Profondeur (m) : "))
      date_c <- readline("Date de création (AAAA-MM-JJ) : ")
      coord <- readline("Coordonnées GPS (ex: 10.25,15.36) : ")
      
      ajouter_forage(nom, type, loc, prof, date_c, coord)
      
    } else if (choix == "2") {
      cat("\n--- Nouvelle analyse ---\n")
      id_f <- as.integer(readline("ID du forage : "))
      ph <- as.numeric(readline("pH : "))
      cond <- as.numeric(readline("Conductivité (µS/cm) : "))
      turb <- as.numeric(readline("Turbidité (NTU) : "))
      nit <- as.numeric(readline("Nitrates (mg/L) : "))
      comm <- readline("Commentaires (optionnel) : ")
      
      enregistrer_analyse(id_f, ph, cond, turb, nit, comm)
      
    } else if (choix == "3") {
      id_f <- as.integer(readline("ID du forage à vérifier : "))
      verifier_conformite(id_f)
      
    } else if (choix == "4") {
      id_f <- as.integer(readline("ID du forage : "))
      historique_forage(id_f)
      
    } else if (choix == "5") {
      conn <- get_conn()
      forages <- dbGetQuery(conn, "SELECT * FROM Forages ORDER BY id_forages")
      dbDisconnect(conn)
      if (nrow(forages) == 0) {
        cat("Aucun forage enregistré.\n")
      } else {
        print(forages)
      }
      
    } else if (choix == "6") {
      export_non_conformes()
      
    } else if (choix == "7") {
      visualisations()
      
    } else if (choix == "8") {
      cat("Au revoir !\n")
      break
    } else {
      cat("Choix invalide !\n")
    }
  }
}

# VISUALISATIONS (ggplot2) 
visualisations <- function() {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  data <- dbGetQuery(conn, "
    SELECT f.nom, a.date_analyse, a.ph, a.turbidite, 
           a.nitrates, a.conductivite 
    FROM Analyses a 
    JOIN Forages f ON a.id_forages = f.id_forages
    ORDER BY a.date_analyse
  ")
  
  if (nrow(data) == 0) {
    cat("Aucune analyse enregistrée pour les graphiques.\n")
    return()
  }
  
  # Graphique 1 : Évolution du pH
  p1 <- ggplot(data, aes(x = date_analyse, y = ph, color = nom, group = nom)) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    labs(title = "Évolution du pH par forage", x = "Date", y = "pH") +
    theme_minimal()
  print(p1)
  
  # Graphique 2 : Turbidité
  p2 <- ggplot(data, aes(x = nom, y = turbidite, fill = nom)) +
    geom_boxplot() +
    labs(title = "Distribution de la turbidité", x = "Forage", y = "Turbidité (NTU)") +
    theme_minimal()
  print(p2)
  
  cat("✅ Graphiques générés avec succès !\n")
}

# Lancement du programme
menu_principal()