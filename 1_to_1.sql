create or replace view tq84_1to1 as
--
--  Check if the values of one column deteremine
--  the values of the other column, and vice versa.
--
--
select
   col_1.table_name              as tab  ,
   col_1.column_name             as col_1,
   col_2.column_name             as col_2,
   concat(
      'select * from (
         select
            ', col_1.column_name, ',
            ', col_2.column_name, ',
            count(*) over (partition by ', col_1.column_name, ') cnt_1,
            count(*) over (partition by ', col_2.column_name, ') cnt_2
         from ',
            col_1.table_name
         ,' group by
            ', col_1.column_name, ',
            ', col_2.column_name, '
      ) s
      where
         cnt_1 > 1 or
         cnt_2 > 1;'
   )        stmt
from
   information_schema.columns col_1    join
   information_schema.columns col_2 on  col_1.table_name   = col_2.table_name   and 
                                        col_1.table_schema = col_2.table_schema
;
