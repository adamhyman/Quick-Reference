# SAS-Programs

SAS Programs and code I use frequently.

## Do Over and Array macros
The original Do_Over and Array macros, and excellent documentation, can be found [here](http://www.sascommunity.org/wiki/Tight_Looping_with_Macro_Arrays).

It consists of Do_Over, Array and Numlist.

#### My modifications:
Added a Monthlist macro, to deal with month ranges, in the form of *yyyymm*, where *mm* only takes values of 01 - 12.

Modified the  Do_Over and Array macro, to enable "Months" as an option, in addition to values.

#### Compare:

```
%put %do_over(values = 201609 - 201703);

201809 201810 201811 201812 201813 201814 201815 201816 201817 201818 201819 201820 201821 201822 201823 201824 201825 201826 
201827 201828 201829 201830 201831 201832 201833 201834 201835 201836 201837 201838 201839 201840 201841 201842 201843 201844 
201845 201846 201847 201848 201849 201850 201851 201852 201853 201854 201855 201856 201857 201858 201859 201860 201861 201862 
201863 201864 201865 201866 201867 201868 201869 201870 201871 201872 201873 201874 201875 201876 201877 201878 201879 201880 
201881 201882 201883 201884 201885 201886 201887 201888 201889 201890 201891 201892 201893 201894 201895 201896 201897 201898 
201899 201900 201901
```

#### With:
```
%put %do_over(months = 201809 - 201901);

201809 201810 201811 201812 201901
```

##### Example:
```
%macro set_rwx(month);
	x "chmod a=rwx /folder1/folder2/folder3/data_&month..sas7bdat";
	x "chmod a=rwx /folder1/folder2/folder3/data2_&month..sas7bdat";
%mend;

%do_over(macro = set_rwx, months = 201701-201812);
```
