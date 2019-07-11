--
--  First, we need test data:
--
create table tq84_test (
   txt_1    varchar(20),
   num      integer,
   txt_2    varchar(20)
);

insert into tq84_test values ('one' , 1, 'eins');
insert into tq84_test values ('two' , 2, 'zwei');
insert into tq84_test values ('null', 0,  null );

select * from tq84_test;

---------------------------------------------------------------------

-- select quotename('foo''bar', '''');

--
--  This is the statement that I want to create:
--
select
   count(*) - count(txt_1),
   count(*) - count(num  ),
   count(*) - count(txt_2)
from
   tq84_test;

---------------------------------------------------------------------

--
--  This should be possible using information_schema.columns
--
--
--  The following select statement runs on SQL Server. It adds the columns
--  p (for part) and q (because it's the letter that follows p). They're used
--  to sort the parts of the statements.
--
   
select stmt from (
 select  -1 p, 0 q, 'select ' stmt
union all
 select 0 p, ordinal_position q,
   'count(*) - count(' + column_name + ')'   + 
      case when row_number() over (order by ordinal_position) < count(*) over () then ',' else '' end as stmt -- Add commans except for last aggregate function
 from
   information_schema.columns
 where
   table_name = 'tq84_test'
union all
 select 1 p, 0 q, ' from tq84_test;' stmt
) s
order by
  p, q ;


--
--  This is the statement that it produced:
--

select 
count(*) - count(txt_1),
count(*) - count(num),
count(*) - count(txt_2)
from tq84_test;

--
--  Increase the difficulty
--
--  I want to create something like

update col set cnt_not_null = 0 where name = 'txt_1'; -- for each column

--
--  This might be possible with something like
--
select 'update col set cnt = ' + str(count(*) - count(txt_1)) + ' where name = ''txt_1'';'         + char(10) + char(13)
from
   tq84_test;

--
--  The following Query runs on SQL Server.
--  Note: the final '+' must be removed manually
--

select 'select ' union all
select
   --   select  'update col set cnt = '  + str(count(*) - count(    txt_1         )) + '  where name =          ''txt_1'';'           + char(10) + char(13)
   --  'select ''update col set cnt = '' + str(count(*) - count(' + column_name +')) + '' where name = ''''' + column_name + ''''';   + char(10) + char(13) '
              '''update col set cnt = '' + str(count(*) - count(' + column_name +')) + '' where name = ''''' + column_name + ''''';'' + char(10) + char(13) + ' --  '+ '
from
   information_schema.columns
where
   table_name = 'tq84_test'
union all
  select ' from tq84_test';
