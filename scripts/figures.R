## figures.R: produce the three paper figures from results.rds and
## data/musk_results.rds. Written to figures/*.pdf.

suppressPackageStartupMessages({
  library(ggplot2)
})

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

if (!dir.exists("figures")) dir.create("figures")

theme_paper <- function(base_size = 9) {
  theme_bw(base_size = base_size) +
    theme(panel.grid.minor = element_blank(),
          legend.position = "right",
          legend.key.size = unit(0.4, "cm"),
          legend.title = element_text(size = base_size - 1),
          legend.text = element_text(size = base_size - 1),
          strip.background = element_blank(),
          strip.text = element_text(face = "bold"),
          plot.margin = margin(2, 2, 2, 2))
}

## ---------------------------------------------------------------------------
## Figure 1: rank-collapse diagnostic
## ---------------------------------------------------------------------------

make_fig_rank <- function(results, out_path) {
  per_seed <- results$per_seed
  eta_true <- per_seed[[1]]$e1_eta_true
  s_true <- -log(1 - eta_true)
  s1_true <- s_true[1]; s2_true <- s_true[2]
  identified_const <- 2 * s1_true + s2_true   # 2 s1 + s2 = const along the ridge

  ## Collect (s1, s2) pairs across seeds and starts for both designs.
  collect <- function(field, design_label) {
    out <- do.call(rbind, lapply(per_seed, function(ps) {
      m <- ps[[field]]
      data.frame(s1 = m[1, ], s2 = m[2, ], seed = ps$seed)
    }))
    out$design <- design_label
    out
  }
  rd <- collect("e1_rd_s_starts", "Rank-deficient (rank M = 4)")
  sa <- collect("e1_sa_s_starts", "Singleton-augmented (rank M = 5)")
  df <- rbind(rd, sa)
  df$design <- factor(df$design,
                      levels = c("Rank-deficient (rank M = 4)",
                                 "Singleton-augmented (rank M = 5)"))

  ## Identified-ridge line: 2 s1 + s2 = const, i.e. s2 = const - 2 s1.
  s1_grid <- seq(0, max(df$s1) * 1.1, length.out = 100)
  ridge <- data.frame(
    s1 = s1_grid, s2 = identified_const - 2 * s1_grid,
    design = factor("Rank-deficient (rank M = 4)",
                    levels = levels(df$design)))
  ridge <- ridge[ridge$s2 >= 0, ]

  truth <- data.frame(s1 = s1_true, s2 = s2_true)

  p <- ggplot(df, aes(x = s1, y = s2)) +
    geom_line(data = ridge, linetype = "dashed", colour = "grey50") +
    geom_point(aes(colour = factor(seed)), alpha = 0.6, size = 1.4,
               show.legend = FALSE) +
    geom_point(data = truth, shape = 4, size = 3.2, stroke = 1.0,
               colour = "black") +
    facet_wrap(~ design, scales = "free") +
    coord_cartesian(xlim = c(0, max(df$s1) * 1.1),
                    ylim = c(0, max(df$s2) * 1.1)) +
    labs(x = expression(hat(s)[1]),
         y = expression(hat(s)[2])) +
    theme_paper()

  ggsave(out_path, p, width = 6.4, height = 2.8, units = "in",
         device = grDevices::cairo_pdf)
}

## ---------------------------------------------------------------------------
## Figure 2: noisy-OR firing-rate confound
## ---------------------------------------------------------------------------

