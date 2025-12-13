# Схема базы данных OLIKON-ЗП

## Структура таблиц

### 1. `pages` - Страницы (годы)
Хранит страницы/годы для работы с расчетными периодами.

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| title | string | Название страницы (например, "2023") - уникальное |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

### 2. `departments` - Отделы
Хранит информацию об отделах компании.

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| name | string | Название отдела - уникальное |
| min_percent | decimal(5,2) | Минимальный процент бонуса (по умолчанию 1.2) |
| max_percent | decimal(5,2) | Максимальный процент бонуса (по умолчанию 4.0) |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

### 3. `employees` - Сотрудники
Хранит информацию о сотрудниках.

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| name | string | Имя сотрудника |
| surname | string | Фамилия сотрудника |
| department_id | bigint | Внешний ключ на `departments.id` (CASCADE DELETE) |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

### 4. `periods` - Расчетные периоды (месяцы)
Хранит расчетные периоды (месяцы) для каждой страницы.

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| page_id | bigint | Внешний ключ на `pages.id` (CASCADE DELETE) |
| number | tinyint | Номер месяца (1-12) |
| name | string | Название месяца (Январь, Февраль и т.д.) |
| days | tinyint | Количество дней в месяце |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

**Уникальный индекс:** `(page_id, number)` - один месяц на страницу

### 5. `period_departments` - Связь периодов с отделами
Связывает расчетные периоды с отделами и хранит суммы.

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| period_id | bigint | Внешний ключ на `periods.id` (CASCADE DELETE) |
| department_id | bigint | Внешний ключ на `departments.id` (CASCADE DELETE) |
| plan_summ | decimal(10,2) | Плановая сумма (по умолчанию 0) |
| fact_summ | decimal(10,2) | Фактическая сумма (по умолчанию 0) |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

**Уникальный индекс:** `(period_id, department_id)` - один отдел в периоде

### 6. `period_items` - Дни периода
Хранит данные по каждому дню расчетного периода для отдела.

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| period_department_id | bigint | Внешний ключ на `period_departments.id` (CASCADE DELETE) |
| number | tinyint | Номер дня (1-31) |
| plan | decimal(10,2) | План на день (по умолчанию 0) |
| fact | decimal(10,2) | Факт на день (nullable) |
| percent | decimal(5,2) | Процент бонуса (по умолчанию 0) |
| zp | decimal(10,2) | Зарплата за день (по умолчанию 0) |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

**Уникальный индекс:** `(period_department_id, number)` - один день в периоде-отделе

### 7. `item_employees` - Связь дней с сотрудниками
Связывает дни периода с сотрудниками (многие ко многим).

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| period_item_id | bigint | Внешний ключ на `period_items.id` (CASCADE DELETE) |
| employee_id | bigint | Внешний ключ на `employees.id` (CASCADE DELETE) |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

**Уникальный индекс:** `(period_item_id, employee_id)` - один сотрудник на день

## Связи между таблицами

```
pages (1) ──< (N) periods
  │
  └── periods (1) ──< (N) period_departments
                      │
                      ├── (N) departments (1) ──< (N) employees
                      │
                      └── (1) ──< (N) period_items
                                   │
                                   └── (N) ──< (N) item_employees ──> (N) employees
```

## Логика работы

1. **Страница (Page)** - представляет год работы (например, "2023")
2. **Период (Period)** - месяц в рамках страницы (Январь, Февраль и т.д.)
3. **Отдел в периоде (PeriodDepartment)** - отдел, участвующий в расчетном периоде
4. **День периода (PeriodItem)** - конкретный день месяца с планом и фактом
5. **Сотрудники на день (ItemEmployee)** - сотрудники, работавшие в конкретный день

## Расчеты

- `fact_summ` в `period_departments` вычисляется как сумма всех `fact` из `period_items`
- `zp` в `period_items` рассчитывается: `((fact / 100) * percent) / количество_сотрудников`
- Процент (`percent`) определяется автоматически на основе сравнения `plan` и `fact`:
  - Если `plan - 1000 > fact` → `min_percent`
  - Иначе → `max_percent`

