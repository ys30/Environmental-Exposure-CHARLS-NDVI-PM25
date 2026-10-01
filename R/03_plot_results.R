# Publication-style summary figure for the current CHARLS–NDVI results
# Uses only estimates documented in the consolidated results tables.
library(ggplot2)
library(dplyr)
library(patchwork)

primary <- tibble::tribble(
  ~spec, ~beta, ~lo, ~hi, ~p,
  "Alternative contextual set A", -0.496, -0.859, -0.134, 0.0072,
  "Alternative contextual set B", -0.491, -0.854, -0.129, 0.0079,
  "Primary contextual set",       -0.477, -0.831, -0.122, 0.0085
)

sensitivity <- tibble::tribble(
  ~spec, ~beta, ~p,
  "City-specific linear trends", -0.630, 0.0054,
  "Primary model",               -0.477, 0.0085,
  "Consumption complete cases",  -0.231, 0.2768
)

# Earlier lag comparison. Keep separate from the final fully adjusted model:
# these estimates should not be mixed as if they came from one final specification.
lags <- tibble::tribble(
  ~lag, ~beta, ~lo, ~hi, ~p,
  "Lag 1", -0.144, -0.501,  0.213, 0.4280,
  "Lag 2", -0.521, -0.864, -0.178, 0.0029,
  "Lag 3",  0.040, -0.279,  0.359, 0.8070
)

theme_pub <- theme_minimal(base_size=12) +
  theme(panel.grid.minor=element_blank(),
        plot.title=element_text(face="bold", size=13),
        plot.subtitle=element_text(color="grey35", size=9),
        axis.title.y=element_blank())

p1 <- ggplot(primary, aes(beta, reorder(spec, beta))) +
  geom_vline(xintercept=0, linetype=2, color="grey55") +
  geom_errorbarh(aes(xmin=lo, xmax=hi), height=.12, linewidth=.7) +
  geom_point(size=3) +
  scale_x_continuous(limits=c(-1, .1)) +
  labs(title="A  Primary result and contextual robustness",
       subtitle="Final fully adjusted models; effect per +0.1 NDVI",
       x="Difference in CESD-10 (95% CI)") + theme_pub

p2 <- ggplot(sensitivity, aes(beta, reorder(spec, beta))) +
  geom_vline(xintercept=0, linetype=2, color="grey55") +
  geom_segment(aes(x=0, xend=beta, y=reorder(spec,beta), yend=reorder(spec,beta)),
               linewidth=.7, color="grey65") +
  geom_point(size=3) +
  geom_text(aes(label=sprintf("β = %.3f   p = %.4f", beta, p)),
            hjust=ifelse(sensitivity$beta < 0, 1.08, -.08), size=3.2) +
  scale_x_continuous(limits=c(-.95,.12)) +
  labs(title="B  Sensitivity specifications",
       subtitle="CIs not reported in the current summary for these sensitivity estimates",
       x="NDVI coefficient") + theme_pub

p3 <- ggplot(lags, aes(beta, lag)) +
  geom_vline(xintercept=0, linetype=2, color="grey55") +
  geom_errorbarh(aes(xmin=lo, xmax=hi), height=.12, linewidth=.7) +
  geom_point(size=3) +
  scale_x_continuous(limits=c(-1,.5)) +
  labs(title="C  Exploratory lag pattern",
       subtitle="Earlier spatial + wave-FE comparison; final common-covariate lag series still to be rerun",
       x="Difference in CESD-10 (95% CI)") + theme_pub

fig <- (p1 | p2) / p3 +
  plot_annotation(
    title="Residential greenness and depressive symptoms in CHARLS",
    subtitle="Negative coefficients indicate fewer depressive symptoms with higher NDVI",
    caption="Primary model: β = −0.477 (95% CI −0.831 to −0.122), p = 0.0085; N = 63,004. Observational associations."
  )

ggsave("figures/ndvi-results-summary.png", fig, width=12, height=8, dpi=300, bg="white")
ggsave("figures/ndvi-results-summary.pdf", fig, width=12, height=8, bg="white")
