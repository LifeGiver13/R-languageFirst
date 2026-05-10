# Creation de la base pour le projet forages
# Nous avons eu du mal au debut avec ca

library(RSQLite)

conn <- dbConnect(SQLite(), "IGEA2_bdd_forages.db")

cat("je cree les tables...\n")

# table principal pour les forages
dbExecute(conn, "
CREATE TABLE IF NOT EXISTS Forages (
    id_forages INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    type TEXT CHECK(type IN ('Forage','Puits','Source')),
    localisation TEXT,
    profondeur REAL,
    date_creation DATE,
    coordonnees TEXT
)
")

# table pour les analyses
dbExecute(conn, "
CREATE TABLE IF NOT EXISTS Analyses (
    id_analyse INTEGER PRIMARY KEY AUTOINCREMENT,
    id_forages INTEGER,
    date_analyse DATE NOT NULL,
    ph REAL,
    conductivite REAL,
    turbidite REAL,
    nitrates REAL,
    commentaires TEXT,
    FOREIGN KEY(id_forages) REFERENCES Forages(id_forages)
)
")

# normes oms
dbExecute(conn, "
CREATE TABLE IF NOT EXISTS Normes_OMS (
    parametre TEXT PRIMARY KEY,
    valeur_min REAL,
    valeur_max REAL,
    unite TEXT,
    description TEXT
)
")

# ajouter normes si la table est vide
nb <- dbGetQuery(conn, "SELECT COUNT(*) FROM Normes_OMS")

if(nb[1,1] == 0){
  normes <- data.frame(
    parametre = c("ph","conductivite","turbidite","nitrates"),
    valeur_min = c(6.5,NA,NA,NA),
    valeur_max = c(8.5,1500,5,50),
    unite = c("","µS/cm","NTU","mg/L"),
    description = c("ph ok","conductivite","turbidite","nitrates")
  )
  dbWriteTable(conn, "Normes_OMS", normes, append=TRUE)
  cat("Normes ajoutees ok\n")
}

cat("Base de donnees initialisee !\n")
dbDisconnect(conn)