-- Создание тестовой таблички
create table persons(id serial, first_name text, second_name text);

-- Вставка тестовых данных
insert into persons(first_name, second_name) values('ivan', 'ivanov');
insert into persons(first_name, second_name) values('petr', 'petrov');
commit;

-- Проверка уровня изоляции на момент первой записи (read committed)
show transaction isolation level;

-- Сессия 1
insert into persons(first_name, second_name) values('sergey', 'sergeev');
-- Сессия 2
select * from persons;
set transaction isolation level repeatable read;