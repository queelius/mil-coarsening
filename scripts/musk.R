## musk.R: real-data MIL application on MUSK1 + MUSK2.
##
## Loads the UCI MUSK clean1.data / clean2.data files, clusters
## conformations into K instance types by k-means on the standardized
## 166-dimensional feature vectors, fits the bag-OR MLE from sim.R,
## reports rank-condition diagnostics and per-type positivity estimates,
## and measures bag-level predictive AUC under leave-one-bag-out
## cross-validation.
##
## Run from the repo root:
##   Rscript scripts/musk.R
## Writes results to data/musk_results.rds.

local({
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  script_dir <- if (length(file_arg) == 1L) {
    dirname(normalizePath(sub("^--file=", "", file_arg)))
  } else {
    if (file.exists("sim.R")) "." else "scripts"
  }
  source(file.path(script_dir, "sim.R"))
})

set.seed(20260527)

## ---------------------------------------------------------------------------
## Loader
## ---------------------------------------------------------------------------

load_musk <- function(path) {
  ## CSV: molecule_name, conformation_name, f1..f166, class
  d <- utils::read.csv(path, header = FALSE, stringsAsFactors = FALSE)
  stopifnot(ncol(d) == 169L)
  list(
    molecule = d[[1]],
    conformation = d[[2]],
    features = as.matrix(d[, 3:168]),
    class = as.integer(d[[169]])
  )
}

#' Per-bag (molecule) label: a molecule is positive iff any of its
#' conformations has class 1. (In MUSK every conformation of the same
#' molecule carries the same label, so this is equivalent to taking
#' the unique label per molecule.)
bag_labels <- function(d) {
  by_mol <- split(d$class, d$molecule)
  vapply(by_mol, function(x) as.integer(any(x == 1L)), integer(1L))
}

## ---------------------------------------------------------------------------
## Clustering and composition matrix
## ---------------------------------------------------------------------------

#' Standardize features (z-score per column), then cluster with k-means.
#' Returns the cluster assignment vector and the standardization parameters
#' (so test instances can be assigned to the same clusters).
cluster_instances <- function(features, K, nstart = 25, iter.max = 50) {
  mu <- colMeans(features)
  sigma <- apply(features, 2, stats::sd)
  sigma[sigma == 0] <- 1
  Z <- sweep(sweep(features, 2, mu, "-"), 2, sigma, "/")
  km <- stats::kmeans(Z, centers = K, nstart = nstart, iter.max = iter.max)
  list(cluster = km$cluster, mu = mu, sigma = sigma, centers = km$centers)
}

#' Assign new instances to the nearest cluster centroid from a prior fit.
assign_to_clusters <- function(features, fit) {
  Z <- sweep(sweep(features, 2, fit$mu, "-"), 2, fit$sigma, "/")
  centers <- fit$centers
  ## squared distance to each centroid
  d2 <- sapply(seq_len(nrow(centers)), function(k)
    rowSums((Z - matrix(centers[k, ], nrow(Z), ncol(Z), byrow = TRUE))^2))
  max.col(-d2, ties.method = "first")
}

#' Build the bag-by-cluster composition matrix M (rows = bags, cols = K).
build_M <- function(molecule_id, cluster_id, K) {
  mol_factor <- factor(molecule_id)
  M <- matrix(0L, nlevels(mol_factor), K,
              dimnames = list(levels(mol_factor), NULL))
  for (i in seq_along(cluster_id)) {
    b <- as.integer(mol_factor[i]); k <- cluster_id[i]
    M[b, k] <- M[b, k] + 1L
  }
  M
}

## ---------------------------------------------------------------------------
## In-sample diagnostic (one K, full data)
## ---------------------------------------------------------------------------

in_sample <- function(dataset, K) {
  d <- load_musk(dataset$path)
  Y <- bag_labels(d)
  mol_levels <- names(Y)
  cl <- cluster_instances(d$features, K)
  M <- build_M(d$molecule, cl$cluster, K)
  ## reorder Y to match M's row order
  Y <- Y[rownames(M)]
  fit <- fit_or_mle(M, Y, control = list(maxit = 5000, factr = 10))
  rank_M <- qr(M)$rank
  sv <- svd(M)$d
  cond <- if (min(sv) > 0) max(sv) / min(sv) else Inf
  score_inf <- max(abs(score_residual(M, Y, fit$p)))
  pred_pos_rate <- mean(fit$p)
  obs_pos_rate  <- mean(Y)
  ## naive bag-level AUC on in-sample fit
  auc_in <- compute_auc(Y, fit$p)
  list(
    K = K,
    N_bags = nrow(M), N_instances = nrow(d$features),
    rank_M = rank_M, condition_number = cond,
    eta_hat = fit$eta, s_hat = fit$s,
    score_inf = score_inf,
    pred_pos_rate = pred_pos_rate, obs_pos_rate = obs_pos_rate,
    auc_in_sample = auc_in,
    n_boundary = sum(fit$s <= 1e-6),
    convergence = fit$convergence,
    cluster_sizes = as.integer(table(factor(cl$cluster, levels = seq_len(K))))
  )
}

