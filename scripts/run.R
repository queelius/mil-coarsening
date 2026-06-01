## run.R: execute the three validation experiments described in
## sections/validation.tex and save results to results.rds.

## Locate sim.R relative to this script, regardless of working directory.
local({
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  script_dir <- if (length(file_arg) == 1L) {
    dirname(normalizePath(sub("^--file=", "", file_arg)))
  } else {
    ## sourced interactively from the repo root or scripts/
    if (file.exists("sim.R")) "." else "scripts"
  }
  source(file.path(script_dir, "sim.R"))
})

set.seed(20260523)

## ---------------------------------------------------------------------------
## Experiment 1: rank condition
## ---------------------------------------------------------------------------
## (1a) full-rank design: K = 5, bags drawn with diverse compositions.
## (1b) rank-deficient design: types 1 and 2 always co-occur in fixed 2:1 ratio.
##      Multiple optima differ in the (s_1, s_2) split but agree on s_1 + 2 s_2.
## (1c) singleton-bag augmentation: add 5 singletons (one per type) to (1b).
##      Verify recovery is restored.

run_exp1 <- function() {
  K <- 5L
  eta_true <- c(0.05, 0.10, 0.20, 0.30, 0.50)

  ## (1a) full-rank: random compositions, bag size ~ Poisson(8)
  N <- 600L
  sizes <- pmax(2L, stats::rpois(N, 8))
  M_a <- t(sapply(sizes, function(sz) {
    counts <- as.integer(tabulate(sample.int(K, sz, replace = TRUE), nbins = K))
    counts
  }))
  dat_a <- sim_bags(M_a, eta_true, rule = "or")
  fit_a <- fit_or_mle(M_a, dat_a$Y)
  err_a <- max_abs_err(fit_a$eta, eta_true)

  ## (1b) rank-deficient: types 1 and 2 always co-occur with m1 = 2 m2,
  ## so column 1 = 2 * column 2 in M and the identified linear functional
  ## of (s_1, s_2) is 2 s_1 + s_2. Types 3-5 vary independently.
  M_b <- t(sapply(seq_len(N), function(i) {
    pair_units <- stats::rpois(1, 2) + 1L     # m1 = 2*u, m2 = 1*u
    c(2L * pair_units, 1L * pair_units,
      as.integer(tabulate(sample.int(3L, max(2L, stats::rpois(1, 4)),
                                     replace = TRUE), nbins = 3L)))
  }))
  rank_M_b <- qr(M_b)$rank
  dat_b <- sim_bags(M_b, eta_true, rule = "or")
  ## Starts that explicitly perturb the (s_1, s_2) split, holding 2 s_1 + s_2
  ## roughly fixed so BFGS cannot use start-only signal to break the tie.
  starts <- list(
    c(log(0.02), log(0.16), log(0.20), log(0.30), log(0.50)),  # low s1, high s2
    c(log(0.05), log(0.10), log(0.20), log(0.30), log(0.50)),  # truth
    c(log(0.08), log(0.04), log(0.20), log(0.30), log(0.50))   # high s1, low s2
  )
  fits_b <- lapply(starts, function(a0)
    fit_or_mle(M_b, dat_b$Y, alpha_init = a0,
               control = list(maxit = 5000, reltol = 1e-12)))
  s_b <- sapply(fits_b, `[[`, "s")
  ## Identified linear functional: 2 s_1 + s_2.
  s_combo_b   <- 2 * s_b[1, ] + s_b[2, ]
  s_combo_true <- 2 * (-log(1 - eta_true[1])) + (-log(1 - eta_true[2]))
  spread_s1    <- max(s_b[1, ]) - min(s_b[1, ])
  spread_combo <- max(s_combo_b) - min(s_combo_b)
  spread_s35   <- max(apply(s_b[3:5, , drop = FALSE], 1,
                            function(r) max(r) - min(r)))

  ## (1c) augment with several singleton bags per type to break the
  ## rank deficiency. Use 20 per type so per-type estimates are reasonably
  ## tight; each singleton's label is Bernoulli(eta_k).
  per_type_singletons <- 20L
  M_c <- rbind(M_b,
               do.call(rbind,
                       lapply(seq_len(K),
                              function(k) {
                                row <- integer(K); row[k] <- 1L
                                matrix(row, per_type_singletons, K, byrow = TRUE)
                              })))
  rank_M_c <- qr(M_c)$rank
  singleton_Y <- unlist(lapply(seq_len(K), function(k)
    stats::rbinom(per_type_singletons, 1L, eta_true[k])))
  Y_c <- c(dat_b$Y, as.integer(singleton_Y))
  fits_c <- lapply(starts, function(a0)
    fit_or_mle(M_c, Y_c, alpha_init = a0,
               control = list(maxit = 5000, reltol = 1e-12)))
  s_c <- sapply(fits_c, `[[`, "s")
  err_c <- max(apply(s_c, 2, function(s) max_abs_err(1 - exp(-s), eta_true)))
  spread_s_c <- max(apply(s_c, 1, function(r) max(r) - min(r)))

  list(
    eta_true = eta_true,
    full_rank = list(N = N, rank = qr(M_a)$rank, max_abs_err = err_a,
                     eta_hat = fit_a$eta),
    rank_deficient = list(
      N = N, rank_M = rank_M_b,
      eta_hat_starts = 1 - exp(-s_b),
      s_true = -log(1 - eta_true),
      s_hat_starts = s_b,            # K rows x 3 starts
      spread_s1 = spread_s1,
      spread_s35_max = spread_s35,
      spread_identified_combo_2s1_plus_s2 = spread_combo,
      identified_combo_true = s_combo_true,
      identified_combo_hat = s_combo_b
    ),
    singleton_augmented = list(
      N = N + K * 20L, rank_M = rank_M_c,
      per_type_singletons = 20L,
      s_hat_starts = s_c,            # K rows x 3 starts
      max_abs_err = err_c,
      spread_s_across_starts = spread_s_c
    )
  )
}