make_fig_firing_rate <- function(results, out_path) {
  rhos <- results$agg$e3_noisy_rhos
  Q    <- results$agg$e3_noisy_ratio_q          # 3 (lo/med/hi) x K x length(rhos)
  K <- dim(Q)[2]
  eta_true <- results$single_seed_exp3$eta_true

  df <- do.call(rbind, lapply(seq_along(rhos), function(j) {
    data.frame(
      rho = rhos[j],
      type = factor(seq_len(K),
                    labels = paste0("eta=", format(eta_true, nsmall = 2))),
      ratio_lo  = Q[1, , j],
      ratio_med = Q[2, , j],
      ratio_hi  = Q[3, , j]
    )
  }))

  p <- ggplot(df, aes(x = rho, y = ratio_med, colour = type,
                      group = type)) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                colour = "grey50") +
    geom_ribbon(aes(ymin = ratio_lo, ymax = ratio_hi, fill = type),
                alpha = 0.15, colour = NA) +
    geom_line() +
    geom_point(size = 1.6) +
    scale_x_continuous(breaks = sort(unique(df$rho)),
                       limits = c(0.45, 1.05)) +
    scale_y_continuous(limits = c(0, 1.2)) +
    labs(x = expression("True firing rate " * rho),
         y = expression(hat(eta)[k] / eta[k] *
                          " (median across seeds, IQR ribbon)"),
         colour = "Instance type",
         fill = "Instance type") +
    theme_paper()

  ggsave(out_path, p, width = 4.8, height = 2.9, units = "in",
         device = grDevices::cairo_pdf)
}

## ---------------------------------------------------------------------------
## Figure 3: MUSK per-type instance positivity
## ---------------------------------------------------------------------------

make_fig_musk <- function(musk_results, out_path) {
  panels <- list(
    list(label = "MUSK1 (K = 20)",
         eta = musk_results$MUSK1$in_sample$K20$eta_hat,
         sizes = musk_results$MUSK1$in_sample$K20$cluster_sizes),
    list(label = "MUSK2 (K = 20)",
         eta = musk_results$MUSK2$in_sample$K20$eta_hat,
         sizes = musk_results$MUSK2$in_sample$K20$cluster_sizes)
  )
  df <- do.call(rbind, lapply(panels, function(p) {
    o <- order(p$eta, decreasing = TRUE)
    data.frame(
      panel = p$label,
      rank = seq_along(o),
      eta = p$eta[o],
      size = p$sizes[o],
      boundary = p$eta[o] < 1e-6
    )
  }))
  df$panel <- factor(df$panel, levels = c("MUSK1 (K = 20)", "MUSK2 (K = 20)"))

  p <- ggplot(df, aes(x = rank, y = eta, fill = boundary)) +
    geom_col(width = 0.85) +
    facet_wrap(~ panel, scales = "free_y") +
    scale_fill_manual(values = c(`FALSE` = "grey30", `TRUE` = "grey75"),
                      labels = c(`FALSE` = "interior",
                                 `TRUE` = "boundary"),
                      name = NULL) +
    labs(x = "Instance type (sorted by fitted positivity)",
         y = expression(hat(eta)[k])) +
    theme_paper() +
    theme(legend.position = c(0.88, 0.85),
          legend.background = element_rect(fill = "white", colour = NA))

  ggsave(out_path, p, width = 6.4, height = 2.6, units = "in",
         device = grDevices::cairo_pdf)
}

## ---------------------------------------------------------------------------
## Driver
## ---------------------------------------------------------------------------

main <- function() {
  cat("Reading results ...\n")
  results <- readRDS("results.rds")
  musk_results <- if (file.exists("data/musk_results.rds"))
    readRDS("data/musk_results.rds") else NULL

  cat("Figure 1: rank-collapse diagnostic ...\n")
  make_fig_rank(results, "figures/fig_rank_collapse.pdf")
  cat("Figure 2: firing-rate confound ...\n")
  make_fig_firing_rate(results, "figures/fig_firing_rate.pdf")
  if (!is.null(musk_results)) {
    cat("Figure 3: MUSK per-type eta ...\n")
    make_fig_musk(musk_results, "figures/fig_musk_eta.pdf")
  } else {
    cat("(skipping Figure 3: data/musk_results.rds not found)\n")
  }
  cat("Done.\n")
}

if (sys.nframe() == 0L) main()
