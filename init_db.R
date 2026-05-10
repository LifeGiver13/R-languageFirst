# init_db.R - Initialisation de la base de données

# Charger les packages nécessaires
if (!require(RSQLite)) install.packages("RSQLite")
library(RSQLite)

conn <- dbConnect(SQLite(), "IGEA2_bdd_forages.db")

# Création des tables 
dbExecute(conn, "
CREATE TABLE IF NOT EXISTS Forages (
    id_forages INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    type TEXT CHECK(type IN ('Forage', 'Puits', 'Source')),
    localisation TEXT,
    profondeur REAL,
    date_creation DATE,
    coordonnees TEXT
)
")

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

dbExecute(conn, "
CREATE TABLE IF NOT EXISTS Normes_OMS (
    parametre TEXT PRIMARY KEY,
    valeur_min REAL,
    valeur_max REAL,
    unite TEXT,
    description TEXT
)
")

# Insertion des normes seulement si la table est vide
if (dbGetQuery(conn, "SELECT COUNT(*) FROM Normes_OMS")[1,1] == 0) {
  normes <- data.frame(
    parametre = c("ph", "conductivite", "turbidite", "nitrates"),
    valeur_min = c(6.5, NA, NA, NA),
    valeur_max = c(8.5, 1500, 5, 50),
    unite = c("", "µS/cm", "NTU", "mg/L"),
    description = c("Plage acceptable", "Conductivité acceptable", 
                    "Turbidité maximale", "Nitrates maximum")
  )
  dbWriteTable(conn, "Normes_OMS", normes, append = TRUE)
  cat("✓ Normes OMS insérées\n")
} else {
  cat("✓ Normes OMS déjà présentes\n")
}

cat("✓ Base de données initialisée avec succès !\n")
dbDisconnect(conn)