#' Compute AUC the simple way (Mann-Whitney U).
compute_auc <- function(Y, p) {
  pos <- p[Y == 1L]; neg <- p[Y == 0L]
  if (length(pos) == 0L || length(neg) == 0L) return(NA_real_)
  pairs <- outer(pos, neg, ">")
  ties  <- outer(pos, neg, "==")
  (sum(pairs) + 0.5 * sum(ties)) / (length(pos) * length(neg))
}

## ---------------------------------------------------------------------------
## Continuous-feature analysis (Theorem 4)
## ---------------------------------------------------------------------------

#' Min-max scale features to [0, 1] per column. Returns the scaled matrix
#' along with the scaling parameters so test instances get the same map.
fit_minmax <- function(features) {
  mn <- apply(features, 2, min)
  mx <- apply(features, 2, max)
  span <- mx - mn
  span[span == 0] <- 1
  list(mn = mn, span = span,
       Z = sweep(sweep(features, 2, mn, "-"), 2, span, "/"))
}

apply_minmax <- function(features, scaling) {
  X <- sweep(sweep(features, 2, scaling$mn, "-"), 2, scaling$span, "/")
  pmin(pmax(X, 0), 1)            # clip to [0, 1] for unseen extremes
}

#' Build bag-summed feature matrix Phi (N_bags x d).
build_Phi <- function(molecule_id, scaled_features) {
  mol_factor <- factor(molecule_id)
  d <- ncol(scaled_features)
  Phi <- matrix(0, nlevels(mol_factor), d,
                dimnames = list(levels(mol_factor), NULL))
  for (b in seq_len(nlevels(mol_factor))) {
    in_bag <- as.integer(mol_factor) == b
    if (any(in_bag))
      Phi[b, ] <- colSums(scaled_features[in_bag, , drop = FALSE])
  }
  Phi
}

in_sample_continuous <- function(dataset) {
  d <- load_musk(dataset$path)
  Y <- bag_labels(d)
  sc <- fit_minmax(d$features)
  Phi <- build_Phi(d$molecule, sc$Z)
  Y <- Y[rownames(Phi)]
  fit <- fit_or_mle(Phi, Y,
                    control = list(maxit = 5000, factr = 10))
  rank_Phi <- qr(Phi)$rank
  N_bags <- nrow(Phi); d_feat <- ncol(Phi)
  list(
    N_bags = N_bags, d_feat = d_feat,
    rank_Phi = rank_Phi,
    underidentified_dim = max(0L, d_feat - rank_Phi),
    pred_pos_rate = mean(fit$p),
    obs_pos_rate = mean(Y),
    auc_in_sample = compute_auc(Y, fit$p),
    n_beta_boundary = sum(fit$beta <- fit$s <= 1e-6),
    convergence = fit$convergence
  )
}

loo_cv_continuous <- function(dataset) {
  d <- load_musk(dataset$path)
  Y_all <- bag_labels(d)
  mol_levels <- names(Y_all)
  N_bags <- length(mol_levels)

  p_pred <- numeric(N_bags); names(p_pred) <- mol_levels
  for (i in seq_len(N_bags)) {
    held <- mol_levels[i]
    is_train_inst <- d$molecule != held
    train_feat <- d$features[is_train_inst, , drop = FALSE]
    train_mol  <- d$molecule[is_train_inst]
    sc <- fit_minmax(train_feat)
    Phi_train <- build_Phi(train_mol, sc$Z)
    Y_train <- Y_all[rownames(Phi_train)]
    fit <- fit_or_mle(Phi_train, Y_train,
                      control = list(maxit = 3000, factr = 1e3))

    held_feat <- d$features[!is_train_inst, , drop = FALSE]
    held_scaled <- apply_minmax(held_feat, sc)
    Phi_held <- colSums(held_scaled)
    p_pred[i] <- 1 - exp(-sum(Phi_held * fit$s))
  }
  list(
    N_bags = N_bags, Y = Y_all, p_pred = p_pred,
    auc = compute_auc(Y_all, p_pred),
    accuracy_at_thresh_0.5 = mean(as.integer(p_pred >= 0.5) == Y_all)
  )
}

## ---------------------------------------------------------------------------
## PCA-to-k continuous-feature analysis (framework prescription)
##
## When d > N, the continuous-feature parameter beta is under-identified by
## d - N dimensions, hurting LOO-CV predictive stability. The framework's
## prescription is to rank-reduce the feature map so col(Phi) is full.
## Here: project min-max-scaled features onto top-k principal components,
## then shift each PC to be nonnegative so the beta >= 0 constraint stays
## well-posed.
## ---------------------------------------------------------------------------

