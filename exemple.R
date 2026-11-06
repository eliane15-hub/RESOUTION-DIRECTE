# Démonstration : la clim, le four et le chauffe-eau sur la même ligne
# À lancer depuis le dossier du projet :  Rscript exemple.R

for (f in list.files("R", full.names = TRUE)) source(f, encoding = "UTF-8")

inst <- creer_installation()

# 1. Que se passe-t-il quand on allume les appareils ?
situations <- list(
  "Clim seule"                = c(TRUE, FALSE, FALSE),
  "Clim + four"               = c(TRUE, TRUE, FALSE),
  "Clim + four + chauffe-eau" = c(TRUE, TRUE, TRUE)
)

courants_totaux <- c()
for (nom in names(situations)) {
  r <- analyser_installation(inst, situations[[nom]])
  courants_totaux[nom] <- r$courant_total
  cat("\n", nom, "\n", sep = "")
  cat("  Tensions aux appareils (V) :", round(r$V, 1), "\n")
  cat("  Courant total :", round(r$courant_total, 1), "A (disjoncteur :", inst$disjoncteur, "A)\n")
  cat(if (r$declenche) "  -> LE DISJONCTEUR SAUTE\n" else "  -> Tout fonctionne\n")
}

# 2. Le système G V = I quand les trois appareils sont allumés
sys <- construire_systeme(inst, c(TRUE, TRUE, TRUE))
cat("\nSystème G V = I (3 appareils allumés)\n\nG =\n")
print(round(sys$G, 2))
cat("\nI =", sys$I, "\n")

# 3. Les trois méthodes donnent la même réponse que solve() de R
V <- data.frame(
  Gauss    = resoudre_gauss(sys$G, sys$I),
  LU       = resoudre_lu(sys$G, sys$I),
  Cholesky = resoudre_cholesky(sys$G, sys$I),
  solve    = solve(sys$G, sys$I),
  row.names = c("V1 (clim)", "V2 (four)", "V3 (chauffe-eau)")
)
cat("\nTensions (V) selon la méthode :\n")
print(round(V, 4))

# 4. Vérification avec la loi des nœuds
r <- analyser_installation(inst, c(TRUE, TRUE, TRUE))
cat("\nCourant dans le premier fil :", round(r$courant_total, 2), "A\n")
cat("Somme des courants des appareils :", round(sum(r$courants), 2), "A\n")

# 5. LU : plusieurs tensions du réseau avec une seule décomposition
lu <- decomposer_lu(sys$G)
cat("\nTension du réseau variable (LU réutilisée) :\n")
for (tension in c(200, 215, 230)) {
  b <- c(tension / inst$fils[1], 0, 0)
  tensions <- resoudre_lu(sys$G, b, lu = lu)
  cat(" ", tension, "V au compteur ->", round(tensions, 1), "V aux appareils\n")
}

# 6. Graphique pour la présentation
dir.create("resultats", showWarnings = FALSE)
png("resultats/courant_disjoncteur.png", width = 900, height = 650, res = 120, type = "cairo")
couleurs <- ifelse(courants_totaux > inst$disjoncteur, "firebrick", "steelblue")
barplot(courants_totaux, col = couleurs, ylim = c(0, 25), ylab = "Courant total (A)",
        names.arg = sub(" \\+ ", "\n+ ", names(courants_totaux)),
        main = "Courant dans la ligne selon les appareils allumés")
abline(h = inst$disjoncteur, lty = 2, lwd = 2)
text(0.2, inst$disjoncteur + 1, paste("Disjoncteur :", inst$disjoncteur, "A"), pos = 4)
dev.off()
cat("\nGraphique enregistré : resultats/courant_disjoncteur.png\n")
