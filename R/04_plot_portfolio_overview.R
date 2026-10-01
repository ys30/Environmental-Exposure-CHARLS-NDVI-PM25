# China-wide CHARLS portfolio results figure
# Uses only documented project estimates.
library(ggplot2); library(dplyr); library(patchwork)
primary <- tibble::tribble(~spec,~beta,~lo,~hi,~p,
"Alternative contextual set A",-0.496,-0.859,-0.134,0.0072,
"Alternative contextual set B",-0.491,-0.854,-0.129,0.0079,
"Primary contextual set",-0.477,-0.831,-0.122,0.0085)
sensitivity <- tibble::tribble(~spec,~beta,~p,
"City-specific linear trends",-0.630,0.0054,
"Primary model",-0.477,0.0085,
"Consumption complete cases",-0.231,0.2768)
lags <- tibble::tribble(~lag,~beta,~lo,~hi,~p,
"Lag 1",-0.144,-0.501,0.213,0.4280,
"Lag 2",-0.521,-0.864,-0.178,0.0029,
"Lag 3",0.040,-0.279,0.359,0.8070)
theme_pub <- theme_minimal(base_size=11)+theme(panel.grid.minor=element_blank(),panel.grid.major.y=element_blank(),plot.title=element_text(face="bold",size=12),plot.subtitle=element_text(size=8.5),axis.title.y=element_blank())
p1 <- ggplot(primary,aes(beta,reorder(spec,beta)))+geom_vline(xintercept=0,linetype=2)+geom_errorbarh(aes(xmin=lo,xmax=hi),height=.1)+geom_point(size=3)+labs(title="B · Primary association",subtitle="Final fully adjusted models · per +0.1 NDVI",x="Difference in CESD-10 (95% CI)")+theme_pub
p2 <- ggplot(sensitivity,aes(beta,reorder(spec,beta)))+geom_vline(xintercept=0,linetype=2)+geom_segment(aes(x=0,xend=beta,y=reorder(spec,beta),yend=reorder(spec,beta)))+geom_point(size=3)+geom_text(aes(label=sprintf("%.3f",beta)),nudge_x=-.04,hjust=1,size=3)+labs(title="C · Specification sensitivity",subtitle="Point estimates; CIs unavailable in consolidated summary",x="NDVI coefficient")+theme_pub
p3 <- ggplot(lags,aes(beta,lag))+geom_vline(xintercept=0,linetype=2)+geom_errorbarh(aes(xmin=lo,xmax=hi),height=.1)+geom_point(size=3)+labs(title="D · Exploratory lag pattern",subtitle="Earlier spatial + wave-FE comparison",x="Difference in CESD-10 (95% CI)")+theme_pub
workflow <- ggplot()+xlim(0,1)+ylim(0,1)+annotate("rect",xmin=.02,xmax=.98,ymin=.05,ymax=.95,fill="#f1f6f2")+annotate("text",x=.06,y=.86,label="A · China-wide exposure workflow",hjust=0,fontface="bold",size=4.2)+annotate("text",x=.06,y=.70,label="MOD13A3 monthly NDVI (1 km)",hjust=0,size=3.4)+annotate("text",x=.06,y=.56,label="Pixel Reliability QA + MCD12Q1 masks",hjust=0,size=3.2)+annotate("text",x=.06,y=.42,label="Prefecture × month greenness · 2005–2020",hjust=0,size=3.2)+annotate("text",x=.06,y=.28,label="City PM2.5 + harmonized CHARLS person-waves",hjust=0,size=3.2)+annotate("text",x=.06,y=.13,label="→ longitudinal CESD-10 models",hjust=0,fontface="bold",size=3.4)+theme_void()
fig <- (workflow|p1)/(p2|p3)+plot_annotation(title="Greenness, air pollution and depressive symptoms across China",subtitle="Remote-sensing exposure engineering linked with longitudinal CHARLS data",caption="Primary NDVI result: β = −0.477 (95% CI −0.831 to −0.122), p = 0.0085; N = 63,004. Observational association.")
ggsave("figures/china-charls-environmental-exposure-results.png",fig,width=13,height=8,dpi=300,bg="white")
ggsave("figures/china-charls-environmental-exposure-results.pdf",fig,width=13,height=8,bg="white")
