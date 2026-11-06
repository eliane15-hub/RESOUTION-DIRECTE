# Installation électrique : une seule ligne alimente trois appareils
#
#   Compteur --fil 1-- (1) clim --fil 2-- (2) four --fil 3-- (3) chauffe-eau
#
# Inconnues : les tensions V1, V2, V3 aux trois appareils.
# Lois utilisées : loi d'Ohm (courant = tension / résistance) et loi des nœuds
# de Kirchhoff (courant qui arrive = courant qui repart).

U_NOMINALE <- 230   # tension pour laquelle la puissance des appareils est indiquée (V)

creer_installation <- function() {
  list(
    tension     = 230,                                          # tension du compteur (V)
    disjoncteur = 16,                                           # courant maximal (A)
    fils        = c(0.1, 0.1, 0.1),                             # résistance de chaque fil (ohm)
    appareils   = c(clim = 1200, four = 1800, chauffe_eau = 1500)  # puissance (W)
  )
}

# Construit le système G V = I à partir de l'installation
# `allumes` indique quels appareils sont allumés (TRUE / FALSE)
construire_systeme <- function(inst, allumes) {
  n <- length(inst$appareils)
  a <- 1 / inst$fils                                      # conductance des fils
  g <- ifelse(allumes, inst$appareils / U_NOMINALE^2, 0)  # conductance des appareils allumés

  G <- matrix(0, n, n)
  for (i in 1:n) {
    G[i, i] <- a[i] + g[i] + (if (i < n) a[i + 1] else 0)
    if (i < n) G[i, i + 1] <- G[i + 1, i] <- -a[i + 1]
  }
  I <- c(a[1] * inst$tension, rep(0, n - 1))
  list(G = G, I = I, g = g)
}

# Résout l'installation et dit si le disjoncteur saute
analyser_installation <- function(inst, allumes, methode = "gauss") {
  sys <- construire_systeme(inst, allumes)
  V <- switch(methode,
    gauss    = resoudre_gauss(sys$G, sys$I),
    lu       = resoudre_lu(sys$G, sys$I),
    cholesky = resoudre_cholesky(sys$G, sys$I)
  )

  courants <- sys$g * V                                    # courant de chaque appareil
  courant_total <- (inst$tension - V[1]) / inst$fils[1]    # courant dans le premier fil

  list(V = V, courants = courants, courant_total = courant_total,
       declenche = courant_total > inst$disjoncteur)
}
