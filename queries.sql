SELECT COUNT(customer_id) AS customers_count
FROM customers
WHERE first_name IS NOT NULL; 
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет количество покупателей
-- Файл результат: customers_count.csv +
-- Проект: Продажи 
-- Задание: 4
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=4

SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(COALESCE(s.quantity, 0) * COALESCE(p.price, 0))) AS income
FROM employees AS e
LEFT JOIN sales AS s
    ON e.employee_id = s.sales_person_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет с продавцами у которых наибольшая выручка
-- Файл результат: top_10_total_income.csv
-- Проект: Продажи 
-- Задание: 5
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=5


WITH seller_avg_income AS (
    SELECT
        e.employee_id,
        e.first_name || ' ' || e.last_name AS seller,
        AVG(COALESCE(s.quantity, 0) * COALESCE(p.price, 0))
            AS average_income_employee
    FROM employees AS e
    LEFT JOIN sales AS s
        ON e.employee_id = s.sales_person_id
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY e.employee_id, e.first_name, e.last_name
),

all_avg AS (
    SELECT AVG(COALESCE(s.quantity, 0) * COALESCE(p.price, 0)) AS all_avg_income
    FROM sales AS s
    INNER JOIN products AS p
        ON s.product_id = p.product_id
)

SELECT
    sa.seller,
    FLOOR(sa.average_income_employee) AS average_income
FROM seller_avg_income AS sa
CROSS JOIN all_avg AS aa
WHERE
    sa.average_income_employee < aa.all_avg_income
    AND sa.average_income_employee <> 0
ORDER BY sa.average_income_employee ASC;
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет с продавцами чья средняя выручка 
--     за сделку меньше средней выручки за сделку по всем продавцам
-- Файл результат: lowest_average_income.csv +
-- Проект: Продажи 
-- Задание: 5
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=5


SELECT
    e.first_name || ' ' || e.last_name AS seller,
    LOWER(COALESCE(TRIM(TO_CHAR(s.sale_date, 'Day')), 'no_data'))
        AS day_of_week,
    FLOOR(SUM(COALESCE(s.quantity, 0) * COALESCE(p.price, 0))) AS income
FROM employees AS e
LEFT JOIN sales AS s
    ON e.employee_id = s.sales_person_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
WHERE s.sale_date IS NOT NULL
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    EXTRACT(ISODOW FROM s.sale_date),
    TO_CHAR(s.sale_date, 'Day')
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date) ASC,
    seller ASC;
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет выручки продавцов по дням недели
-- Файл результат: day_of_the_week_income.csv
-- Проект: Продажи 
-- Задание: 5
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=5

SELECT
    CASE
        WHEN c.age >= 16 AND c.age <= 25 THEN '16-25'
        WHEN c.age >= 26 AND c.age <= 40 THEN '26-40'
        WHEN c.age > 40 THEN '40+'
        ELSE '<16'
    END AS age_category,
    COUNT(c.customer_id) AS age_count
FROM customers AS c
GROUP BY age_category
ORDER BY age_category;
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет количество покупателей в разных возрастных группах
-- Проект: Продажи
-- Файл результат: age_groups.csv +
-- Задание: 6
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=6

SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(COALESCE(s.quantity, 0) * COALESCE(p.price, 0))) AS income
FROM sales AS s
LEFT JOIN customers AS c
    ON s.customer_id = c.customer_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    TO_CHAR(s.sale_date, 'YYYY-MM');
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет помесячный, количество покупателей с общей выручкой
-- Файл результат: customers_by_month.csv -
-- Проект: Продажи 
-- Задание: 6
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=6

WITH min_date AS (
    SELECT
        p.price,
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        MIN(s.sale_date) AS sale_date
    FROM customers AS c
    LEFT JOIN sales AS s
        ON c.customer_id = s.customer_id
    LEFT JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY
        p.price,
        c.customer_id,
        c.last_name,
        e.first_name,
        e.last_name
    HAVING p.price = 0
    ORDER BY c.customer_id
)

SELECT
    customer,
    sale_date,
    seller
FROM min_date
ORDER BY customer_id;
-- Автор: Константин Игнатенко
-- Email: grundigk@gmail.com
-- Описание: Отчет список покупателей совершивших первую покупку 
-- с нулевой ценой(такая акция) когда и у какого продавца
-- Проект: Продажи
-- Файл результат: special_offer.csv
-- Задание: 6
-- Ссылка: https://ru.hexlet.io/projects/92/members/50321?step=6