data Prob;
input treatment time censor;
cards;
0	1	0
0	63	0
0	105	0
0	129	0
0	182	0
0	216	0
0	250	0
0	262	0
0	301	0
0	301	0
0	342	0
0	354	0
0	356	0
0	358	0
0	380	0
0	383	0
0	383	0
0	388	0
0	394	0
0	408	0
0	460	0
0	489	0
0	499	0
0	523	0
0	524	0
0	535	0
0	562	0
0	569	0
0	675	0
0	676	0
0	748	0
0	778	0
0	786	0
0	797	0
0	955	0
0	968	0
0	1000	0
0	1245	0
0	1271	0
0	1420	0
0	1551	0
0	1694	0
0	2363	0
0	2754	1
0	2950	1
1	17	0
1	42	0
1	44	0
1	48	0
1	60	0
1	72	0
1	74	0
1	95	0
1	103	0
1	108	0
1	122	0
1	144	0
1	167	0
1	170	0
1	183	0
1	185	0
1	193	0
1	195	0
1	197	0
1	208	0
1	234	0
1	235	0
1	254	0
1	307	0
1	315	0
1	401	0
1	445	0
1	464	0
1	484	0
1	528	0
1	542	0
1	547	0
1	577	0
1	580	0
1	795	0
1	855	0
1	1366	0
1	1577	0
1	2060	0
1	2412	1
1	2486	1
1	2796	1
1	2802	1
1	2934	1
1	2988	1
;run;
data prob; set prob;
treat=1-treatment;
run;
ods graphics on;
proc phreg data=prob;
model time*censor(1)= treat/ RL ties=breslow;
assess var=(treat) ph;
title problem 3b;
run;
proc phreg data=prob;
model time*censor(1)=z treat/ RL ties=breslow;
z=treat* time;
title problem 3b;
run;

data tongue;
input  DnaProf Time Death ;
cards;

1 1 1
1 3 1
1 3 1
1 4 1
1 10 1
1 13 1
1 13 1
1 16 1
1 16 1
1 24 1
1 26 1
1 27 1
1 28 1
1 30 1
1 30 1
1 32 1
1 41 1
1 51 1
1 65 1
1 67 1
1 70 1
1 72 1
1 73 1
1 77 1
1 91 1
1 93 1
1 96 1
1 100 1
1 104 1
1 157 1
1 167 1
1 61 0
1 74 0
1 79 0
1 80 0
1 81 0
1 87 0
1 87 0
1 88 0
1 89 0
1 93 0
1 97 0
1 101 0
1 104 0
1 108 0
1 109 0
1 120 0
1 131 0
1 150 0
1 231 0
1 240 0
1 400 0
2 1 1
2 3 1
2 4 1
2 5 1
2 5 1
2 8 1
2 12 1
2 13 1
2 18 1
2 23 1
2 26 1
2 27 1
2 30 1
2 42 1
2 56 1
2 62 1
2 69 1
2 104 1
2 104 1
2 112 1
2 129 1
2 181 1
2 8 0
2 67 0
2 76 0
2 104 0
2 176 0
2 231 0

;
data tongue; set tongue;
Type= dnaprof-1;
run;
proc phreg data=tongue;
model time*death(0)=type / RL ;
assess var=(type) ph;
title 'TIES=BRESLOW';
run;

proc phreg data=surv;
model survival__days_*Mortalityind(0)=mean_pth td/ RL ;
td=	mean_pth* survival__days_;

run;
