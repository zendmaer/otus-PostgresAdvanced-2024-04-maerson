# Задание № 1
## Работа с уровнями изоляции транзакции в PostgreSQL

### Предварительные операции
```sql
-- Создаём таблицу 'persons' и заполняем начальными данными
create table persons(id serial, first_name text, second_name text);
insert into persons(first_name, second_name) values('ivan', 'ivanov');
insert into persons(first_name, second_name) values('petr', 'petrov');
```

```sql
-- Смотрим уровень изоляций в обеих сессиях
show transaction isolation level;
```
```console
 transaction_isolation 
-----------------------
 read committed
(1 row)
```

### <a name="read_committed"/>Уровень изоляции 'read committed' (значение по умолчанию)

```console

[//]: # (В нескольких вкладках консоли заходим в postgres, организуем две сессии)
sudo -u postgres psql
```

```sql
-- Отключаем автокомит в обеих сессиях, чтобы проверить уровни изоляции
\set AUTOCOMMIT OFF
```

```sql
-- В первой сессии вставляем запись
insert into persons(first_name, second_name) values('sergey', 'sergeev');
```
```sql
-- Во второй сессии начинаем транзакцию и смотрим вывод
begin;
select * from persons;
```

```console
[//]: # (Получаем первоначальный результат, третья строчка не добавилась)
 id | first_name | second_name 
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
(2 rows)
```
```sql
-- В первой сессии коммитим изменения и снова смотрим вывод во второй сессии (select)
commit;
```

```console
[//]: # (На этот раз видим три записи)
 id | first_name | second_name 
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
  8 | sergey     | sergeev
(3 rows)
```

```sql
-- Завершаем транзакцию во второй сессии
commit;
```

**Опеределение.**\
[*read committed*](#read_committed) - уровень изоляции, разрешающий читать только зафиксированные данные.\
**Вывод.**\
По этой причине в первом случае (до коммита в первой сессии) мы получали данные которые 
уже были зафиксированы.\
Во втором случае произошла фиксация (commit) и согласно определению уровня данной изоляции 
мы беспрепятственно смогли прочитать новые данные.

### <a name="repeatable_read"/>Уровень изоляции 'repeatable read'
```sql
-- В обеих сессиях начинаем новые транзакции и меняем уровень изоляции
begin;
set transaction isolation level repeatable read;
```

```sql
-- В первой сессии добавляем данные и проверяем содержимое таблицы во второй сессии (select)
insert into persons(first_name, second_name) values('sveta', 'svetova');
```
```console
[//]: # (Данные остались прежними как и при уровне изоляции по умолчанию - read committed)
 id | first_name | second_name 
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
  8 | sergey     | sergeev
(3 rows)
```
```sql
-- Фиксируем транзакцию в первой сессии и проверяем содержимое таблицы во второй сессии (select)
commit;
```
```console
[//]: # (Данные остались прежними)
 id | first_name | second_name 
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
  8 | sergey     | sergeev
(3 rows)
```
```sql
-- Фиксируем транзакцию во второй сессии и снова проверяем содержимое таблицы (select)
commit;
```
```console
[//]: # (Данные изменились)
 id | first_name | second_name 
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
  8 | sergey     | sergeev
  9 | sveta      | svetova
(4 rows)
```

**Опеределение.**\
[*repeatable read*](#repeatable_read) - более строгий уровень изоляции, 
по сравнению с [read committed](#read_committed).\
Допускает чтение только фиксированных данных, но также гарантирует что\
прочитанные данные будут теми же (неизменчивость).\
**Вывод.**\
По этой причине в первом случае (до коммита в первой сессии) мы получали данные которые 
уже были зафиксированы как и в случае с [read committed](#read_committed).\
После фиксации изменений в первой сессии во второй изменений мы не получили. 
Однако, после фиксации транзакции во второй сессии мы смогли получить изменённые данные. 
Что и следует из определения уровня изоляции [repeatable read](#repeatable_read).

---
[К началу](#задание--1) | [На главную](../README.MD)