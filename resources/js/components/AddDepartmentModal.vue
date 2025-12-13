<template>
    <el-dialog
        v-model="visible"
        title="Добавление отдела"
        width="600px"
        @close="handleClose"
    >
        <el-form :model="form" :rules="rules" ref="formRef" label-width="140px">
            <el-form-item label="Название отдела" prop="name">
                <el-input v-model="form.name" placeholder="Отдел продаж" style="width: 100%" />
            </el-form-item>
            <el-form-item label="Мин. % бонуса" prop="min_percent">
                <el-input-number
                    v-model="form.min_percent"
                    :min="0"
                    :max="100"
                    :precision="2"
                    :step="0.1"
                    style="width: 100%"
                />
            </el-form-item>
            <el-form-item label="Макс. % бонуса" prop="max_percent">
                <el-input-number
                    v-model="form.max_percent"
                    :min="0"
                    :max="100"
                    :precision="2"
                    :step="0.1"
                    style="width: 100%"
                />
            </el-form-item>
        </el-form>
        <template #footer>
            <div class="dialog-footer">
                <el-button @click="handleClose">Отмена</el-button>
                <el-button type="primary" @click="handleSubmit" :loading="loading">
                    Добавить
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
import { ref, reactive, watch } from 'vue';
import { useDepartmentsStore } from '../stores/departments';
import { useAlert } from '../composables/useAlert';

const props = defineProps({
    modelValue: Boolean,
});

const emit = defineEmits(['update:modelValue', 'success']);

const departmentsStore = useDepartmentsStore();
const { callAlert } = useAlert();

const visible = ref(false);
const loading = ref(false);
const formRef = ref(null);

const form = reactive({
    name: '',
    min_percent: 1.2,
    max_percent: 4.0,
});

const rules = {
    name: [
        { required: true, message: 'Введите название отдела', trigger: 'blur' },
    ],
    min_percent: [
        { required: true, message: 'Введите минимальный процент', trigger: 'blur' },
    ],
    max_percent: [
        { required: true, message: 'Введите максимальный процент', trigger: 'blur' },
        {
            validator: (rule, value, callback) => {
                if (value <= form.min_percent) {
                    callback(new Error('Максимальный процент должен быть больше минимального'));
                } else {
                    callback();
                }
            },
            trigger: 'blur',
        },
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

const handleClose = () => {
    visible.value = false;
    form.name = '';
    form.min_percent = 1.2;
    form.max_percent = 4.0;
    formRef.value?.resetFields();
};

const handleSubmit = async () => {
    if (!formRef.value) return;
    
    await formRef.value.validate(async (valid) => {
        if (valid) {
            loading.value = true;
            try {
                await departmentsStore.createDepartment({
                    name: form.name,
                    min_percent: form.min_percent,
                    max_percent: form.max_percent,
                });
                callAlert('success', `Отдел "${form.name}" успешно создан`);
                emit('success');
                handleClose();
            } catch (error) {
                const message = error.message || 'Ошибка при создании отдела';
                callAlert('danger', message);
            } finally {
                loading.value = false;
            }
        }
    });
};
</script>

