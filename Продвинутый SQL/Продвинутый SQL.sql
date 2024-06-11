**ЗАДАЧА 1**
Найдите количество вопросов, которые набрали больше 300 очков или как минимум 100 раз были добавлены в «Закладки».
  
SELECT COUNT(id)
FROM stackoverflow.posts 
WHERE (favorites_count>=100 OR score >300) AND post_type_id = 1

**ЗАДАЧА 2**
Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно? Результат округлите до целого числа.

WITH p AS (SELECT CAST(DATE_TRUNC('day',p.creation_date) AS date) AS day,
     pt.type,
     COUNT(p.id) AS count
FROM stackoverflow.posts p
LEFT JOIN stackoverflow.post_types pt ON pt.id=p.post_type_id
WHERE pt.type= 'Question' AND (CAST(DATE_TRUNC('day',p.creation_date) AS date) BETWEEN '2008-11-01' AND '2008-11-18')
GROUP BY day,pt.type)
SELECT ROUND(AVG(count))
FROM p
  
**ЗАДАЧА 3**
Сколько пользователей получили значки сразу в день регистрации? Выведите количество уникальных пользователей.

SELECT COUNT(DISTINCT u.id)
FROM stackoverflow.users u
JOIN stackoverflow.badges b ON u.id=b.user_id
WHERE DATE_TRUNC('day', b.creation_date)::date=DATE_TRUNC('day', u.creation_date)::date
  
**ЗАДАЧА 4**
Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос?

SELECT COUNT(DISTINCT p.id)
FROM stackoverflow.posts p
JOIN stackoverflow.users u ON p.user_id=u.id
JOIN stackoverflow.votes v ON v.post_id=p.id
WHERE display_name = 'Joel Coehoorn'
  
**ЗАДАЧА 5**
Выгрузите все поля таблицы vote_types. Добавьте к таблице поле rank, в которое войдут номера записей в обратном порядке. Таблица должна быть отсортирована по полю id.

SELECT *,
    ROW_NUMBER() OVER (ORDER BY id DESC)
FROM stackoverflow.vote_types
ORDER BY id
  
**ЗАДАЧА 6**
Отберите 10 пользователей, которые поставили больше всего голосов типа Close. Отобразите таблицу из двух полей: идентификатором пользователя и количеством голосов. Отсортируйте данные сначала по убыванию количества голосов, потом по убыванию значения идентификатора пользователя.

SELECT v.user_id,
COUNT(v.id) AS count
FROM stackoverflow.users u 
JOIN stackoverflow.votes v ON u.id=v.user_id
JOIN stackoverflow.vote_types vt ON vt.id=v.vote_type_id 
WHERE vt.name= 'Close'
GROUP BY v.user_id,vt.name
ORDER BY count DESC,user_id DESC
LIMIT 10 
  
**ЗАДАЧА 7**
Отберите 10 пользователей по количеству значков, полученных в период с 15 ноября по 15 декабря 2008 года включительно.
Отобразите несколько полей:
идентификатор пользователя;
число значков;
место в рейтинге — чем больше значков, тем выше рейтинг.
Пользователям, которые набрали одинаковое количество значков, присвойте одно и то же место в рейтинге.
Отсортируйте записи по количеству значков по убыванию, а затем по возрастанию значения идентификатора пользователя.

SELECT user_id,
       COUNT(id) AS count,
       DENSE_RANK() OVER (ORDER BY COUNT(id) DESC)
FROM stackoverflow.badges 
WHERE DATE_TRUNC('day',creation_date)::date BETWEEN '2008-11-15' AND '2008-12-15'
GROUP BY user_id
ORDER BY count DESC,user_id
LIMIT 10
  
**ЗАДАЧА 8**
Сколько в среднем очков получает пост каждого пользователя?
Сформируйте таблицу из следующих полей:
заголовок поста;
идентификатор пользователя;
число очков поста;
среднее число очков пользователя за пост, округлённое до целого числа.
Не учитывайте посты без заголовка, а также те, что набрали ноль очков.

SELECT title,
       user_id,
       score,
     ROUND(AVG(score) OVER (PARTITION BY user_id))
FROM stackoverflow.posts
WHERE score != 0 AND title IS NOT NULL

**ЗАДАЧА 9**
Отобразите заголовки постов, которые были написаны пользователями, получившими более 1000 значков. Посты без заголовков не должны попасть в список.

