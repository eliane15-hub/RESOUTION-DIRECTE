# Décomposition LU avec pivot partiel : P A = L U
decomposer_lu <- function(A) {
  n <- nrow(A)
  U <- A
  L <- diag(n)
  P <- diag(n)

  for (k in seq_len(n - 1)) {
    p <- which.max(abs(U[k:n, k])) + k - 1
    if (p != k) {
      U[c(k, p), ] <- U[c(p, k), ]
      P[c(k, p), ] <- P[c(p, k), ]
      if (k > 1) L[c(k, p), 1:(k - 1)] <- L[c(p, k), 1:(k - 1)]
    }
    for (i in (k + 1):n) {
      L[i, k] <- U[i, k] / U[k, k]   # le multiplicateur est gardé dans L
      U[i, ] <- U[i, ] - L[i, k] * U[k, ]
    }
  }

  if (!isTRUE(abs(U[n, n]) > 1e-12)) stop("Matrice singulière : pas de solution unique")
  list(L = L, U = U, P = P)
}

# Résout A x = b. Si `lu` est fourni, on réutilise la décomposition déjà calculée.
resoudre_lu <- function(A, b, lu = decomposer_lu(A)) {
  y <- substitution_avant(lu$L, lu$P %*% b)
  substitution_arriere(lu$U, y)
}
