<template>
    <el-dialog
        v-model="visible"
        title="Создание расчетного периода"
        width="500px"
        @close="handleClose"
    >
        <el-form :model="form" :rules="rules" ref="formRef" label-width="150px">
            <el-form-item label="Месяц" prop="number">
                <el-select
                    v-model="form.number"
                    placeholder="Выберите месяц"
                    style="width: 100%"
                    @change="handleMonthChange"
                >
                    <el-option
                        v-for="(month, num) in months"
                        :key="num"
                        :label="month.name"
                        :value="parseInt(num)"
                    />
                </el-select>
            </el-form-item>
            <el-form-item label="Количество дней" prop="days">
                <el-input-number
                    v-model="form.days"
                    :min="1"
                    :max="31"
                    style="width: 100%"
                />
            </el-form-item>
        </el-form>
        <template #footer>
            <div class="dialog-footer">
                <el-button @click="handleClose">Отмена</el-button>
                <el-button type="primary" @click="handleSubmit" :loading="loading">
                    Создать
                </el-button>
            </div>
        </template>
    </el-dialog>
</template>

<style scoped>
.dialog-footer {
    display: flex !important;
    justify-content: flex-end !important;
    gap: 10px;
    position: static !important;
    background-color: transparent !important;
    width: auto !important;
    height: auto !important;
    bottom: auto !important;
}
</style>

<script setup>
import { ref, reactive, watch, computed } from 'vue';
import { usePeriodsStore } from '../stores/periods';
import { usePagesStore } from '../stores/pages';
import { useAlert } from '../composables/useAlert';

const props = defineProps({
    modelValue: Boolean,
});

const emit = defineEmits(['update:modelValue', 'success']);

const periodsStore = usePeriodsStore();
const pagesStore = usePagesStore();
const { callAlert } = useAlert();

const visible = ref(false);
const loading = ref(false);
const formRef = ref(null);

const months = computed(() => periodsStore.months);
const currentPage = computed(() => pagesStore.currentPage);

const form = reactive({
    number: null,
    days: 31,
});

const rules = {
    number: [
        { required: true, message: 'Выберите месяц', trigger: 'change' },
    ],
    days: [
        { required: true, message: 'Введите количество дней', trigger: 'blur' },
    ],
};

watch(() => props.modelValue, (val) => {
    visible.value = val;
});

watch(visible, (val) => {
    if (!val) {
        emit('update:modelValue', false);
    }
});

const handleMonthChange = (monthNumber) => {
    if (months.value[monthNumber]) {
        form.days = months.value[monthNumber].days;
    }
};

const handleClose = () => {
    visible.value = false;
    form.number = null;
    form.days = 31;
    formRef.value?.resetFields();
};

const handleSubmit = async () => {
    if (!formRef.value || !currentPage.value) return;
    
    await formRef.value.validate(async (valid) => {
        if (valid) {
            loading.value = true;
            try {
                await periodsStore.createPeriod({
                    page_id: currentPage.value.id,
                    number: form.number,
                    days: form.days,
                });
                // Перезагрузить страницу для обновления данных
                await pagesStore.fetchPage(currentPage.value.id);
                callAlert('success', 'Период успешно создан');
                emit('success');
                handleClose();
            } catch (error) {
                const message = error.message || 'Ошибка при создании периода';
                callAlert('danger', message);
            } finally {
                loading.value = false;
            }
        }
    });
};
</script>