WITH p AS (SELECT user_id,
COUNT(id) AS count
FROM stackoverflow.badges
GROUP BY user_id
HAVING COUNT(id) >1000)
SELECT title
FROM stackoverflow.posts t
JOIN p ON t.user_id=p.user_id
WHERE title IS NOT NULL

**ЗАДАЧА 10**
Напишите запрос, который выгрузит данные о пользователях из Канады (англ. Canada). Разделите пользователей на три группы в зависимости от количества просмотров их профилей:
пользователям с числом просмотров больше либо равным 350 присвойте группу 1;
пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу 2;
пользователям с числом просмотров меньше 100 — группу 3.
Отобразите в итоговой таблице идентификатор пользователя, количество просмотров профиля и группу. Пользователи с количеством просмотров меньше либо равным нулю не должны войти в итоговую таблицу.

SELECT DISTINCT id,
       views,
      CASE
       WHEN views < 100 THEN 3
       WHEN views >= 350 THEN 1
      ELSE 2
       END AS kat
FROM stackoverflow.users 
WHERE location LIKE  '%Canada%'  AND views > 0 
  
**ЗАДАЧА 11**
Дополните предыдущий запрос. Отобразите лидеров каждой группы — пользователей, которые набрали максимальное число просмотров в своей группе. Выведите поля с идентификатором пользователя, группой и количеством просмотров. Отсортируйте таблицу по убыванию просмотров, а затем по возрастанию значения идентификатора.

WITH p AS (
SELECT DISTINCT id,
       views,
      CASE
       WHEN views < 100 THEN 3
       WHEN views >= 350 THEN 1
      ELSE 2
       END AS kat
FROM stackoverflow.users 
WHERE location LIKE  '%Canada%'  AND views > 0 ),
t AS (
SELECT id, views,kat,MAX (views) OVER (PARTITION BY kat) AS max
FROM p
ORDER BY views DESC, id)
SELECT id,views,kat
FROM t
WHERE views=max
ORDER BY views DESC, id
  
**ЗАДАЧА 12**
Посчитайте ежедневный прирост новых пользователей в ноябре 2008 года. Сформируйте таблицу с полями:
номер дня;
число пользователей, зарегистрированных в этот день;
сумму пользователей с накоплением.

WITH p AS(
    SELECT 
    EXTRACT('day' FROM creation_date::date) AS day,
   
       COUNT(id) AS count--OVER (PARTITION BY EXTRACT('day' FROM creation_date::date)) AS count    
FROM stackoverflow.users
WHERE creation_date::date BETWEEN '2008-11-01' AND '2008-11-30'
         GROUP BY EXTRACT('day' FROM creation_date::date)
         ) 

SELECT DISTINCT day,count,
      SUM(count) OVER(ORDER BY day)::int
FROM p
 
**ЗАДАЧА 13**
Для каждого пользователя, который написал хотя бы один пост, найдите интервал между регистрацией и временем создания первого поста. Отобразите:
идентификатор пользователя;
разницу во времени между регистрацией и первым постом.

WITH p AS (
SELECT u.id,
      u.creation_date AS reg,
      p.creation_date AS post,
      MIN(p.creation_date) OVER (PARTITION BY u.id) AS min,
      p.creation_date-u.creation_date AS days
FROM stackoverflow.users u
JOIN stackoverflow.posts p ON u.id=p.user_id)

SELECT id,
       days
FROM p
WHERE post=min
  
**ЗАДАЧА 14**
Выведите общую сумму просмотров у постов, опубликованных в каждый месяц 2008 года. Если данных за какой-либо месяц в базе нет, такой месяц можно пропустить. Результат отсортируйте по убыванию общего количества просмотров.

SELECT 
       DATE_TRUNC('month', creation_date)::date,
       SUM(views_count) 
FROM  stackoverflow.posts
WHERE creation_date::date BETWEEN '2008-01-01' AND '2008-12-31'
GROUP BY DATE_TRUNC('month', creation_date)::date
ORDER BY sum DESC
  
**ЗАДАЧА 15**
Выведите имена самых активных пользователей, которые в первый месяц после регистрации (включая день регистрации) дали больше 100 ответов. Вопросы, которые задавали пользователи, не учитывайте. Для каждого имени пользователя выведите количество уникальных значений user_id. Отсортируйте результат по полю с именами в лексикографическом порядке.

SELECT u.display_name,
       COUNT(DISTINCT p.user_id)
