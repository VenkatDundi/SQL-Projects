create table t1(id int);

insert into t1 values(1);
insert into t1 values(2);
insert into t1 values(3);

select * from t1;
delete from t2;

create table t2(id int);

insert into t2 values(7);
insert into t2 values(8);
insert into t2 values(9);
insert into t2 values(4);
insert into t2 values(5);
insert into t2 values(6);

select * from t2;




/* Inner */

select count(*) from t1 right join t2 on t1.id = t2.id;