fit_pca <- function(scaled_features, k) {
  pc <- stats::prcomp(scaled_features, center = TRUE, scale. = FALSE)
  W <- pc$rotation[, 1:k, drop = FALSE]
  centered <- scale(scaled_features, center = pc$center, scale = FALSE)
  Z <- centered %*% W
  mn_Z <- apply(Z, 2, min)
  list(W = W, mu_x = pc$center, mn_Z = mn_Z,
       Z = sweep(Z, 2, mn_Z, "-"), k = k)
}

apply_pca <- function(scaled_features, pca_fit) {
  centered <- scale(scaled_features,
                    center = pca_fit$mu_x, scale = FALSE)
  Z <- centered %*% pca_fit$W
  Z <- sweep(Z, 2, pca_fit$mn_Z, "-")
  pmax(Z, 0)
}

#' Bag-summed PCA features, returns N_bags x k matrix.
build_Phi_pca <- function(molecule_id, pca_features) {
  mol_factor <- factor(molecule_id)
  k <- ncol(pca_features)
  Phi <- matrix(0, nlevels(mol_factor), k,
                dimnames = list(levels(mol_factor), NULL))
  for (b in seq_len(nlevels(mol_factor))) {
    in_bag <- as.integer(mol_factor) == b
    if (any(in_bag))
      Phi[b, ] <- colSums(pca_features[in_bag, , drop = FALSE])
  }
  Phi
}

in_sample_pca <- function(dataset, k = 50L) {
  d <- load_musk(dataset$path)
  Y <- bag_labels(d)
  sc <- fit_minmax(d$features)
  pca <- fit_pca(sc$Z, k)
  Phi <- build_Phi_pca(d$molecule, pca$Z)
  Y <- Y[rownames(Phi)]
  fit <- fit_or_mle(Phi, Y, control = list(maxit = 5000, factr = 10))
  list(
    k = k, N_bags = nrow(Phi), d_feat = ncol(Phi),
    rank_Phi = qr(Phi)$rank,
    obs_pos_rate = mean(Y), pred_pos_rate = mean(fit$p),
    auc_in_sample = compute_auc(Y, fit$p),
    n_beta_boundary = sum(fit$s <= 1e-6),
    convergence = fit$convergence
  )
}

loo_cv_pca <- function(dataset, k = 50L) {
  d <- load_musk(dataset$path)
  Y_all <- bag_labels(d)
  mol_levels <- names(Y_all)
  N_bags <- length(mol_levels)

  p_pred <- numeric(N_bags); names(p_pred) <- mol_levels
  for (i in seq_len(N_bags)) {
    held <- mol_levels[i]
    is_train_inst <- d$molecule != held
    train_feat <- d$features[is_train_inst, , drop = FALSE]
    train_mol  <- d$molecule[is_train_inst]
    sc <- fit_minmax(train_feat)
    pca <- fit_pca(sc$Z, k)
    Phi_train <- build_Phi_pca(train_mol, pca$Z)
    Y_train <- Y_all[rownames(Phi_train)]
    fit <- fit_or_mle(Phi_train, Y_train,
                      control = list(maxit = 3000, factr = 1e3))

    held_feat <- d$features[!is_train_inst, , drop = FALSE]
    held_scaled <- apply_minmax(held_feat, sc)
    held_pca <- apply_pca(held_scaled, pca)
    Phi_held <- colSums(held_pca)
    p_pred[i] <- 1 - exp(-sum(Phi_held * fit$s))
  }
  list(
    k = k, N_bags = N_bags, Y = Y_all, p_pred = p_pred,
    auc = compute_auc(Y_all, p_pred),
    accuracy_at_thresh_0.5 = mean(as.integer(p_pred >= 0.5) == Y_all)
  )
}

## ---------------------------------------------------------------------------
## Leave-one-bag-out cross-validation
## ---------------------------------------------------------------------------

loo_cv <- function(dataset, K) {
  d <- load_musk(dataset$path)
  Y_all <- bag_labels(d)
  mol_levels <- names(Y_all)
  N_bags <- length(mol_levels)

  p_pred <- numeric(N_bags)
  names(p_pred) <- mol_levels

  for (i in seq_len(N_bags)) {
    held <- mol_levels[i]
    is_train_inst <- d$molecule != held
    train_feat <- d$features[is_train_inst, , drop = FALSE]
    train_mol  <- d$molecule[is_train_inst]
    cl <- cluster_instances(train_feat, K, nstart = 10, iter.max = 30)
    M_train <- build_M(train_mol, cl$cluster, K)
    Y_train <- Y_all[rownames(M_train)]
    fit <- fit_or_mle(M_train, Y_train,
                      control = list(maxit = 5000, factr = 10))

    ## held-out bag: assign instances to training clusters, build a
    ## composition row, predict
    held_feat <- d$features[!is_train_inst, , drop = FALSE]
    held_cluster <- assign_to_clusters(held_feat, cl)
    m_held <- as.integer(tabulate(held_cluster, nbins = K))
    p_pred[i] <- 1 - exp(-sum(m_held * fit$s))
  }
  list(
    K = K, N_bags = N_bags,
    Y = Y_all, p_pred = p_pred,
    auc = compute_auc(Y_all, p_pred),
    accuracy_at_thresh_0.5 = mean(as.integer(p_pred >= 0.5) == Y_all)
  )
}

