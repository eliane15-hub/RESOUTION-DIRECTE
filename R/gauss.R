# Méthode de Gauss avec pivot partiel : résout A x = b
resoudre_gauss <- function(A, b) {
  n <- nrow(A)
  M <- cbind(A, b)   # matrice augmentée [A | b]

  for (k in seq_len(n - 1)) {

    # ETAPE 1 : choisir le pivot
    p <- which.max(abs(M[k:n, k])) + k - 1
    if (p != k) M[c(k, p), ] <- M[c(p, k), ]

    # ETAPE 2 : annuler sous le pivot
    for (i in (k + 1):n) {
      m <- M[i, k] / M[k, k]
      M[i, k:(n + 1)] <- M[i, k:(n + 1)] - m * M[k, k:(n + 1)]
    }
  }

  if (!isTRUE(abs(M[n, n]) > 1e-12)) stop("Matrice singulière : pas de solution unique")

  # ETAPE 3 : remontée
  substitution_arriere(M[, 1:n, drop = FALSE], M[, n + 1])
}
