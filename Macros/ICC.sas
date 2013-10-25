data temp; set mylib.veincta;
keep ID AKsmallmin_a AKsmallmin_b BKsmallmin_a BKsmallmin_b;run;
proc means; var  AKsmallmin_a AKsmallmin_b BKsmallmin_a BKsmallmin_b;run;

data temp; set temp;
missing=1;
if AKsmallmin_a>. then missing=0;
if AKsmallmin_b>. then missing=0;
if BKsmallmin_a>. then missing=0;
if BKsmallmin_b>. then missing=0;
run;
proc freq; tables missing; run;
data temp; set temp; if missing=0; run;


data ICC_AK;
input id $ diameter;
cards;
1	0.223333333
1	0.203333333
2	0.44
2	0.44
3.1	0.24
3.1	0.31
3.2	0.24
3.2	0.243333333
4.1	0.37
4.1	0.37
4.2	0.27
4.2	0.333333333
5.1	0.34
5.1	0.353333333
5.2	0.503333333
5.2	0.5
6.1	0.383333333
6.1	0.37
6.2	0.35
6.2	0.263333333
7	0.22
7	0.23
8.1	0.323333333
8.1	0.243333333
8.2	0.27
8.2	0.31
10	0.523333333
10	0.523333333
11.1	0.49
11.1	0.363333333
11.2	0.39
11.2	0.23
12.1	0.6
12.1	0.64
12.2	0.3
12.2	0.323333333
13	0.28
13	0.323333333
14.1	0.23
14.1	0.233333333
14.2	0.38
14.2	0.326666667
15.1	0.17
15.1	0.17
15.2	0.243333333
15.2	0.25
16	0.27
16	0.216666667
17	0.496666667
17	0.48
18	0.59
18	0.53
19	0.35
19	0.33
20	0.37
20	0.29
21	0.35
21	0.35
22.1	0.16
22.1	0.16
22.2	0.276666667
22.2	0.18
23.1	0.17
23.1	0.17
23.2	0.23
23.2	0.17
24	0.173333333
24	0.26
25	0.35
25	0.413333333
25	0.29
25	0.26
26	0.28
26	0.393333333
27.1	0.29
27.1	0.31
27.2	0.14
27.2	0.2
;
run;

%macro Icc_sas(ds, response, subject);
ods output OverallANOVA =all;
proc glm data=&ds;
class &subject;
model &response=&subject;
run;
data Icc(keep=sb sw n R R_low R_up);
retain sb sw n;
set all end=last;
if source='Model' then sb=ms;
if source='Error' then do;sw=ms; n=df; end;
if last then do;
R=round((sb-sw)/(sb+sw), 0.01);
vR1=((1-R)**2)/2;
vR2=(((1+R)**2)/n +((1-R)*(1+3*R)+4*(R**2))/(n-1));
VR=VR1*VR2;
L=(0.5*log((1+R)/(1-R)))-(1.96*sqrt(VR))/((1+R)*(1-R));
U=(0.5*log((1+R)/(1-R)))+(1.96*sqrt(VR))/((1+R)*(1-R));
R_Low=(exp(2*L)-1)/(exp(2*L)+1);
R_Up=(exp(2*U)-1)/(exp(2*U)+1);
output;
end;
run;
proc print data=icc noobs split='*';
var r r_low r_up;
label r='ICC*' r_low='Lower bound*' r_up='Upper bound*';
title 'Reliability test: ICC and its confidence limits';
run;
%mend;

%icc_sas(ds=icc_ak, response=diameter, subject=id);


data ICC_BK;
input id $ diameter;
cards;
1	0.17
1	0.203333333
3.1	0.25
3.1	0.263333333
4.1	0.273333333
4.1	0.24
4.2	0.21
5	0.28
5	0.326666667
6.1	0.17
6.1	0.243333333
6.2	0.226666667
6.2	0.236666667
7	0.2
7	0.31
8	0.183333333
8	0.196666667
10	0.37
10	0.306666667
11.1	0.186666667
11.1	0.17
11.2	0.253333333
11.2	0.28
12.1	0.323333333
12.1	0.47
12.2	0.3
12.2	0.376666667
13	0.29
13	0.29
14	0.24
14	0.27
14	0.17
14	0.23
15.1	0.17
15.1	0.17
15.2	0.16
15.2	0.17
16	0.17
16	0.17
18	0.433333333
18	0.48
20	0.15
20	0.16
22	0.23
23.1	0.25
23.1	0.17
23.2	0.17
23.2	0.17
24	0.196666667
24	0.18
25	0.22
25	0.22
26	0.26
26	0.21
27.1	0.2
27.1	0.17
27.2	0.2
27.2	0.17
;
run;
%icc_sas(ds=icc_bk, response=diameter, subject=id);