## ---------------------------------------------------------------------------
## Driver
## ---------------------------------------------------------------------------

datasets <- list(
  MUSK1 = list(path = "data/musk1/clean1.data"),
  MUSK2 = list(path = "data/musk2/clean2.data")
)

main <- function(K_values = c(10L, 20L),
                 out_path = "data/musk_results.rds") {
  results <- list()
  for (ds_name in names(datasets)) {
    ds <- datasets[[ds_name]]
    cat("\n=== ", ds_name, " ===\n", sep = "")
    in_samp <- lapply(K_values, function(K) {
      cat("  in-sample K =", K, "\n")
      in_sample(ds, K)
    })
    names(in_samp) <- paste0("K", K_values)
    cv <- lapply(K_values, function(K) {
      cat("  LOO-CV     K =", K, "\n")
      loo_cv(ds, K)
    })
    names(cv) <- paste0("K", K_values)
    cat("  in-sample continuous-feature\n")
    cont_in <- in_sample_continuous(ds)
    cat("  LOO-CV     continuous-feature\n")
    cont_cv <- loo_cv_continuous(ds)
    cat("  in-sample PCA-to-k=50\n")
    pca_in <- in_sample_pca(ds, k = 50L)
    cat("  LOO-CV     PCA-to-k=50\n")
    pca_cv <- loo_cv_pca(ds, k = 50L)
    results[[ds_name]] <- list(in_sample = in_samp, loo_cv = cv,
                                continuous_in_sample = cont_in,
                                continuous_loo_cv = cont_cv,
                                pca_in_sample = pca_in,
                                pca_loo_cv = pca_cv)
  }
  saveRDS(results, out_path)

  ## stdout summary
  cat("\n=== Summary ===\n")
  for (ds_name in names(results)) {
    cat("--", ds_name, "--\n")
    for (kn in names(results[[ds_name]]$in_sample)) {
      ins <- results[[ds_name]]$in_sample[[kn]]
      cv  <- results[[ds_name]]$loo_cv[[kn]]
      cat(sprintf(
        "  %s: rank(M)=%d cond=%.1f obs_pos_rate=%.2f pred=%.2f score_inf=%.2g n_bdy=%d AUC_in=%.3f AUC_LOO=%.3f acc_LOO=%.3f\n",
        kn, ins$rank_M, ins$condition_number, ins$obs_pos_rate,
        ins$pred_pos_rate, ins$score_inf, ins$n_boundary,
        ins$auc_in_sample, cv$auc, cv$accuracy_at_thresh_0.5))
      cat("    eta_hat:",
          paste(sprintf("%.3f", sort(ins$eta_hat, decreasing = TRUE)),
                collapse = " "), "\n")
      cat("    cluster sizes:",
          paste(ins$cluster_sizes, collapse = " "), "\n")
    }
    ci <- results[[ds_name]]$continuous_in_sample
    cc <- results[[ds_name]]$continuous_loo_cv
    cat(sprintf(
      "  continuous: rank(Phi)=%d/d=%d underid_dim=%d obs_pos=%.2f pred=%.2f n_beta_bdy=%d AUC_in=%.3f AUC_LOO=%.3f acc_LOO=%.3f\n",
      ci$rank_Phi, ci$d_feat, ci$underidentified_dim,
      ci$obs_pos_rate, ci$pred_pos_rate, ci$n_beta_boundary,
      ci$auc_in_sample, cc$auc, cc$accuracy_at_thresh_0.5))
    pi_ <- results[[ds_name]]$pca_in_sample
    pc_ <- results[[ds_name]]$pca_loo_cv
    cat(sprintf(
      "  PCA k=%d: rank(Phi)=%d/d=%d obs_pos=%.2f pred=%.2f n_beta_bdy=%d AUC_in=%.3f AUC_LOO=%.3f acc_LOO=%.3f\n",
      pi_$k, pi_$rank_Phi, pi_$d_feat,
      pi_$obs_pos_rate, pi_$pred_pos_rate, pi_$n_beta_boundary,
      pi_$auc_in_sample, pc_$auc, pc_$accuracy_at_thresh_0.5))
  }
  invisible(results)
}

if (sys.nframe() == 0L) main()
