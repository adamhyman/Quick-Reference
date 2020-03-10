
*  Split's &orig into &num numbered files  ;

%macro split(orig, num);

%if %upcase(&orig) = %str(HELP) %then %do;
		%put %nrstr(%%split%(orig	 =  name of dataset, );
		%put %nrstr(       num =  number of output datasets, named &orig._1 - &orig._&num.%));
		%end;
	%else %do;

        data _null_;
            if 0 then set &orig. nobs=count;
            call symput('numobs',put(count,8.));
            run;
        %let n=%sysevalf(&numobs/&num,ceil);
        data %do J=1 %to &num ; &orig._&J %end; ;
            set &orig.;
            %do I=1 %to &num;
            if %eval(&n*(&i-1)) <_n_ <= %eval(&n*&I) then output &orig._&I;
            %end;
        run;
    %end;
%mend split;