## ---------------------------------------------------------------------------
## Experiment 2: bag-prevalence consistency (corrected form)
## ---------------------------------------------------------------------------
## The bag-OR MLE satisfies the IRLS-weighted moment-matching equation
##    M^T D^{-1} (Y - p_hat) = 0,  D = diag(p_hat).
## Verify the infinity-norm of this K-vector is at optimizer tolerance.

run_exp2 <- function(reps = 30L, boundary_tol = 1e-6) {
  K <- 4L
  eta_true <- c(0.05, 0.15, 0.30, 0.60)
  N <- 400L
  resids_inf <- numeric(reps)
  unwt_inf   <- numeric(reps)
  at_boundary <- logical(reps)
  for (r in seq_len(reps)) {
    sizes <- pmax(2L, stats::rpois(N, 6))
    M <- t(sapply(sizes, function(sz) {
      as.integer(tabulate(sample.int(K, sz, replace = TRUE), nbins = K))
    }))
    dat <- sim_bags(M, eta_true, rule = "or")
    starts <- list(rep(log(0.05), K), log(eta_true),
                   rep(log(0.3), K), rep(log(0.01), K))
    fits <- lapply(starts, function(a0)
      fit_or_mle(M, dat$Y, alpha_init = a0,
                 control = list(maxit = 5000, factr = 10)))
    best <- which.max(sapply(fits, `[[`, "loglik"))
    fit <- fits[[best]]
    at_boundary[r] <- any(fit$s <= boundary_tol)
    res_weighted <- score_residual(M, dat$Y, fit$p)
    res_unweighted <- as.numeric(crossprod(M, dat$Y - fit$p))
    resids_inf[r] <- max(abs(res_weighted))
    unwt_inf[r]   <- max(abs(res_unweighted))
  }
  interior <- !at_boundary
  list(reps = reps, K = K, N = N, eta_true = eta_true,
       weighted_residual_inf = resids_inf,
       unweighted_residual_inf = unwt_inf,
       at_boundary = at_boundary,
       n_interior = sum(interior),
       n_boundary = sum(at_boundary),
       interior_weighted_median = if (any(interior))
         stats::median(resids_inf[interior]) else NA_real_,
       interior_weighted_max = if (any(interior))
         max(resids_inf[interior]) else NA_real_,
       interior_unweighted_median = if (any(interior))
         stats::median(unwt_inf[interior]) else NA_real_,
       interior_unweighted_max = if (any(interior))
         max(unwt_inf[interior]) else NA_real_,
       boundary_weighted_residuals = resids_inf[at_boundary])
}

## ---------------------------------------------------------------------------
## Experiment 3: aggregation-rule bias (noisy-OR firing-rate confound)
## ---------------------------------------------------------------------------
## Generate under noisy-OR with rho in {1.0, 0.9, 0.7, 0.5} and under symmetric
## label noise with eps in {0, 0.05, 0.10, 0.20}. Fit deterministic-OR model.
## For noisy-OR, the firing-rate confound predicts eta_hat ~ rho * eta_true.
## For label noise, predict first-order linear bias in eps.

