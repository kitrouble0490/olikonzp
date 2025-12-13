<template>
    <div class="period-block">
        <el-card class="period-card">
            <template #header>
                <div class="period-header">
                    <span class="period-name">{{ period.name }}</span>
                    <div class="period-header-actions">
                        <el-button
                            type="primary"
                            size="small"
                            :icon="Plus"
                            @click="handleSelectDepartment"
                        >
                            Отдел
                        </el-button>
                        <el-button
                            v-if="isPeriodEmpty"
                            type="danger"
                            size="small"
                            :icon="Delete"
                            circle
                            @click="handleDeletePeriod"
                        />
                    </div>
                </div>
            </template>

            <div
                v-if="
                    period.period_departments &&
                    period.period_departments.length > 0
                "
                class="table-wrapper"
            >
                <el-table
                    :data="period.period_departments"
                    border
                    class="period-table"
                >
                    <el-table-column label="Отдел" width="200" fixed="left">
                        <template #default="{ row }">
                            <div class="department-header">
                                <strong>{{ row.department?.name }}</strong>
                                <el-button
                                    type="danger"
                                    :icon="Delete"
                                    size="small"
                                    circle
                                    @click="handleDeleteDepartment(row.id)"
                                />
                            </div>
                            <div class="department-info">
                                <div>
                                    План:
                                    <el-input-number
                                        v-model="row.plan_summ"
                                        :precision="2"
                                        :step="100"
                                        size="small"
                                        style="width: 120px"
                                        @change="handleUpdatePlanSumm(row)"
                                    />
                                </div>
                                <div>
                                    Факт:
                                    <strong>{{ row.fact_summ }} р.</strong>
                                </div>
                                <div>
                                    <el-tag
                                        v-if="
                                            row.fact_summ - row.plan_summ < 0
                                        "
                                        type="warning"
                                        size="small"
                                    >
                                        Не выполнение:
                                        {{
                                            (
                                                row.fact_summ - row.plan_summ
                                            ).toFixed(2)
                                        }}
                                        р.
                                    </el-tag>
                                    <el-tag
                                        v-else-if="
                                            row.fact_summ - row.plan_summ > 0
                                        "
                                        type="success"
                                        size="small"
                                    >
                                        Выполнение:
                                        {{
                                            (
                                                row.fact_summ - row.plan_summ
                                            ).toFixed(2)
                                        }}
                                        р.
                                    </el-tag>
                                    <el-tag
                                        v-else
                                        type="info"
                                        size="small"
                                    >
                                        Выполнение ---
                                    </el-tag>
                                </div>
                                <div>
                                    Бонус:
                                    <el-tag type="warning" size="small"
                                        >▼{{ row.department?.min_percent }}%</el-tag
                                    >
                                    <el-tag type="success" size="small"
                                        >▲{{ row.department?.max_percent }}%</el-tag
                                    >
                                </div>
                                <div
                                    v-if="
                                        row.department?.employees &&
                                        row.department.employees.length > 0
                                    "
                                    class="employees-list"
                                >
                                    <div
                                        v-for="emp in row.department.employees"
                                        :key="emp.id"
                                        class="employee-item"
                                    >
                                        {{ emp.surname }} {{ emp.name }}
                                        <el-tag type="info" size="small">
                                            {{ getEmployeeZp(row, emp.id) }} р.
                                        </el-tag>
                                    </div>
                                </div>
                            </div>
                        </template>
                    </el-table-column>

                    <el-table-column
                        v-for="item in getPeriodItems(
                            period.period_departments[0]
                        )"
                        :key="item.id"
                        :label="`День ${item.number}`"
                        width="120"
                        align="center"
                    >
                        <template #default="{ row }">
                            <DayCell
                                :period-item="getItemForDay(row, item.number)"
                                :employees="row.department?.employees || []"
                                :department="row.department"
                                :loading-fact="getLoadingState(row.id, item.number, 'fact')"
                                :loading-percent="getLoadingState(row.id, item.number, 'percent')"
                                @update:fact="
                                    (value) =>
                                        handleUpdateItemFact(row, item.number, value)
                                "
                                @update:percent="
                                    (value) =>
                                        handleUpdateItemPercent(
                                            row,
                                            item.number,
                                            value
                                        )
                                "
                                @toggle-employee="
                                    (empId) =>
                                        handleToggleEmployee(
                                            getItemForDay(row, item.number),
                                            empId
                                        )
                                "
                            />
                        </template>
                    </el-table-column>
                </el-table>
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { computed, ref } from 'vue';
import { Plus, Delete } from '@element-plus/icons-vue';
import { usePagesStore } from '../stores/pages';
import { usePeriodDepartmentsStore } from '../stores/periodDepartments';
import { usePeriodItemsStore } from '../stores/periodItems';
import { usePeriodsStore } from '../stores/periods';
import { useDebounce } from '../composables/useDebounce';
import { ElMessage, ElMessageBox } from 'element-plus';
import DayCell from './DayCell.vue';

