/*
Запрос получает количество покупателей
из таблицы customers
Проект: Продажи
Задание 4
https://ru.hexlet.io/projects/92/members/50321?step=4
*/
SELECT 
	COUNT (customer_id) AS customers_count
FROM customers
WHERE first_name IS NOT NULL; -- Проверка отсутствия NULL 