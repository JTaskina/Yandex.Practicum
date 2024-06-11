**Задача 1**
Отобразите все записи из таблицы company по компаниям, которые закрылись.
  
SELECT COUNT(*)
FROM company
WHERE status = 'closed';

**Задача 2**
Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле funding_total.

SELECT   funding_total
FROM     company
WHERE    category_code = 'news'
     AND      country_code = 'USA'
ORDER BY funding_total DESC
  
**Задача 3**
Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
     AND CAST(acquired_at AS date) BETWEEN '2011-01-01' AND '2013-12-31' 
  
**Задача 4**
Отобразите имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'.

SELECT first_name,
       last_name,
       network_username
FROM people
WHERE network_username LIKE 'Silver%'
  
**Задача 5**
Выведите на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.

SELECT *
FROM people
WHERE network_username LIKE '%money%'
      AND last_name LIKE 'K%'
  
**Задача 6**
Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы

SELECT country_code,
       SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC
  
**Задача 7**
Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

SELECT CAST(funded_at AS date),
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY CAST(funded_at AS date)
HAVING MIN(raised_amount) != 0
       AND MIN(raised_amount) != MAX(raised_amount)

  
**Задача 8**
Создайте поле с категориями:
Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.

SELECT *,
CASE 
    WHEN invested_companies >= 100 THEN 'high_activity' 
    WHEN invested_companies < 100  AND invested_companies >=20 THEN 'middle_activity'
    ELSE 'low_activity'
    END
FROM fund     

**Задача 9**
Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.

SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds))
FROM fund
GROUP BY activity
ORDER BY ROUND(AVG(investment_rounds)) 

**Задача 10**
Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавьте сортировку по коду страны в лексикографическом порядке.

SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE CAST(founded_at AS date) BETWEEN '2010-01-01' AND '2012-12-31'
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10

**Задача 11**
Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.

SELECT i.first_name,
       i.last_name,
       p.instituition
FROM people AS i
LEFT JOIN education AS p ON i.id= p.person_id

**Задача 12**
Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий учебных заведений. Составьте топ-5 компаний по количеству университетов.

SELECT i.name,
       COUNT(DISTINCT t.instituition)
FROM company AS i
INNER JOIN people AS p ON p.company_id=i.id
INNER JOIN education AS t ON p.id=t.person_id
GROUP BY i.name
ORDER BY COUNT(t.instituition) DESC
LIMIT 5

**Задача 13**
Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.

SELECT DISTINCT i.name
FROM company AS i
LEFT JOIN funding_round AS p ON i.id=p.company_id
WHERE i.status = 'closed'
      AND p.is_first_round = 1
      AND p.is_last_round = 1

**Задача 14**
Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

SELECT DISTINCT i.id 
FROM people AS i
INNER JOIN company AS p ON i.company_id=p.id
INNER JOIN funding_round AS t ON p.id=t.company_id
WHERE p.status = 'closed'
      AND t.is_first_round = 1
      AND t.is_last_round = 1

**Задача 15**
Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.

SELECT DISTINCT i.id,
       m.instituition
FROM people AS i
INNER JOIN company AS p ON i.company_id=p.id
INNER JOIN funding_round AS t ON p.id=t.company_id
INNER JOIN education AS m ON i.id=m.person_id
WHERE p.status = 'closed'
      AND t.is_first_round = 1
      AND t.is_last_round = 1

**Задача 16**
Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.

 SELECT DISTINCT p.id,
       COUNT(ed.instituition)
FROM company AS com
INNER JOIN people AS p ON com.id=p.company_id
INNER JOIN education AS ed ON p.id=ed.person_id
WHERE STATUS LIKE '%closed%'
  AND com.id IN (SELECT company_id
                FROM funding_round
                 WHERE is_first_round = 1
                   AND is_last_round = 1)

GROUP BY p.id

**Задача 17**

Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.

