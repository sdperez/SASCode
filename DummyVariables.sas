
data one;
input id season;
datalines;
1 1
2 1
3 1
4 1
5 2
6 3
7 2
8 2
9 3
10 4
11 4
;
run;
data new;set one;
Spring=(season=1);
Summer=(season=2);
Fall=(season=3);

Array a {3} spring summer fall;
	do i = 1 to 3;
	If season=" " then a(i) = " ";
	end;
run;