run_exp3 <- function(reps = 25L) {
  K <- 4L
  eta_true <- c(0.05, 0.15, 0.30, 0.60)
  N <- 800L

  build_M <- function() {
    sizes <- pmax(2L, stats::rpois(N, 6))
    t(sapply(sizes, function(sz) {
      as.integer(tabulate(sample.int(K, sz, replace = TRUE), nbins = K))
    }))
  }

  noisy_grid <- c(1.0, 0.9, 0.7, 0.5)
  noisy_res <- lapply(noisy_grid, function(rho) {
    eh <- matrix(NA_real_, reps, K)
    for (r in seq_len(reps)) {
      M <- build_M()
      dat <- sim_bags(M, eta_true, rule = "noisy_or", rho = rho)
      fit <- fit_or_mle(M, dat$Y)
      eh[r, ] <- fit$eta
    }
    list(rho = rho,
         eta_hat_median = apply(eh, 2, stats::median),
         eta_hat_mean   = colMeans(eh),
         predicted_rho_eta = rho * eta_true,
         ratio_median = apply(eh, 2, stats::median) / eta_true)
  })

  noise_grid <- c(0, 0.05, 0.10, 0.20)
  noise_res <- lapply(noise_grid, function(eps) {
    eh <- matrix(NA_real_, reps, K)
    for (r in seq_len(reps)) {
      M <- build_M()
      dat <- sim_bags(M, eta_true, rule = "label_noise",
                      eps_minus = eps, eps_plus = eps)
      fit <- fit_or_mle(M, dat$Y)
      eh[r, ] <- fit$eta
    }
    list(eps = eps,
         eta_hat_median = apply(eh, 2, stats::median),
         eta_hat_mean   = colMeans(eh),
         bias_median = apply(eh, 2, stats::median) - eta_true)
  })

  list(K = K, N = N, reps = reps, eta_true = eta_true,
       noisy_or = noisy_res, label_noise = noise_res)
}

## ---------------------------------------------------------------------------
## Multi-seed aggregation
## ---------------------------------------------------------------------------

#' Run all three experiments under one seed; return a flat list of scalars
#' and per-type vectors suitable for cross-seed aggregation.
one_seed_run <- function(seed) {
  set.seed(seed)
  e1 <- run_exp1()
  e2 <- run_exp2()
  e3 <- run_exp3()
  list(
    seed = seed,
    e1_rd_s_starts = e1$rank_deficient$s_hat_starts,    # K x 3
    e1_sa_s_starts = e1$singleton_augmented$s_hat_starts, # K x 3
    e1_eta_true = e1$eta_true,
    e1_full_err = e1$full_rank$max_abs_err,
    e1_rank_M_def = e1$rank_deficient$rank_M,
    e1_spread_s1 = e1$rank_deficient$spread_s1,
    e1_spread_combo = e1$rank_deficient$spread_identified_combo_2s1_plus_s2,
    e1_combo_true = e1$rank_deficient$identified_combo_true,
    e1_combo_hat_median = stats::median(e1$rank_deficient$identified_combo_hat),
    e1_sing_err = e1$singleton_augmented$max_abs_err,
    e1_sing_spread = e1$singleton_augmented$spread_s_across_starts,
    e2_n_boundary = e2$n_boundary,
    e2_int_wt_med = e2$interior_weighted_median,
    e2_int_wt_max = e2$interior_weighted_max,
    e2_int_unwt_med = e2$interior_unweighted_median,
    e2_int_unwt_max = e2$interior_unweighted_max,
    e3_noisy_ratios = sapply(e3$noisy_or, function(r) r$ratio_median),
    e3_noisy_rhos = sapply(e3$noisy_or, `[[`, "rho"),
    e3_noise_bias = sapply(e3$label_noise, function(r) r$bias_median),
    e3_noise_eps = sapply(e3$label_noise, `[[`, "eps")
  )
}

#' Helper: median + IQR pair as a length-3 vector (lo, med, hi).
mq <- function(x) stats::quantile(x, c(0.25, 0.5, 0.75), na.rm = TRUE,
                                   names = FALSE)

## ---------------------------------------------------------------------------
## Driver
## ---------------------------------------------------------------------------

