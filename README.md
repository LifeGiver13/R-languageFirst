# Gestion des Forages et Qualité de l'Eau

**Projet Informatique IGEA 2**  
**Période** : Lundi 30 Mars 2026 - Jeudi 14 Mai 2026

## Membres du groupe
- Nom Prénom 1
- Nom Prénom 2  
- Nom Prénom 3

---

## Description du Projet

Ce projet permet de gérer les forages et puits d’eau dans une zone donnée. Il suit la qualité physico-chimique de l’eau (pH, conductivité, turbidité, nitrates) et vérifie automatiquement si l’eau est potable selon les normes de l’OMS.

Le système utilise une base de données **SQLite**, des fichiers externes (JSON), des graphiques avec **ggplot2**, et une interface en console.

---

## Comment exécuter le projet

1. Ouvrir le dossier du projet dans **VS Code** (avec l’extension R installée) ou **RStudio**.
2. Exécuter d’abord le fichier `init_db.R` **une seule fois** (pour créer la base de données et les tables).
3. Exécuter le fichier `main.R` pour lancer le programme.

Le menu interactif apparaîtra dans la console.

---

## Packages nécessaires

```r
install.packages(c("RSQLite", "dplyr", "ggplot2", "jsonlite"))