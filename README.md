# order-book-plot-find

Search for connected components in full-depth order-book for a trading day.

This project consists of two repositories. The main part of this project is here: https://github.com/leonid-tkach/order-book-plots

The presentation about this project: https://docs.google.com/presentation/d/1i27WkaikonMWRYUc3aiEB2DqW2aQznqykuqXclO93ko/edit#slide=id.g1a7e7bd42c3_1_92



Web App: https://orderbookplots.sleepyapper.com/



I use the algorithm for searching connected components from this book: https://algs4.cs.princeton.edu/41graph/

Technologies I used:

TECHS|I USED
---|---
|<img src="./pres/0python.png" width="50">|Python: finding obplots (connected components) and add them to log files.<br>*I used: pandas, os, regex, time, pandas, datetime, matplotlib.*
|<img src="./pres/0R.png" width="50">|R: some extra data tidying, drawing plots.<br>*I used: tidyverse (ggplot, dplyr, tidyr), shiny, DBI, RPostgres, pool, dygrpahs, DT.*
|<img src="./pres/0RShiny.png" width="50">|R Shiny: web application.
|<img src="./pres/0AWS.png" width="50">|Amazon Web Services: deploying my web application.<br>*I used: EC2 (for Shiny Server), RDS (for PostgreSQL), Route 53 (to register domain).*
|<img src="./pres/0Postgresql.png" width="50">|PostgreSQL: database.<br>*I used: pgAdmin, Windows PowerShell, TablePlus.*
|<img src="./pres/0ubuntu.png" width="50">|Ubuntu: EC2 operating system.<br>*I use PuTTy terminal to admin it.*
|<img src="./pres/0NGINX.png" width="50">|F5 NGINX: web server.
|<img src="./pres/0let-s-encrypt.png" width="50">|Let's Encrypt: to get certificates to use HTTPS.

## From the Past (`C++`)

File `algorithm_2013.cpp` contains code I used in 2013 to find the same order book plots. It's my algorithm, not the much better one from Prof. Sedgewick's book I use in this project.  I tried to program it in EViews first then, but it was going to take about 20 days. The same algorithm in C++ took about 4 hours, as far as I remember. 