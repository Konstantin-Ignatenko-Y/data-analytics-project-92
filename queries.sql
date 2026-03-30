SELECT 
	COUNT (customer_id) AS customers_count
FROM customers
WHERE first_name IS NOT NULL; -- Проверка отсутствия NULL 
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет количество покупателей
-- Проект: Продажи 
-- Задание: 4
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=4

SELECT
    e.first_name || ' ' || e.last_name AS seller,
	COUNT(s.sales_id) AS operations,
	SUM(FLOOR(COALESCE(s.quantity, 0) * COALESCE(p.price, 0))) AS income --Замена NULL на 0, округление, агрегация
FROM employees e
LEFT JOIN sales s
    ON s.sales_person_id = e.employee_id
LEFT JOIN products p
    ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет с продавцами у которых наибольшая выручка
-- Проект: Продажи 
-- Задание: 5
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=5


WITH seller_avg_income AS ( --Средняя выручка за сделку по каждому продавцу
    SELECT
        e.employee_id,
        e.first_name || ' ' || e.last_name AS seller,
        AVG(COALESCE(s.quantity, 0) * COALESCE(p.price, 0)) AS average_income_employee
    FROM employees e
    LEFT JOIN sales s 
	    ON e.employee_id = s.sales_person_id
    LEFT JOIN products p 
	    ON s.product_id = p.product_id
    GROUP BY e.employee_id, e.first_name, e.last_name
),
all_avg AS ( --Средняя выручка за сделку по всем продавцам
    SELECT 
	    AVG(COALESCE(s.quantity, 0) * COALESCE(p.price, 0)) AS all_avg_income
    FROM sales s
    JOIN products p 
	    ON s.product_id = p.product_id
)
SELECT
    sa.seller,
    FLOOR(sa.average_income_employee) AS average_income
	-- ROUND(sa.average_income_employee)::integer AS average_income  --Еще один вариант округления до целого
FROM seller_avg_income sa
CROSS JOIN all_avg aa --Соединение таблиц: одного общего среднего значения с таблицей всех средних значений
WHERE sa.average_income_employee < aa.all_avg_income 
    AND sa.average_income_employee <> 0
ORDER BY sa.average_income_employee ASC;
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет с продавцами чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
-- Проект: Продажи 
-- Задание: 5
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=5


SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COALESCE(TRIM(TO_CHAR(s.sale_date, 'Day')),'no_data') AS day_of_week, --Проверка на отсутствие даты, лишние пробелы, преобразование в название
    FLOOR(SUM(COALESCE(s.quantity, 0) * COALESCE(p.price, 0))) AS income --Проверки на отсутствие значений
FROM employees e
LEFT JOIN sales s 
    ON e.employee_id = s.sales_person_id
LEFT JOIN products p 
    ON s.product_id = p.product_id
WHERE s.sale_date IS NOT NULL --Проверка на отсутствие даты
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    EXTRACT(ISODOW FROM s.sale_date), --Группировка по дню недели начиная с понедельника
    TO_CHAR(s.sale_date, 'Day') --
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date) ASC, --Сортировка по дню недели начиная с понедельника
    seller ASC;
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет выручки продавцов по дням недели
-- Проект: Продажи 
-- Задание: 5
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=5