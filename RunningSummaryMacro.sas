libname R "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\SASCode";
libname s "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\Studies\ReturnOR";
%inc "C:\Users\sdperez.EMORYUNIVAD\Desktop\My Documents\SASCode\Macros\summary.sas";
%summary(data=r.myeloma_problem, con1=POP, class=REGISTRY);
%summary(data=s.return, con1=Age1 BMI ,cat2=returnor, class=sex);
