## sim.R: pure functions for the MIL-as-coarsening validation.
## No I/O, no side effects. Sourced by run.R.

## ---------------------------------------------------------------------------
## DGP
## ---------------------------------------------------------------------------

#' Simulate a bag dataset under one of four aggregation rules.
#'
#' @param M  N-by-K integer composition matrix (counts of each type per bag).
#' @param eta length-K vector of per-type instance positivity in [0, 1).
#' @param rule one of "or" (standard MIL), "noisy_or" (instance fires w.p. rho),
#'   "label_noise" (bag label flipped FN/FP), or "threshold" (>=r positives).
#' @param rho firing rate for noisy_or.
#' @param eps_minus,eps_plus FN/FP rates for label_noise.
#' @param threshold integer r for threshold rule.
#' @return list(Y = bag labels, num_pos = per-bag count of positive instances).
sim_bags <- function(M, eta,
                     rule = c("or", "noisy_or", "label_noise", "threshold"),
                     rho = 1, eps_minus = 0, eps_plus = 0, threshold = 1) {
  rule <- match.arg(rule)
  N <- nrow(M); K <- ncol(M)
  stopifnot(length(eta) == K, all(eta >= 0 & eta < 1))
  num_pos <- integer(N)
  for (i in seq_len(N)) {
    pos_i <- 0L
    for (k in seq_len(K)) {
      if (M[i, k] > 0L) {
        pos_i <- pos_i + sum(stats::rbinom(M[i, k], 1L, eta[k]))
      }
    }
    num_pos[i] <- pos_i
  }
  Y <- switch(rule,
    "or"        = as.integer(num_pos >= 1L),
    "threshold" = as.integer(num_pos >= threshold),
    "noisy_or"  = {
      ## each positive instance independently fires the bag with prob rho
      sapply(num_pos, function(np) {
        if (np == 0L) 0L
        else as.integer(sum(stats::rbinom(np, 1L, rho)) >= 1L)
      })
    },
    "label_noise" = {
      true_Y <- as.integer(num_pos >= 1L)
      flip_one_to_zero <- stats::runif(N) < eps_minus
      flip_zero_to_one <- stats::runif(N) < eps_plus
      ifelse(true_Y == 1L,
             ifelse(flip_one_to_zero, 0L, 1L),
             ifelse(flip_zero_to_one, 1L, 0L))
    }
  )
  list(Y = as.integer(Y), num_pos = num_pos)
}

## ---------------------------------------------------------------------------
## Estimator: maximum likelihood under the deterministic-OR bag rule
## ---------------------------------------------------------------------------

#' Negative log-likelihood for the bag-OR model.
#'
#' P(Y_i = 0 | m_i) = exp(-m_i^T s),  s_k = -log(1 - eta_k) >= 0.
neg_loglik_or <- function(s, M, Y) {
  S <- as.numeric(M %*% s)
  ## log p_i = log(1 - exp(-S_i)); use log1p(-exp(.)) for stability.
  log_p1 <- ifelse(S > 1e-12, log1p(-exp(-S)), log(pmax(S, 1e-300)) - S / 2)
  log_p0 <- -S
  -sum(Y * log_p1 + (1 - Y) * log_p0)
}

#' Analytic gradient of -loglik w.r.t. s directly.
#'
#' d ell / d s_k = sum_i m_{ik} (Y_i - p_i) / p_i.
grad_or <- function(s, M, Y) {
  S <- as.numeric(M %*% s)
  p <- 1 - exp(-S)
  ratio <- ifelse(p > 0, (Y - p) / p, ifelse(Y == 0L, -1, NA_real_))
  dell_ds <- as.numeric(crossprod(M, ratio))
  -dell_ds
}

#' Maximum-likelihood estimate of (s, eta) under the bag-OR model.
#'
#' Parametrizes s directly with the natural box constraint s_k >= 0
#' (eta_k in [0, 1)). L-BFGS-B is used so the boundary s_k = 0 is
#' reachable without parametrization blow-up.
#'
#' @param M N-by-K composition matrix.
#' @param Y length-N integer bag labels (0/1).
#' @param alpha_init starting value for s (named for backward compatibility);
#'   may be either the log-survival vector itself or its log, autodetected by sign.
#' @return list with eta, s, p (fitted bag-positive probs), loglik, convergence.
fit_or_mle <- function(M, Y, alpha_init = NULL,
                       control = list(maxit = 2000, factr = 1e7),
                       lower = 1e-8, upper = 50) {
  K <- ncol(M)
  if (is.null(alpha_init)) {
    s_init <- rep(0.1, K)
  } else {
    ## treat as s if all nonnegative, else as log(s) (back-compat)
    s_init <- if (all(alpha_init >= 0)) alpha_init else exp(alpha_init)
    s_init <- pmax(s_init, 1e-4)        # well off the boundary for L-BFGS-B
  }
  ## Filter control args that L-BFGS-B doesn't accept (reltol, abstol).
  ok_ctrl <- c("trace", "fnscale", "parscale", "ndeps", "maxit",
               "REPORT", "factr", "pgtol", "lmm", "type")
  control <- control[names(control) %in% ok_ctrl]
  if (is.null(control$factr)) control$factr <- 1e7
  if (is.null(control$maxit)) control$maxit <- 2000
  fit <- stats::optim(s_init, neg_loglik_or, gr = grad_or,
                      M = M, Y = Y, method = "L-BFGS-B",
                      lower = rep(lower, K), upper = rep(upper, K),
                      control = control)
  s_hat <- fit$par
  list(eta = 1 - exp(-s_hat),
       s = s_hat,
       p = as.numeric(1 - exp(-(M %*% s_hat))),
       alpha = log(pmax(s_hat, 1e-300)),
       loglik = -fit$value,
       convergence = fit$convergence,
       message = fit$message)
}

## ---------------------------------------------------------------------------
## Diagnostics
## ---------------------------------------------------------------------------

#' Score-equation residual at fitted s.
#'
#' For the bag-OR model, the per-coordinate score is
#'    s_k -score = sum_i m_{ik} (Y_i - p_i) / p_i
#' so the K-vector M^T D^{-1} (Y - p) should be ~0 at the MLE.
score_residual <- function(M, Y, p_hat) {
  ratio <- ifelse(p_hat > 0, (Y - p_hat) / p_hat,
                  ifelse(Y == 0L, -1, NA_real_))
  as.numeric(crossprod(M, ratio))
}

#' Convenience: max-abs error |eta_hat - eta_true|, ignoring NA.
max_abs_err <- function(eta_hat, eta_true) {
  max(abs(eta_hat - eta_true), na.rm = TRUE)
}
