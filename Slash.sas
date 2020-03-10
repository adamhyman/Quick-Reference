%macro slash(data_in, by, slash, items, data_out);

%if %upcase(&data_in.) eq %str(HELP) %then %do;
	%put %nrstr(%%slash%( data_in  =  table name of input table,) ;
	%put %str(        by       =  space-separated list of variables to slash by,);
	%put %str(        slash    =  space-separated list of variables to slash up,);
	%put %str(        items    =  number of items to slash up,);
	%put %str(        data_out = table name (with no dataset options) being created by the macro%););
	%end;
%else %do;

/*	%put slash is &slash.;*/

	%array(slash, values=&slash.);
	%array(by, values=&by.);


	%let by = %do_over(by);
	%let by_last = &&by&byN;

	*  Get total Count  ;
	proc sort data=&data_in. (keep=&by.) out=_slash_all_1; 
			by	&by.;
			run;

	proc summary data = _slash_all_1 nway missing;	
		output out= _slash_all_2 (drop=_type_ rename=( _freq_=total_count) );
		by &by.;
	run;


	%do i=1 %to &slashN.;

		%let slash = &&slash&i;

		*  Get Count for each slashed value  ;
		proc sort data=&data_in. (keep=&by. &slash.) out=_slash1; 
				by	&by. &slash.;
				run;

		proc summary data = _slash1 nway missing;	
			output out= _slash2 (drop=_type_ rename=( _freq_=count) );
			by &by. &slash.;
		run;

		*  Calculate percentage (Slashed count / Total count)  ;
		data _slash3 (drop=newvar total_count);
			length &slash. $200;
			merge _slash2 _slash_all_2;
			by &by.;
			newvar = ' (' || compress(put(count / total_count * 100, 3.)) || ')';  *  Numeric to character conversion. ;
			&slash. = trim(&slash.) || newvar;
		run;

		proc sort data=_slash3; by &by. descending count; run;
		data _slash4;
			set  _slash3;
			by &by.  ;
			If first.&by_last. then counter = 0;
				Counter + 1;
			If counter le &items.;
			Drop counter; 
		Run;

		proc transpose data=_slash4
			out=_slash5 (drop=_name_)
			prefix=&slash.;
			by &by.;
			var &slash. ;
		run;

		
		data _slash6_&i. (drop= %do_over(values=1-&items., phrase=&slash.?));
		set _slash5;
			format &slash. $200.;

			&slash. = %do_over(values=1-&items., phrase=trim(&slash.?), between=||' / '||);

			*  Get rid of extra ' / ' in &slash. ;
			%do_over(values=2-&items., phrase=
							/*  If last 2 characters = ' /' then remove ' /' from the end  */
							if substr(&slash., length(&slash.) - 1, length(&slash.)) = ' /' then &slash. = substr(&slash., 1, length(&slash.)-2);
							/*  If last character = ' ' then remove ' ' from the end  */
							if substr(&slash., length(&slash.), length(&slash.)) = ' ' then &slash. = substr(&slash., 1, length(&slash.)-1);
			);
		run;


	%end;

	data &data_out.;
		merge %do_over(slash, phrase = _slash6_?_I_ )
			_slash_all_2;
		by &by.;
		run;

%end;


proc datasets nolist;
	delete _slash:;
	run;


%mend;
