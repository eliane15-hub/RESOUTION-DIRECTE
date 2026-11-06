# Décomposition de Cholesky : A = L Lᵀ (A symétrique définie positive)
decomposer_cholesky <- function(A) {
  n <- nrow(A)
  if (!isTRUE(all.equal(A, t(A)))) stop("La matrice n'est pas symétrique")

  L <- matrix(0, n, n)
  for (j in 1:n) {
    avant <- seq_len(j - 1)
    reste <- A[j, j] - sum(L[j, avant]^2)
    if (reste <= 0) stop("La matrice n'est pas définie positive")
    L[j, j] <- sqrt(reste)

    if (j < n) {
      for (i in (j + 1):n) {
        L[i, j] <- (A[i, j] - sum(L[i, avant] * L[j, avant])) / L[j, j]
      }
    }
  }
  L
}

resoudre_cholesky <- function(A, b) {
  L <- decomposer_cholesky(A)
  y <- substitution_avant(L, b)    # L y = b
  substitution_arriere(t(L), y)    # Lᵀ x = y
}
