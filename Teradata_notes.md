
### Create Temporary Table

##### Step 1 : Create output table with no data and index on(field1,field2)

```sql
CREATE volatile table my_table AS (
SELECT  t1.field1,
t1.field2,
t1.field3,
t1.field4
FROM schema.table1 t1
inner join table2 t2 on t1.key = t2.key 
where  t1.field4 = 2
qualify rank () over ( partition by t1.field1, t1.field2 order by t1.field4 ) = 1
)
WITH NO DATA PRIMARY INDEX (field1,field2) ON COMMIT PRESERVE ROWS;
```

##### Step 2: Insert the data into output table
```sql
insert into my_table
SELECT  t1.field1,
t1.field2,
t1.field3,
t1.field4
FROM schema.table1 t1
inner join table2 t2 on t1.key = t2.key 
where  t1.field4 = 2
qualify rank () over ( partition by t1.field1, t1.field2 order by t1.field4 ) = 1
```

### Create Permanent in Teradata.  Retrieve with SAS.

##### Step 1 : Create permanent table
```sql
create table schema.table as (
Select field1,
field2
from schema.table1 a
join schema.table2 b on a.field=b.field
join schema.table3 c on c.field = b.field
where 1=1
and date='2018-12-10'
and field>=0
and field <>'VAD VAL'
and time > 0)
WITH DATA PRIMARY INDEX ( field1 ) ;
```

##### Step 2 : Retreive with SAS
```
libname myschema Teradata SERVER=' ' user=''  password=''  schema='theschema' ;
proc print data=myschema.table1 (obs=10); run;
```

### Create Teradata dataset from SAS, then bring into SAS

```sql
proc sql;
  connect to teradata (user="&username." password="&password." server='subdomain.domain.com'  mode=teradata);

    -- Create table
    execute (
      CREATE volatile table my_table AS (
      SELECT t1.field1,
      t1.field2,
      t1.field3,
      t1.field4
      FROM schema.table1 t1
      inner join table2 t2 on t1.key = t2.key 
      where  t1.field4 = 2
      WITH NO DATA PRIMARY INDEX (field1,field2) ON COMMIT PRESERVE ROWS;
      ) by Teradata;

    -- Insert data for days 1 - 15
    execute (
      insert into my_table
      SELECT t1.field1,
      t1.field2,
      t1.field3,
      t1.field4
      FROM schema.table1 t1
      inner join table2 t2 on t1.key = t2.key 
      where  1=1
      and t1.field4 = 2
			and t1.date >=  '2018-12-01'
			and t1.date < '2018-12-16';
      ) by Teradata;
      
    -- Insert data for days 15 - 31
    execute (
      insert into my_table
      SELECT t1.field1,
      t1.field2,
      t1.field3,
      t1.field4
      FROM schema.table1 t1
      inner join table2 t2 on t1.key = t2.key 
      where  1=1
      and t1.field4 = 2
			and t1.date >=  '2018-12-16'
			and t1.date < '2019-01-01';
      ) by Teradata;

	create table mylib.my_perm_table AS
	select * from connection to teradata (select * from my_table);
	   disconnect from teradata;
     
  quit;
```