SELECT AVG(nmk.sc)
FROM (SELECT DISTINCT p.id,
       COUNT(ed.instituition) AS sc
FROM company AS com
INNER JOIN people AS p ON com.id=p.company_id
INNER JOIN education AS ed ON p.id=ed.person_id
WHERE STATUS LIKE '%closed%'
  AND com.id IN (SELECT company_id
                FROM funding_round
                 WHERE is_first_round = 1
                   AND is_last_round = 1

GROUP BY p.id) AS nmk

**Задача 18**
Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet.

SELECT AVG(nmk.sc)
FROM (SELECT DISTINCT p.id,
       COUNT(ed.instituition) AS sc
FROM company AS com
INNER JOIN people AS p ON com.id=p.company_id
INNER JOIN education AS ed ON p.id=ed.person_id
WHERE com.name LIKE 'Socialnet'
GROUP BY p.id) AS nmk

**Задача 19**
Составьте таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.

SELECT f.name AS name_of_fund,
       com.name AS name_of_company,
       fr.raised_amount AS amount
FROM investment AS i
INNER JOIN company AS com ON i.company_id=com.id
INNER JOIN fund AS f ON i.fund_id=f.id
INNER JOIN funding_round AS fr ON i.funding_round_id=fr.id
WHERE com.milestones > 6
   AND EXTRACT(YEAR FROM CAST (fr.funded_at AS TIMESTAMP)) BETWEEN 2012 AND 2013

**Задача 20**
Выгрузите таблицу, в которой будут такие поля:
название компании-покупателя;
сумма сделки;
название компании, которую купили;
сумма инвестиций, вложенных в купленную компанию;
доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями.

 WITH 
x AS(SELECT a.id AS id_1,
     c.name AS i_c,
       a.price_amount AS pa
FROM acquisition AS a
LEFT JOIN company AS c ON a.acquiring_company_id=c.id
WHERE a.price_amount > 0),

y AS(SELECT a.id AS id_2,
     c.name AS ed_c,
       c.funding_total AS ft
FROM acquisition AS a
LEFT JOIN company AS c ON a.acquired_company_id=c.id
WHERE c.funding_total > 0)
SELECT x.i_c,
       x.pa,
       y.ed_c,
       y.ft,
       ROUND (x.pa/y.ft)
FROM x 
INNER JOIN y ON x.id_1=y.id_2 
ORDER BY x.pa DESC, y.ed_c ASC
LIMIT 10 

**Задача 21**

Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования.

x AS(SELECT company_id,
       EXTRACT(MONTH FROM CAST(funded_at AS date)) AS month
FROM funding_round
WHERE raised_amount > 0
      AND EXTRACT(YEAR FROM CAST(funded_at AS date)) BETWEEN 2010 AND 2013),
      
y AS (SELECT id,
       name       
FROM company
WHERE category_code = 'social')
SELECT y.name,
       x.month
FROM x
INNER JOIN y ON x.company_id=y.id

**Задача 22**
Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
номер месяца, в котором проходили раунды;
количество уникальных названий фондов из США, которые инвестировали в этом месяце;
количество компаний, купленных за этот месяц;
общая сумма сделок по покупкам в этом месяце.

x AS(SELECT EXTRACT(MONTH FROM CAST(funded_at AS date)) AS month,
      COUNT(DISTINCT f.name) AS fund_name
FROM investment AS i
INNER JOIN funding_round AS fr ON fr.id = i.funding_round_id
INNER JOIN fund AS f ON f.id=i.fund_id
WHERE f.country_code ='USA'
      AND fr.funded_at BETWEEN '2010-01-01' AND '2013-12-31'
GROUP BY month),
y AS (SELECT  EXTRACT(MONTH FROM CAST(acquired_at AS date)) AS month,
        COUNT(acquired_company_id) AS count,
        SUM(price_amount) AS sum
FROM acquisition
WHERE acquired_at BETWEEN '2010-01-01' AND '2013-12-31'
GROUP BY month)
SELECT x.month,
       x.fund_name,
       y.count,
       y.sum
FROM x
INNER JOIN y ON x.month=y.month

**Задача 23**

Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.

WITH
inv_2011 AS (SELECT country_code,
                    AVG(funding_total)
            FROM company 
             WHERE EXTRACT(YEAR FROM CAST(founded_at AS date))=2011
            GROUP BY country_code
            HAVING COUNT(id) >0),
inv_2012 AS (SELECT country_code,
                    AVG(funding_total)
            FROM company 
             WHERE EXTRACT(YEAR FROM CAST(founded_at AS date))=2012
            GROUP BY country_code
            HAVING COUNT(id) >0),            
inv_2013 AS (SELECT country_code,
                    AVG(funding_total)
            FROM company 
             WHERE EXTRACT(YEAR FROM CAST(founded_at AS date))=2013
            GROUP BY country_code
            HAVING COUNT(id) >0)
SELECT    inv_2011.country_code,
          inv_2011.avg AS inv_2011,
          inv_2012.avg AS inv_2012,
          inv_2013.avg AS inv_2013
FROM inv_2011   
INNER JOIN inv_2012 ON inv_2011.country_code=inv_2012.country_code
INNER JOIN inv_2013 ON inv_2012.country_code=inv_2013.country_code    
ORDER BY inv_2011 DESC
