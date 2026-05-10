# Projet IGEA2 — Gestion des Forages

Projet realise dans le cadre du cours IGEA2.

Le but du projet est de gerer les forages et les analyses de qualite d'eau avec R et SQLite.

Nous avons essaye de faire un petit systeme simple en console qui permet :
- d'ajouter des forages,
- enregistrer des analyses,
- verifier la conformite OMS,
- exporter des analyses non conformes,
- afficher quelques graphiques.

---

## Technologies utilisees

- R
- SQLite
- ggplot2

---

## Organisation des fichiers

- `main.R` : menu principal
- `fonctions.R` : fonctions du projet
- `init_db.R` : creation de la base de donnees

---

## Installation

Installer les packages suivants :

```r
install.packages(c(
  "RSQLite",
  "dplyr",
  "ggplot2"
))
```

---

## Lancement

D'abord executer :

```r
source("init_db.R")
```

Puis :

```r
source("main.R")
```

---

## Difficultes rencontrees

Au debut nous avions quelques problemes avec les requetes SQL et les jointures entre les tables.

Le graphique a aussi pose probleme parce que certaines valeurs etaient NULL.
