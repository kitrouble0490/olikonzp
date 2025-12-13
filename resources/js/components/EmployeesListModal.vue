<template>
    <el-dialog
        v-model="visible"
        title="Список сотрудников"
        width="700px"
        @close="handleClose"
    >
        <el-table :data="employees" style="width: 100%" v-loading="loading">
            <el-table-column prop="surname" label="Фамилия" width="150" />
            <el-table-column prop="name" label="Имя" width="150" />
            <el-table-column prop="department.name" label="Отдел" />
            <el-table-column label="Действия" width="100" align="right">
                <template #default="{ row }">
                    <el-button
                        type="danger"
                        :icon="Delete"
                        circle
                        @click="handleDelete(row)"
                    />
                </template>
            </el-table-column>
        </el-table>
        <template #footer>
            <div class="dialog-footer">
                <el-button @click="handleClose">Закрыть</el-button>
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
import { ref, watch, computed } from 'vue';
import { Delete } from '@element-plus/icons-vue';
import { useEmployeesStore } from '../stores/employees';
import { useAlert } from '../composables/useAlert';
import { ElMessageBox } from 'element-plus';

const props = defineProps({
    modelValue: Boolean,
});

const emit = defineEmits(['update:modelValue']);

const employeesStore = useEmployeesStore();
const { callAlert } = useAlert();

const visible = ref(false);
const loading = computed(() => employeesStore.loading);

const employees = computed(() => employeesStore.employees);

watch(() => props.modelValue, (val) => {
    visible.value = val;
    if (val) {
        employeesStore.fetchEmployees();
    }
});

watch(visible, (val) => {
    if (!val) {
        emit('update:modelValue', false);
    }
});

const handleClose = () => {
    visible.value = false;
};

const handleDelete = async (employee) => {
    try {
        await ElMessageBox.confirm(
            `Удалить сотрудника ${employee.surname} ${employee.name}?`,
            'Подтверждение удаления',
            {
                confirmButtonText: 'Удалить',
                cancelButtonText: 'Отмена',
                type: 'warning',
            }
        );
        
        await employeesStore.deleteEmployee(employee.id);
        callAlert('success', 'Сотрудник удален');
    } catch (error) {
        if (error !== 'cancel') {
            callAlert('danger', 'Ошибка при удалении сотрудника');
        }
    }
};
</script>

