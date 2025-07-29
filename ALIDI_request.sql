--Пример запросов
--1.	На основании таблицы с продажами необходимо рассчитать среднюю цену продажи, по следующим критериям:
--ТЦ 10, категория Wines
--Город Ekaterinburg, категории Sweets и Grocery
--
--Поля в результате:
--store_id, cma, art_name, средняя цена продажи



SELECT s.store_id, p.cma, p.art_name, AVG(s.sell_val_gsp / s.sell_qty_colli) AS avg_sales
FROM sales s
JOIN product p ON s.art_no=p.art_no
JOIN stores st ON s.store_id = st.store_id
WHERE (s.store_id = 10 AND p.cma = 'Wines') OR (st.city_desc = 'Ekaterinburg' and p.cma in ('Sweets', 'Grocery'))
GROUP BY s.store_id, p.cma, p.art_name
ORDER BY s.store_id, p.cma, p.art_name;

--
--2.	На основании таблицы с продажами необходимо рассчитать по категориям:
-- сколько было продано единиц товара и на какую сумму, по регулярной цене и в рамках предоставленной скидки.
--
--Поля в результате:
--месяц продажи, cma, период со скидкой\без скидки, кол-во единиц товара, сумма продажи


SELECT EXTRACT(monthname from s.date_of_day) AS месяц_продажи, p.cma,
CASE
	WHEN pd.art_no IS NOT NULL THEN 'период_со_скидкой'
	ELSE 'без_скидки'
END discount,
sum(s.sell_qty_colli) AS total_quanity,
sum(sell_val_gsp) AS total_sales
FROM sales s
JOIN product p ON s.art_no = p.art_no
LEFT JOIN prod_disc pd ON s.art_no = p.art_no
AND s.store_id = pd.store_id
AND s.date_of_day BETWEEN pd.date_from and pd.date_to
GROUP BY месяц_продажи, p.cma, discount
ORDER BY месяц_продажи, p.cma;


--3.	На основании таблицы с предоставленными скидками необходимо вывести:
-- список категорий, артикулов, их наименований, ТЦ, название городов. Рассчитать процент скидки на каждой позиции.
--Критерии:
--Город Nizhny Novgorod
--Категории Drinks, Wines, Bakery
--Дата действия скидки 15 марта 2018
--
--Поля в результате:
--город, ТЦ, категория, артикул, наименование, % скидки
--Оставить только те строки, где скидка превышает 50%

SELECT st.city_desc AS Город, st.store_id AS ТЦ, p.art_no AS Артикул, p.art_name AS Наименование, round((1-(pd.discount_colli_gsp/ old_colli_gsp)) *100, 2) AS Процент_скидки
FROM prod_disc pd
JOIN stores st ON pd.store_id = st.store_id
JOIN product p ON pd.art_no = p.art_no
WHERE st.city_desc = 'Nizhny Novgorod'
     AND p.cma IN ('Drinks', 'Wines', 'Bakery')
     AND '2018-03-15' BETWEEN pd.date_from and pd.date_to #запрос отработал, но из-за формата даьы м. словаться на реальном df
     AND (1-(pd.discount_colli_gsp/ old_colli_gsp))* 100 > 50
ORDER BY Город, ТЦ, Наименование;

--4.	На основании таблицы по продажам на уровне региона в каждой категории товара вывести топ 5 артикулов по сумме продаж в рублях. 
--
--Поля в результате:
--регион, категория, артикул, сумма продажи
SELECT tm.Регион, tm.Категория, tm.Артикул, tm.Сумма_продажи
FROM
(
SELECT st.district AS Регион, p.cma AS Категория, p.art_name AS  Артикул, sum(sell_val_gsp) as Сумма_продажи,
RANK() OVER (PARTITION BY st.district, p.cma ORDER BY SUM(s.sell_val_gsp) DESC) AS TOP_art_name
FROM sales s
JOIN stores AS st ON s.store_id = st.store_id
JOIN product p ON s.art_no = p.art_no
GROUP BY st.district, p.cma, p.art_name
) AS tm

WHERE TOP_art_name <=5
ORDER BY tm.Регион, tm.Категория, tm.Артикул, tm.Сумма_продажи DESC;



--5.	На основании таблицы с продажами, посчитать накопитольную сумму продажи за 22 год в разбивке по месяцам.
--Поля в результате:
--месяц, накопительный итог
SELECT tm.month, sum(tm.month_total) OVER (ORDER BY tm.month) AS Накопительный_итог
FROM 
(
SELECT EXTRACT(monthname from date_of_day) AS month,
        EXTRACT(month from date_of_day) AS month_num,
        sum(sell_val_gsp) AS month_total
FROM sales
WHERE EXTRACT(YEAR from date_of_day) = 2022
GROUP BY EXTRACT(monthname from date_of_day), 
         EXTRACT(month from date_of_day)     
) AS tm 
ORDER BY tm.month;
