const props = defineProps({
    period: {
        type: Object,
        required: true,
    },
});

const emit = defineEmits(['select-department', 'refresh']);

const pagesStore = usePagesStore();
const periodDepartmentsStore = usePeriodDepartmentsStore();
const periodItemsStore = usePeriodItemsStore();
const periodsStore = usePeriodsStore();

const currentPage = computed(() => pagesStore.currentPage);

// Проверка, пуст ли период (нет отделов)
const isPeriodEmpty = computed(() => {
    return !props.period.period_departments || props.period.period_departments.length === 0;
});

// Состояние загрузки для каждого поля каждого item
// Формат: { 'periodDepId_dayNumber_field': true/false }
const loadingStates = ref({});

// Methods
const getEmployeeZp = (periodDep, employeeId) => {
    if (!periodDep.period_items) return '0.00';
    const total = periodDep.period_items
        .filter(
            (item) =>
                item.employees &&
                item.employees.some((e) => e.id === employeeId)
        )
        .reduce((sum, item) => sum + parseFloat(item.zp || 0), 0);
    return total.toFixed(2);
};

const getPeriodItems = (periodDep) => {
    return periodDep?.period_items || [];
};

const getItemForDay = (periodDep, dayNumber) => {
    return (
        periodDep.period_items?.find((item) => item.number === dayNumber) || {
            id: null,
            fact: null,
            plan: 0,
            percent: 0,
            zp: 0,
            employees: [],
        }
    );
};

// Получение ключа для состояния загрузки
const getLoadingKey = (periodDepId, dayNumber, field) => {
    return `${periodDepId}_${dayNumber}_${field}`;
};

// Получение состояния загрузки
const getLoadingState = (periodDepId, dayNumber, field) => {
    const key = getLoadingKey(periodDepId, dayNumber, field);
    return loadingStates.value[key] || false;
};

// Установка состояния загрузки
const setLoadingState = (periodDepId, dayNumber, field, isLoading) => {
    const key = getLoadingKey(periodDepId, dayNumber, field);
    if (isLoading) {
        loadingStates.value[key] = true;
    } else {
        delete loadingStates.value[key];
    }
};

const updatePeriodItem = async (item, periodDepId, dayNumber, fieldsToUpdate) => {
    if (!item.id) return;
    
    // Устанавливаем состояние загрузки для всех обновляемых полей
    // Это происходит только когда начинается реальное сохранение (после debounce)
    fieldsToUpdate.forEach(field => {
        setLoadingState(periodDepId, dayNumber, field, true);
    });
    
    try {
        await periodItemsStore.updatePeriodItem(item.id, {
            fact: item.fact,
            percent: item.percent,
        });
        await refreshData();
    } catch (error) {
        ElMessage.error('Ошибка при обновлении дня');
    } finally {
        // Снимаем состояние загрузки
        fieldsToUpdate.forEach(field => {
            setLoadingState(periodDepId, dayNumber, field, false);
        });
    }
};

// Создаем debounced функции для каждого item отдельно
// Используем Map для хранения debounced функций для каждого item
const factDebounceMap = new Map();
const percentDebounceMap = new Map();

const getDebounceKey = (periodDepId, dayNumber) => {
    return `${periodDepId}_${dayNumber}`;
};

const updateItemFactInternal = async (row, dayNumber, value) => {
    const item = getItemForDay(row, dayNumber);
    item.fact = value;
    // Процент рассчитывается автоматически в DayCell
    if (item.id) {
        await updatePeriodItem(item, row.id, dayNumber, ['fact']);
    }
};

const updateItemPercentInternal = async (row, dayNumber, value) => {
    const item = getItemForDay(row, dayNumber);
    item.percent = value;
    if (item.id) {
        await updatePeriodItem(item, row.id, dayNumber, ['percent']);
    }
};

const handleUpdateItemFact = (row, dayNumber, value) => {
    // Обновляем локально сразу
    const item = getItemForDay(row, dayNumber);
    item.fact = value;
    
    // Получаем или создаем debounced функцию для этого item
    const key = getDebounceKey(row.id, dayNumber);
    if (!factDebounceMap.has(key)) {
        const { debouncedFn } = useDebounce(
            (r, d, v) => updateItemFactInternal(r, d, v),
            1500
        );
        factDebounceMap.set(key, debouncedFn);
    }
    
    // Сохраняем в базу с задержкой
    factDebounceMap.get(key)(row, dayNumber, value);
};

const handleUpdateItemPercent = (row, dayNumber, value) => {
    // Обновляем локально сразу
    const item = getItemForDay(row, dayNumber);
    item.percent = value;
    
    // Получаем или создаем debounced функцию для этого item
    const key = getDebounceKey(row.id, dayNumber);
    if (!percentDebounceMap.has(key)) {
        const { debouncedFn } = useDebounce(
            (r, d, v) => updateItemPercentInternal(r, d, v),
            1500
        );
        percentDebounceMap.set(key, debouncedFn);
    }
    
    // Сохраняем в базу с задержкой
    percentDebounceMap.get(key)(row, dayNumber, value);
};

