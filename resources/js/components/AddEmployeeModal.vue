<template>
    <el-dialog
        v-model="visible"
        title="Добавление сотрудника"
        width="500px"
        @close="handleClose"
    >
        <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
            <el-form-item label="Имя" prop="name">
                <el-input v-model="form.name" placeholder="Иван" />
            </el-form-item>
            <el-form-item label="Фамилия" prop="surname">
                <el-input v-model="form.surname" placeholder="Иванов" />
            </el-form-item>
            <el-form-item label="Отдел" prop="department_id">
                <el-select
                    v-model="form.department_id"
                    placeholder="Выберите отдел"
                    style="width: 100%"
                >
                    <el-option
                        v-for="dept in departments"
                        :key="dept.id"
                        :label="dept.name"
                        :value="dept.id"
                    />
                </el-select>
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
import { ref, reactive, watch, computed } from 'vue';
import { useEmployeesStore } from '../stores/employees';
import { useDepartmentsStore } from '../stores/departments';
import { useAlert } from '../composables/useAlert';

const props = defineProps({
    modelValue: Boolean,
});

const emit = defineEmits(['update:modelValue', 'success']);

const employeesStore = useEmployeesStore();
const departmentsStore = useDepartmentsStore();
const { callAlert } = useAlert();

const visible = ref(false);
const loading = ref(false);
const formRef = ref(null);

const departments = computed(() => departmentsStore.departments);

const form = reactive({
    name: '',
    surname: '',
    department_id: null,
});

const rules = {
    name: [
        { required: true, message: 'Введите имя сотрудника', trigger: 'blur' },
    ],
    surname: [
        { required: true, message: 'Введите фамилию сотрудника', trigger: 'blur' },
    ],
    department_id: [
        { required: true, message: 'Выберите отдел', trigger: 'change' },
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
    form.surname = '';
    form.department_id = null;
    formRef.value?.resetFields();
};

const handleSubmit = async () => {
    if (!formRef.value) return;
    
    await formRef.value.validate(async (valid) => {
        if (valid) {
            loading.value = true;
            try {
                await employeesStore.createEmployee({
                    name: form.name,
                    surname: form.surname,
                    department_id: form.department_id,
                });
                callAlert('success', `Сотрудник ${form.surname} ${form.name} успешно добавлен`);
                emit('success');
                handleClose();
            } catch (error) {
                const message = error.message || 'Ошибка при создании сотрудника';
                callAlert('danger', message);
            } finally {
                loading.value = false;
            }
        }
    });
};
</script>

