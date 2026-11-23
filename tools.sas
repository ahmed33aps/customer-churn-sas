%let DATA_DIR=.;


FILENAME REFFILE "&DATA_DIR./Customer-Churn-Records.csv";

PROC IMPORT DATAFILE=REFFILE
    DBMS=CSV
    OUT=WORK.IMPORT
    REPLACE;
    GETNAMES=YES;
RUN;

data churn;
    set import;
run;

proc contents data=churn;
run;

/* Do not print raw customer rows. */


proc means data=churn;
run;

proc freq data=churn;
    tables Exited  gender geography;
run;

proc sgplot data=churn;
    histogram age;
run;

proc sgplot data=churn;
    vbar Exited ;
run;

proc sgplot data=churn;
    vbox balance / category=Exited;
run;

proc means data=churn nmiss;
run;

proc means data=churn noprint;
 var age;
 output out=age_summary mean=age_mean;
run;

data churn_clean;
    if _n_=1 then set age_summary(keep=age_mean);
    set churn;

    if missing(balance) then balance=0;
    if missing(age) then age=age_mean;
run;

data churn_features;
    set churn_clean;

    age_group = (age > 40);
    high_balance = (balance > 100000);
run;

proc logistic data=churn_features;
    class gender geography / param=ref;
    model Exited(event='1') = age balance tenure numofproducts;
run;

proc logistic data=churn_features plots=roc;
    model Exited(event='1') = age balance tenure;
run;

proc sgplot data=churn_features;
    scatter x=age y=balance / group=Exited markerattrs=(size=5);
    title 'Age vs Balance by Churn Status';
run;

proc sgplot data=churn_features;
    vbar geography / group=Exited groupdisplay=stack;
    title 'Churn Distribution by Geography';
run;
proc sgplot data=churn_features;
    density age / group=Exited;
    title 'Age Density by Churn Status';
run;
proc sgplot data=churn_features;
    heatmap x=numofproducts y=tenure / colorstat=freq;
    title 'Heatmap: Number of Products vs Tenure';
run;
