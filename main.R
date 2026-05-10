# Fichier principal du projet

source("fonctions.R")
source("init_db.R")

cat("\n====================================\n")
cat("     GESTION FORAGES IGEA2\n")
cat("====================================\n\n")

menu_principal <- function(){

  repeat{

    cat("\n Sélectionnez votre option entre 1 a 8 : \n\n")
    cat("1 - Ajouter forage\n")
    cat("2 - Ajouter analyse\n")
    cat("3 - Verifier qualite\n")
    cat("4 - Historique\n")
    cat("5 - Liste forages\n")
    cat("6 - Exporter mauvais\n")
    cat("7 - Graphiques\n")
    cat("8 - Quitter\n\n")

    choix <- readline("Ton choix : ")

    if(choix == "1"){
      cat("\nAjout forage\n")
      nom <- readline("Nom : ")
      type <- readline("Type : ")
      loc <- readline("Localisation : ")
      prof <- as.numeric(readline("Profondeur : "))
      dat <- readline("Date creation : ")
      coor <- readline("Coordonnees : ")
      
      ajouter_forage(nom, type, loc, prof, dat, coor)

    } else if(choix == "2"){
      cat("\nNouvelle analyse\n")
      id <- as.integer(readline("ID forage : "))
      ph <- readline("pH : ")
      cond <- readline("Conductivite : ")
      turb <- readline("Turbidite : ")
      nit <- readline("Nitrates : ")
      comm <- readline("Commentaire : ")
      
      save_analyse(id, ph, cond, turb, nit, comm)

    } else if(choix == "3"){
      id <- as.integer(readline("ID forage : "))
      check_conformite(id)

    } else if(choix == "4"){
      id <- as.integer(readline("ID : "))
      voir_historique(id)

    } else if(choix == "5"){
      conn <- get_conn()
      print(dbGetQuery(conn, "SELECT * FROM Forages"))
      dbDisconnect(conn)

    } else if(choix == "6"){
      export_nonconformes()

    } else if(choix == "7"){
      faire_graphiques()

    } else if(choix == "8"){
      cat("Bye !\n")
      break
    } else {
      cat("Mauvais choix...\n")
    }
  }
}

menu_principal()