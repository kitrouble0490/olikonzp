# Этап 3: Backend (Laravel API) ✅

## Выполнено

### 1. Созданы модели Eloquent ✅
- `Page` - Страницы (годы)
- `Department` - Отделы
- `Employee` - Сотрудники
- `Period` - Расчетные периоды (месяцы)
- `PeriodDepartment` - Связь периодов с отделами
- `PeriodItem` - Дни периода
- `ItemEmployee` - Связь дней с сотрудниками

### 2. Настроены отношения между моделями ✅
- `Page` → `hasMany(Period)`
- `Period` → `belongsTo(Page)`, `hasMany(PeriodDepartment)`
- `Department` → `hasMany(Employee)`, `hasMany(PeriodDepartment)`
- `Employee` → `belongsTo(Department)`, `belongsToMany(PeriodItem)`
- `PeriodDepartment` → `belongsTo(Period)`, `belongsTo(Department)`, `hasMany(PeriodItem)`
- `PeriodItem` → `belongsTo(PeriodDepartment)`, `belongsToMany(Employee)`

### 3. Созданы API контроллеры ✅

#### PageController
- `GET /api/pages` - Список страниц
- `POST /api/pages` - Создать страницу
- `GET /api/pages/{id}` - Получить страницу с периодами
- `PUT /api/pages/{id}` - Обновить страницу
- `DELETE /api/pages/{id}` - Удалить страницу

#### DepartmentController
- `GET /api/departments` - Список отделов
- `POST /api/departments` - Создать отдел
- `GET /api/departments/{id}` - Получить отдел
- `PUT /api/departments/{id}` - Обновить отдел
- `DELETE /api/departments/{id}` - Удалить отдел

#### EmployeeController
- `GET /api/employees` - Список сотрудников
- `POST /api/employees` - Создать сотрудника
- `GET /api/employees/{id}` - Получить сотрудника
- `PUT /api/employees/{id}` - Обновить сотрудника
- `DELETE /api/employees/{id}` - Удалить сотрудника

#### PeriodController
- `GET /api/periods` - Список периодов
- `POST /api/periods` - Создать период (месяц)
- `GET /api/periods/{id}` - Получить период
- `PUT /api/periods/{id}` - Обновить период
- `DELETE /api/periods/{id}` - Удалить период
- `GET /api/periods/months/list` - Список месяцев

#### PeriodDepartmentController
- `POST /api/period-departments` - Добавить отдел в период
- `PUT /api/period-departments/{id}` - Обновить период-отдел
- `DELETE /api/period-departments/{id}` - Удалить отдел из периода

#### PeriodItemController
- `PUT /api/period-items/{id}` - Обновить день (план, факт, процент)
- `POST /api/period-items/{id}/toggle-employee` - Добавить/удалить сотрудника из дня

### 4. Реализована бизнес-логика расчетов ✅

#### Автоматический расчет процента
- Если `plan - 1000 > fact` → используется `min_percent`
- Иначе → используется `max_percent`

#### Расчет зарплаты за день
```php
zp = ((fact / 100) * percent) / количество_сотрудников
```

#### Автоматические пересчеты
- При обновлении `fact` → пересчитывается `percent` (если не указан вручную)
- При обновлении `fact` или `percent` → пересчитывается `zp`
- При изменении сотрудников в дне → пересчитывается `zp`
- При обновлении дня → пересчитывается `fact_summ` в `PeriodDepartment`

### 5. Настроена валидация данных ✅
- Валидация всех входных данных
- Проверка уникальности (страницы, отделы)
- Проверка существования связей (foreign keys)
- Проверка диапазонов значений

### 6. Настроены API маршруты ✅
Все маршруты зарегистрированы в `routes/api.php` и доступны по префиксу `/api/`

## Примеры использования API

### Создать страницу
```bash
POST /api/pages
{
  "title": "2024"
}
```

### Создать отдел
```bash
POST /api/departments
{
  "name": "Отдел продаж",
  "min_percent": 1.2,
  "max_percent": 4.0
}
```

### Создать сотрудника
```bash
POST /api/employees
{
  "name": "Иван",
  "surname": "Иванов",
  "department_id": 1
}
```

### Создать период
```bash
POST /api/periods
{
  "page_id": 1,
  "number": 1,
  "days": 31
}
```

### Добавить отдел в период
```bash
POST /api/period-departments
{
  "period_id": 1,
  "department_id": 1,
  "plan_summ": 100000
}
```

### Обновить день периода
```bash
PUT /api/period-items/1
{
  "fact": 5000
}
```

### Добавить сотрудника в день
```bash
POST /api/period-items/1/toggle-employee
{
  "employee_id": 1
}
```

## Следующий этап

**Этап 4: Frontend (Vue 3 + Pinia)**
- Создание Pinia stores
- Интеграция с API
- Миграция логики из старого приложения
- Обновление компонентов Vue 3

