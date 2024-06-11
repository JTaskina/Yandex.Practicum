SELECT COUNT(*)
FROM company
WHERE status = 'closed';


Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
     AND CAST(acquired_at AS date) BETWEEN '2011-01-01' AND '2013-12-31'
