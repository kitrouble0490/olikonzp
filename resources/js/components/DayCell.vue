<template>
    <div class="day-cell">
        <div class="day-plan-emoji">{{ getPlanEmoji }}</div>
        <div class="day-plan">{{ periodItem?.plan || 0 }} р.</div>
        <div class="input-wrapper">
            <el-input
                :model-value="localFact"
                type="number"
                size="small"
                style="width: 100%"
                :disabled="isAnyLoading"
                @update:model-value="handleFactChange"
            />
            <el-icon v-if="loadingFact" class="loading-icon">
                <Loading />
            </el-icon>
        </div>
        <div class="day-diff">
            <el-tag
                v-if="localFact && periodItem?.plan && localFact - periodItem.plan < 0"
                type="warning"
                size="small"
            >
                {{ differenceSumm(localFact, periodItem.plan) }} р.
            </el-tag>
            <el-tag
                v-else-if="localFact && periodItem?.plan && localFact - periodItem.plan > 0"
                type="success"
                size="small"
            >
                {{ differenceSumm(localFact, periodItem.plan) }} р.
            </el-tag>
            <el-tag 
                v-else
                type="info"
                size="small"
            >
                 Нет
            </el-tag>
        </div>
        <div class="input-wrapper">
            <el-input
                :model-value="localPercent"
                type="number"
                size="small"
                style="width: 100%"
                :disabled="isAnyLoading"
                @update:model-value="handlePercentChange"
            />
            <el-icon v-if="loadingPercent" class="loading-icon">
                <Loading />
            </el-icon>
        </div>
        <div v-if="employees && employees.length > 0" class="day-employees">
            <el-checkbox
                v-for="emp in employees"
                :key="emp.id"
                :model-value="checkEmployeeInItem(emp.id)"
                @change="() => $emit('toggle-employee', emp.id)"
                size="small"
            >
            <span v-if="periodItem?.employees && periodItem.employees.length > 0 && checkEmployeeInItem(emp.id)">{{ periodItem.zp }} р.</span>
            <span v-else>0 р.</span>
            </el-checkbox>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import { Loading } from '@element-plus/icons-vue';

const props = defineProps({
    periodItem: {
        type: Object,
        default: () => ({
            fact: null,
            plan: 0,
            percent: 0,
            zp: 0,
            employees: [],
        }),
    },
    employees: {
        type: Array,
        default: () => [],
    },
    department: {
        type: Object,
        default: null,
    },
    loadingFact: {
        type: Boolean,
        default: false,
    },
    loadingPercent: {
        type: Boolean,
        default: false,
    },
});

const emit = defineEmits(['update:fact', 'update:percent', 'toggle-employee']);

// Локальное состояние для мгновенного отображения
const localFact = ref(props.periodItem?.fact ?? null);
const localPercent = ref(props.periodItem?.percent ?? 0);

// Синхронизация с props при изменении periodItem
watch(() => props.periodItem?.fact, (newValue) => {
    if (newValue !== localFact.value) {
        localFact.value = newValue;
    }
}, { immediate: true });

watch(() => props.periodItem?.percent, (newValue) => {
    if (newValue !== localPercent.value) {
        localPercent.value = newValue ?? 0;
    }
}, { immediate: true });

// Флаг для отслеживания ручного редактирования процента
const isPercentManual = ref(false);

const isAnyLoading = computed(() => props.loadingFact || props.loadingPercent);

const differenceSumm = (arg1, arg2) => {
    const diff = arg1 - arg2;
    return diff.toFixed(1);
};

const checkEmployeeInItem = (employeeId) => {
    return props.periodItem?.employees?.some(e => e.id === employeeId) || false;
};

const getPlanEmoji = computed(() => {
    const plan = props.periodItem?.plan || 0;
    const fact = localFact.value;
    
    // Если факт не указан, показываем нейтральный
    if (fact === null || fact === undefined || fact === 0) {
        return '😐';
    }
    
    // Если план равен нулю, показываем нейтральный
    if (plan === 0) {
        return '😐';
    }
    
    // Вычисляем процент разницы
    const diffPercent = ((fact - plan) / plan) * 100;
    
    // Если факт меньше плана на 50% или больше - злой смайлик
    if (diffPercent <= -50) {
        return '😠';
    }
    
    // Если факт больше плана на 50% или больше - позитивный смайлик
    if (diffPercent >= 50) {
        return '😊';
    }
    
    // В промежутке - нейтральный
    return '😐';
});

// Автоматический расчет процента на основе разницы факта и плана
const calculatePercent = (fact, plan) => {
    if (!props.department || fact === null || fact === undefined || plan === null || plan === undefined) {
        return localPercent.value || 0;
    }
    
    const diff = fact - plan;
    if (diff > 0) {
        // Если факт больше плана - используем max_percent
        return props.department.max_percent || 0;
    } else {
        // Если факт меньше или равен плану - используем min_percent
        return props.department.min_percent || 0;
    }
};

const handleFactChange = (value) => {
    // Преобразуем значение в число или null
    const numValue = value === '' || value === null || value === undefined || isNaN(value) ? null : Number(value);
    localFact.value = numValue;
    
    // Автоматически рассчитываем процент при изменении факта
    // только если процент не был изменен вручную
    if (!isPercentManual.value && props.department && props.periodItem?.plan !== null && props.periodItem?.plan !== undefined && numValue !== null) {
        const calculatedPercent = calculatePercent(numValue, props.periodItem.plan);
        if (calculatedPercent !== localPercent.value) {
            localPercent.value = calculatedPercent;
            emit('update:percent', calculatedPercent);
        }
    }
    
    // Эмитим событие для сохранения (debounce будет в родительском компоненте)
    emit('update:fact', numValue);
};

const handlePercentChange = (value) => {
    // Преобразуем значение в число или 0
    const numValue = value === '' || value === null || value === undefined || isNaN(value) ? 0 : Number(value);
    localPercent.value = numValue;
    // Помечаем, что процент был изменен вручную
    isPercentManual.value = true;
    
    // Эмитим событие для сохранения (debounce будет в родительском компоненте)
    emit('update:percent', numValue);
    
    // Сбрасываем флаг через 3 секунды, чтобы при следующем изменении fact
    // процент снова рассчитывался автоматически
    setTimeout(() => {
        isPercentManual.value = false;
    }, 3000);
};
</script>

<style scoped>
.day-cell {
    padding: 5px;
}

.day-plan {
    font-size: 11px;
    color: #666;
    margin-bottom: 5px;
}

.day-plan-emoji {
    font-size: 14px;
    margin-bottom: 5px;
}

.input-wrapper {
    position: relative;
    width: 100%;
}

.loading-icon {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    color: #409eff;
    animation: rotating 1s linear infinite;
}

@keyframes rotating {
    from {
        transform: translateY(-50%) rotate(0deg);
    }
    to {
        transform: translateY(-50%) rotate(360deg);
    }
}

.day-diff {
    margin: 5px 0;
}

.day-employees {
    margin-top: 21px;
    font-size: 11px;
    display: flex;
    flex-flow: column nowrap;
    gap: 3px;
}

.day-employees .el-checkbox {
    display: flex;
    align-items: center;
}
</style>

