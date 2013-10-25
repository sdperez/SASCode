data crcfull;
do id=1 to 3;
 do i=1 to 6;
 visitno=i;
 weight= i*2*(id/3);
 fatwt=i*.5;
 output;
 end;
end;
 run;
data work.combo1;
array wt(6) weight1 weight2 weight3 weight4 weight5 weight6; ** 
Weight1 through 6 are the new variable names you are creating**;
array fw (6) fatwt1 - fatwt6;
***fw(1) is the first element in the fw array;
do i=1 to 6;
 set work.crcfull;
 by id;
 wt(i) = weight;*weight is the original variable you are 'transposing';
 fw(i) = fatwt;
 if last.id then return; *** Stops the loop from looking for vist 6 if we are on the last visit;
end;
keep id weight1-weight6 fatwt1-fatwt6;
run;