const handleToggleEmployee = async (item, employeeId) => {
    if (!item.id) return;
    try {
        await periodItemsStore.toggleEmployee(item.id, employeeId);
        await refreshData();
    } catch (error) {
        ElMessage.error('Ошибка при изменении сотрудника');
    }
};

const updatePlanSummInternal = async (periodDep) => {
    try {
        await periodDepartmentsStore.updatePeriodDepartment(periodDep.id, {
            plan_summ: periodDep.plan_summ,
        });
        await refreshData();
        ElMessage.success('План обновлен');
    } catch (error) {
        ElMessage.error('Ошибка при обновлении плана');
    }
};

// Debounced версия с задержкой 3000ms
const { debouncedFn: debouncedUpdatePlanSumm } = useDebounce(
    updatePlanSummInternal,
    3000
);

const handleUpdatePlanSumm = (periodDep) => {
    debouncedUpdatePlanSumm(periodDep);
};

const handleSelectDepartment = () => {
    emit('select-department', props.period);
};

const handleDeletePeriod = async () => {
    // Проверяем, что период пуст
    if (!isPeriodEmpty.value) {
        ElMessage.warning('Нельзя удалить период, в котором есть отделы. Сначала удалите все отделы.');
        return;
    }
    
    try {
        await ElMessageBox.confirm(
            `Удалить период "${props.period.name}"?`,
            'Подтверждение удаления',
            {
                confirmButtonText: 'Удалить',
                cancelButtonText: 'Отмена',
                type: 'warning',
                confirmButtonClass: 'el-button--danger',
            }
        );
        
        await periodsStore.deletePeriod(props.period.id);
        await refreshData();
        ElMessage.success('Период удален');
    } catch (error) {
        if (error !== 'cancel') {
            ElMessage.error('Ошибка при удалении периода');
        }
    }
};

const handleDeleteDepartment = async (periodDepId) => {
    // Находим отдел для отображения названия в подтверждении
    const periodDep = props.period.period_departments?.find(pd => pd.id === periodDepId);
    const departmentName = periodDep?.department?.name || 'отдел';
    
    try {
        await ElMessageBox.confirm(
            `Удалить отдел "${departmentName}" из периода?`,
            'Подтверждение удаления',
            {
                confirmButtonText: 'Удалить',
                cancelButtonText: 'Отмена',
                type: 'warning',
                confirmButtonClass: 'el-button--danger',
            }
        );
        
        await periodDepartmentsStore.deletePeriodDepartment(periodDepId);
        await refreshData();
        ElMessage.success('Отдел удален из периода');
    } catch (error) {
        if (error !== 'cancel') {
            ElMessage.error('Ошибка при удалении отдела');
        }
    }
};

const refreshData = async () => {
    if (currentPage.value) {
        await pagesStore.fetchPage(currentPage.value.id);
        emit('refresh');
    }
};
</script>

<style scoped>
.period-block {
    margin-bottom: 20px;
}

.period-card {
    margin-bottom: 20px;
    width: 100%;
    max-width: 100%;
    overflow: hidden;
}

.period-card :deep(.el-card__body) {
    padding: 20px;
    overflow: visible;
}

.period-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.period-header-actions {
    display: flex;
    gap: 10px;
    align-items: center;
}

.period-name {
    font-size: 18px;
    font-weight: bold;
}

.department-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.department-info {
    font-size: 12px;
    margin-top: 10px;
}

.department-info > div {
    margin-bottom: 5px;
}

.employees-list {
    margin-top: 10px;
    padding-top: 10px;
    border-top: 1px solid #eee;
}

.employee-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 5px;
    font-size: 12px;
}

.table-wrapper {
    width: 100%;
    max-width: 100%;
    overflow-x: auto;
    overflow-y: visible;
    -webkit-overflow-scrolling: touch;
    position: relative;
}

.table-wrapper::-webkit-scrollbar {
    height: 8px;
}

.table-wrapper::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
}

.table-wrapper::-webkit-scrollbar-thumb {
    background: #888;
    border-radius: 4px;
}

.table-wrapper::-webkit-scrollbar-thumb:hover {
    background: #555;
}

/* Element Plus таблица для периодов */
.period-table {
    min-width: 800px;
    width: max-content;
}

.period-table :deep(.el-table__header-wrapper) {
    width: 100%;
}

.period-table :deep(.el-table__body-wrapper) {
    width: 100%;
}

.period-table :deep(.el-table__header) {
    width: 100%;
}

.period-table :deep(.el-table__body) {
    width: 100%;
}

.period-table :deep(table) {
    width: 100%;
    table-layout: fixed;
}

.period-table :deep(.el-table__header th),
.period-table :deep(.el-table__body td) {
    padding: 8px;
}
</style>