FROM stackoverflow.posts AS p
JOIN stackoverflow.users AS u 
ON p.user_id=u.id
JOIN stackoverflow.post_types AS pt
ON pt.id=p.post_type_id
WHERE p.creation_date::date BETWEEN u.creation_date::date AND (u.creation_date::date + INTERVAL '1 month') 
      AND pt.type LIKE 'Answer'
GROUP BY u.display_name
HAVING COUNT(p.id) > 100
ORDER BY u.display_name;

**ЗАДАЧА 16**
Выведите количество постов за 2008 год по месяцам. Отберите посты от пользователей, которые зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре того же года. Отсортируйте таблицу по значению месяца по убыванию.

SELECT DATE_TRUNC('month',p.creation_date)::date AS month,
       COUNT(p.id) AS count
FROM stackoverflow.posts p
JOIN stackoverflow.users u ON u.id=p.user_id
WHERE DATE_TRUNC('year',p.creation_date)::date ='2008-01-01' AND u.id IN 
            (SELECT u.id AS user_id      
             FROM stackoverflow.posts p
             JOIN stackoverflow.users u ON u.id=p.user_id
             WHERE DATE_TRUNC('month',u.creation_date)::date='2008-09-01' AND                              DATE_TRUNC('month',p.creation_date)::date='2008-12-01')
 GROUP BY month  
 ORDER BY month DESC
  
**ЗАДАЧА 17**
Используя данные о постах, выведите несколько полей:
идентификатор пользователя, который написал пост;
дата создания поста;
количество просмотров у текущего поста;
сумма просмотров постов автора с накоплением.
Данные в таблице должны быть отсортированы по возрастанию идентификаторов пользователей, а данные об одном и том же пользователе — по возрастанию даты создания поста.

SELECT user_id ,creation_date,views_count,SUM(views_count) OVER (PARTITION BY user_id ORDER BY creation_date)
FROM stackoverflow.posts
ORDER BY user_id, creation_date

**ЗАДАЧА 18**
Сколько в среднем дней в период с 1 по 7 декабря 2008 года включительно пользователи взаимодействовали с платформой? Для каждого пользователя отберите дни, в которые он или она опубликовали хотя бы один пост. Нужно получить одно целое число — не забудьте округлить результат.

WITH p AS(SELECT user_id,COUNT(DISTINCT DATE_TRUNC('day',creation_date)::date) AS count_days
FROM  stackoverflow.posts
WHERE creation_date::date BETWEEN '2008-12-01'AND '2008-12-07'
GROUP BY user_id)
SELECT ROUND(AVG(count_days))::int
FROM p
  
**ЗАДАЧА 19**
На сколько процентов менялось количество постов ежемесячно с 1 сентября по 31 декабря 2008 года? Отобразите таблицу со следующими полями:
Номер месяца.
Количество постов за месяц.
Процент, который показывает, насколько изменилось количество постов в текущем месяце по сравнению с предыдущим.
Если постов стало меньше, значение процента должно быть отрицательным, если больше — положительным. Округлите значение процента до двух знаков после запятой.
Напомним, что при делении одного целого числа на другое в PostgreSQL в результате получится целое число, округлённое до ближайшего целого вниз. Чтобы этого избежать, переведите делимое в тип numeric.

WITH p AS (
SELECT EXTRACT(MONTH FROM creation_date::date) AS month,
       COUNT(id) AS sum,
       LAG(COUNT(id)) OVER (ORDER BY EXTRACT(MONTH FROM creation_date::date)) AS lag
FROM stackoverflow.posts
WHERE creation_date::date BETWEEN '2008-09-01' AND '2008-12-31'
GROUP BY month)
SELECT month,sum,
       ROUND((sum::numeric/lag*100)-100,2)
       FROM p
  
**ЗАДАЧА 20**

Найдите пользователя, который опубликовал больше всего постов за всё время с момента регистрации. Выведите данные его активности за октябрь 2008 года в таком виде:
номер недели;
дата и время последнего поста, опубликованного на этой неделе.

SELECT  DISTINCT(EXTRACT(week FROM creation_date::date)) AS week,
        MAX(creation_date) OVER (PARTITION BY EXTRACT(week FROM creation_date::date))
        FROM stackoverflow.posts
WHERE creation_date::date BETWEEN '2008-10-01' AND '2008-10-31' AND user_id IN (SELECT user_id
       
FROM  stackoverflow.posts
GROUP BY user_id
ORDER BY SUM(id) DESC
LIMIT 1)  