#' Run the full experiment battery under multiple seeds and aggregate.
#'
#' Reports median and IQR for every headline scalar so reviewers can see
#' which numbers are stable point estimates and which are seed-dependent.
main <- function(out_path = "results.rds",
                 seeds = 20260523L + seq_len(20L) - 1L) {
  cat("Running", length(seeds), "seeds:", paste(range(seeds), collapse = " to "),
      "\n")
  per_seed <- vector("list", length(seeds))
  for (i in seq_along(seeds)) {
    cat("  seed", seeds[i], "(", i, "of", length(seeds), ")\n")
    per_seed[[i]] <- one_seed_run(seeds[i])
  }

  ## Run the single-seed version one more time for back-compat output.
  set.seed(seeds[1])
  cat("Single-seed pass for back-compat output ...\n")
  e1 <- run_exp1(); e2 <- run_exp2(); e3 <- run_exp3()

  ## Cross-seed aggregates of scalar quantities.
  pull <- function(name) sapply(per_seed, `[[`, name)
  pull_mat <- function(name) sapply(per_seed, `[[`, name)  # cells x seeds

  agg <- list(
    n_seeds = length(seeds),
    e1_full_err           = mq(pull("e1_full_err")),
    e1_rank_M_def         = stats::median(pull("e1_rank_M_def")),
    e1_spread_s1          = mq(pull("e1_spread_s1")),
    e1_spread_combo       = mq(pull("e1_spread_combo")),
    e1_combo_true         = stats::median(pull("e1_combo_true")),
    e1_combo_hat_median   = mq(pull("e1_combo_hat_median")),
    e1_sing_err           = mq(pull("e1_sing_err")),
    e1_sing_spread        = mq(pull("e1_sing_spread")),
    e2_n_boundary         = mq(pull("e2_n_boundary")),
    e2_int_wt_med         = mq(pull("e2_int_wt_med")),
    e2_int_wt_max         = mq(pull("e2_int_wt_max")),
    e2_int_unwt_med       = mq(pull("e2_int_unwt_med")),
    e2_int_unwt_max       = mq(pull("e2_int_unwt_max")),
    e3_noisy_rhos         = per_seed[[1]]$e3_noisy_rhos,
    e3_noise_eps          = per_seed[[1]]$e3_noise_eps,
    ## per (rho, type): median + IQR across seeds
    e3_noisy_ratio_q = apply(simplify2array(lapply(per_seed,
                                                   `[[`, "e3_noisy_ratios")),
                             c(1, 2), function(x) mq(x)),
    e3_noise_bias_q = apply(simplify2array(lapply(per_seed,
                                                  `[[`, "e3_noise_bias")),
                            c(1, 2), function(x) mq(x))
  )

  results <- list(seeds = seeds, per_seed = per_seed,
                  agg = agg,
                  single_seed_exp1 = e1,
                  single_seed_exp2 = e2,
                  single_seed_exp3 = e3,
                  sessionInfo = utils::sessionInfo())
  saveRDS(results, out_path)

  ## stdout summary: cross-seed medians with IQR
  fmt_q <- function(q) sprintf("%.3g [%.3g, %.3g]",
                                q[2], q[1], q[3])
  cat("\n=== Cross-seed summary (", agg$n_seeds, "seeds; median [IQR]) ===\n")
  cat("Exp 1 full-rank  max|eta_hat - eta|     :", fmt_q(agg$e1_full_err), "\n")
  cat("Exp 1 rank-defic. spread(s1)            :", fmt_q(agg$e1_spread_s1), "\n")
  cat("Exp 1 rank-defic. spread(2 s1 + s2)     :", fmt_q(agg$e1_spread_combo), "\n")
  cat("Exp 1 rank-defic. identified combo true =",
      signif(agg$e1_combo_true, 3),
      "  fitted median across starts:", fmt_q(agg$e1_combo_hat_median), "\n")
  cat("Exp 1 singleton+ max|eta_hat - eta|     :", fmt_q(agg$e1_sing_err), "\n")
  cat("Exp 1 singleton+ spread across starts   :", fmt_q(agg$e1_sing_spread), "\n")
  cat("Exp 2 boundary reps (of 30)             :", fmt_q(agg$e2_n_boundary), "\n")
  cat("Exp 2 interior weighted residual median :", fmt_q(agg$e2_int_wt_med), "\n")
  cat("Exp 2 interior weighted residual max    :", fmt_q(agg$e2_int_wt_max), "\n")
  cat("Exp 2 interior unweighted residual med  :", fmt_q(agg$e2_int_unwt_med), "\n")
  cat("Exp 2 interior unweighted residual max  :", fmt_q(agg$e2_int_unwt_max), "\n")
  cat("Exp 3 noisy-OR median ratio (median across seeds, types are columns):\n")
  for (j in seq_along(agg$e3_noisy_rhos)) {
    cat(sprintf("   rho = %.2f  type-medians = %s\n",
                agg$e3_noisy_rhos[j],
                paste(sprintf("%.3f", agg$e3_noisy_ratio_q[2, , j]),
                      collapse = " ")))
  }
  cat("Exp 3 label-noise median bias (cross-seed median):\n")
  for (j in seq_along(agg$e3_noise_eps)) {
    cat(sprintf("   eps = %.2f  type-bias-medians = %s\n",
                agg$e3_noise_eps[j],
                paste(sprintf("%+.3f", agg$e3_noise_bias_q[2, , j]),
                      collapse = " ")))
  }
  invisible(results)
}

if (sys.nframe() == 0L) main()
