<template>
    <el-dialog
        v-model="visible"
        :title="editMode ? 'Выбор отдела для периода' : 'Список отделов'"
        width="700px"
        @close="handleClose"
    >
        <el-table :data="departments" style="width: 100%" v-loading="loading">
            <el-table-column prop="name" label="Название" min-width="150" />
            <el-table-column label="Минимальный %" min-width="150">
                <template #default="{ row }">
                    <el-input-number
                        v-model="row.min_percent"
                        :min="0"
                        :max="100"
                        :precision="2"
                        :step="0.1"
                        size="small"
                        style="width: 100%"
                        @change="handleUpdatePercent(row)"
                    />
                </template>
            </el-table-column>
            <el-table-column label="Максимальный %" min-width="150">
                <template #default="{ row }">
                    <el-input-number
                        v-model="row.max_percent"
                        :min="0"
                        :max="100"
                        :precision="2"
                        :step="0.1"
                        size="small"
                        style="width: 100%"
                        @change="handleUpdatePercent(row)"
                    />
                </template>
            </el-table-column>
            <el-table-column label="Действия" width="100" align="right" fixed="right">
                <template #default="{ row }">
                    <el-button
                        v-if="editMode"
                        type="primary"
                        :icon="Plus"
                        circle
                        @click="handleAddToPeriod(row)"
                    />
                    <el-button
                        v-else
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
import { Delete, Plus } from '@element-plus/icons-vue';
import { useDepartmentsStore } from '../stores/departments';
import { usePeriodDepartmentsStore } from '../stores/periodDepartments';
import { usePagesStore } from '../stores/pages';
import { useAlert } from '../composables/useAlert';
import { ElMessageBox } from 'element-plus';

const props = defineProps({
    modelValue: Boolean,
    editMode: {
        type: Boolean,
        default: false,
    },
    period: {
        type: Object,
        default: null,
    },
});

const emit = defineEmits(['update:modelValue', 'department-added']);

const departmentsStore = useDepartmentsStore();
const periodDepartmentsStore = usePeriodDepartmentsStore();
const pagesStore = usePagesStore();
const { callAlert } = useAlert();

const visible = ref(false);
const loading = computed(() => departmentsStore.loading);

const departments = computed(() => departmentsStore.departments);

watch(() => props.modelValue, (val) => {
    visible.value = val;
    if (val) {
        departmentsStore.fetchDepartments();
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

const handleUpdatePercent = async (department) => {
    try {
        await departmentsStore.updateDepartment(department.id, {
            name: department.name,
            min_percent: department.min_percent,
            max_percent: department.max_percent,
        });
        callAlert('success', 'Проценты обновлены');
    } catch (error) {
        callAlert('danger', 'Ошибка при обновлении');
    }
};

const handleAddToPeriod = async (department) => {
    if (!props.period) return;
    
    try {
        await periodDepartmentsStore.createPeriodDepartment({
            period_id: props.period.id,
            department_id: department.id,
            plan_summ: 0,
        });
        
        // Перезагрузить страницу
        if (pagesStore.currentPage) {
            await pagesStore.fetchPage(pagesStore.currentPage.id);
        }
        
        callAlert('success', 'Отдел добавлен в период');
        emit('department-added');
    } catch (error) {
        const message = error.message || 'Ошибка при добавлении отдела';
        callAlert('danger', message);
    }
};

const handleDelete = async (department) => {
    try {
        await ElMessageBox.confirm(
            `Удалить отдел "${department.name}"?`,
            'Подтверждение удаления',
            {
                confirmButtonText: 'Удалить',
                cancelButtonText: 'Отмена',
                type: 'warning',
            }
        );
        
        await departmentsStore.deleteDepartment(department.id);
        callAlert('success', 'Отдел удален');
    } catch (error) {
        if (error !== 'cancel') {
            callAlert('danger', 'Ошибка при удалении отдела');
        }
    }
};
</script>

