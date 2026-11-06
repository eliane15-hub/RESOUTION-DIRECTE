# Résolution d'un système triangulaire (utilisée par Gauss, LU et Cholesky)

# U x = y avec U triangulaire supérieure : on part de la dernière ligne et on remonte
substitution_arriere <- function(U, y) {
  n <- length(y)
  x <- numeric(n)
  for (i in n:1) {
    deja_connu <- if (i < n) sum(U[i, (i + 1):n] * x[(i + 1):n]) else 0
    x[i] <- (y[i] - deja_connu) / U[i, i]
  }
  x
}

# L y = b avec L triangulaire inférieure : on part de la première ligne et on descend
substitution_avant <- function(L, b) {
  n <- length(b)
  y <- numeric(n)
  for (i in 1:n) {
    deja_connu <- if (i > 1) sum(L[i, 1:(i - 1)] * y[1:(i - 1)]) else 0
    y[i] <- (b[i] - deja_connu) / L[i, i]
  }
  y
}
