# =============================================
# fonctions.R - Fonctions métier du projet
# Projet 3 : Gestion des Forages et Qualité de l'Eau
# =============================================

library(RSQLite)
library(dplyr)
library(ggplot2)
library(jsonlite)

# Connexion à la BD
get_conn <- function() {
  dbConnect(SQLite(), "IGEA2_bdd_forages.db")
}

# 1. Ajouter un forage
ajouter_forage <- function(nom, type, localisation, profondeur, date_creation, coordonnees) {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  # Validation du type
  types_autorises <- c("Forage", "Puits", "Source")
  if (!type %in% types_autorises) {
    cat("❌ Erreur : Le type doit être 'Forage', 'Puits' ou 'Source'\n")
    return(NULL)
  }

  query <- "INSERT INTO Forages (nom, type, localisation, profondeur, date_creation, coordonnees) 
            VALUES (?, ?, ?, ?, ?, ?)"
  
  dbExecute(conn, query, params = list(nom, type, localisation, profondeur, date_creation, coordonnees))
  cat("✅ Forage ajouté avec succès !\n")
}

# 2. Enregistrer une analyse (version robuste)
enregistrer_analyse <- function(id_forages, ph, conductivite, turbidite, nitrates, commentaires = "") {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  # Nettoyage automatique des entrées
  ph <- suppressWarnings(as.numeric(ph))
  conductivite <- suppressWarnings(as.numeric(conductivite))
  turbidite <- suppressWarnings(as.numeric(turbidite))
  nitrates <- suppressWarnings(as.numeric(nitrates))
  
  query <- "INSERT INTO Analyses (id_forages, date_analyse, ph, conductivite, turbidite, nitrates, commentaires) 
            VALUES (?, DATE('now'), ?, ?, ?, ?, ?)"
  
  dbExecute(conn, query, params = list(id_forages, ph, conductivite, turbidite, nitrates, commentaires))
  cat("✅ Analyse enregistrée avec succès !\n")
}

# 3. Vérifier conformité (améliorée)
verifier_conformite <- function(id_forages) {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  analyse <- dbGetQuery(conn, "
    SELECT a.*, f.nom 
    FROM Analyses a 
    JOIN Forages f ON a.id_forages = f.id_forages 
    WHERE a.id_forages = ? 
    ORDER BY a.date_analyse DESC LIMIT 1", params = list(id_forages))
  
  if (nrow(analyse) == 0) {
    cat("Aucune analyse trouvée pour ce forage.\n")
    return(NULL)
  }
  
  cat("\n=== BULLETIN DE CONFORMITÉ ===\n")
  cat("Forage :", analyse$nom, "\n")
  cat("Date  :", analyse$date_analyse, "\n\n")
  
  non_conforme <- FALSE
  
  # Vérifications
  if (!is.na(analyse$ph)) {
    if (analyse$ph < 6.5 || analyse$ph > 8.5) {
      cat("❌ pH hors norme (", analyse$ph, ")\n")
      non_conforme <- TRUE
    } else cat("✓ pH conforme\n")
  }
  
  if (!is.na(analyse$conductivite) && analyse$conductivite > 1500) {
    cat("❌ Conductivité hors norme (", analyse$conductivite, " µS/cm)\n")
    non_conforme <- TRUE
  } else if (!is.na(analyse$conductivite)) cat("✓ Conductivité conforme\n")
  
  if (!is.na(analyse$turbidite) && analyse$turbidite > 5) {
    cat("❌ Turbidité hors norme (", analyse$turbidite, " NTU)\n")
    non_conforme <- TRUE
  } else if (!is.na(analyse$turbidite)) cat("✓ Turbidité conforme\n")
  
  if (!is.na(analyse$nitrates) && analyse$nitrates > 50) {
    cat("❌ Nitrates hors norme (", analyse$nitrates, " mg/L)\n")
    non_conforme <- TRUE
  } else if (!is.na(analyse$nitrates)) cat("✓ Nitrates conformes\n")
  
  if (non_conforme) {
    cat("\n⚠️  EAU NON POTABLE selon normes OMS\n")
  } else {
    cat("\n✅ EAU POTABLE selon normes OMS\n")
  }
  
  return(analyse)
}

# 4. Historique d'un forage
historique_forage <- function(id_forages) {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  hist <- dbGetQuery(conn, "
    SELECT f.nom, a.date_analyse, a.ph, a.conductivite, 
           a.turbidite, a.nitrates, a.commentaires 
    FROM Forages f 
    JOIN Analyses a ON f.id_forages = a.id_forages 
    WHERE f.id_forages = ? 
    ORDER BY a.date_analyse DESC", params = list(id_forages))
  
  print(hist)
  return(hist)
}

# 5. Export des analyses non conformes
export_non_conformes <- function() {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  # Création du dossier s'il n'existe pas
  if (!dir.exists("rapports")) dir.create("rapports")
  
  non_conf <- dbGetQuery(conn, "
    SELECT f.nom, f.localisation, a.date_analyse, a.ph, 
           a.conductivite, a.turbidite, a.nitrates, a.commentaires
    FROM Analyses a 
    JOIN Forages f ON a.id_forages = f.id_forages
    WHERE a.ph < 6.5 OR a.ph > 8.5 
       OR a.conductivite > 1500 
       OR a.turbidite > 5 
       OR a.nitrates > 50")
  
  if (nrow(non_conf) > 0) {
    write.csv(non_conf, "rapports/analyses_non_conformes.csv", row.names = FALSE)
    cat("✅ Export terminé : rapports/analyses_non_conformes.csv\n")
  } else {
    cat("Aucune analyse non conforme trouvée.\n")
  }
}

# 6. Import normes depuis JSON (optionnel)
importer_normes_json <- function(fichier = "data/normes.json") {
  conn <- get_conn()
  on.exit(dbDisconnect(conn))
  
  normes <- fromJSON(fichier)
  dbWriteTable(conn, "Normes_OMS", as.data.frame(normes), append = TRUE, overwrite = FALSE)
  cat("✅ Normes importées depuis JSON\n")
}