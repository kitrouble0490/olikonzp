<template>
    <el-dialog
        v-model="visible"
        title="Добавление новой страницы"
        width="400px"
        @close="handleClose"
        :close-on-click-modal="false"
    >
        <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
            <el-form-item label="Название" prop="title">
                <el-input v-model="form.title" placeholder="Например: 2024" />
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
import { usePagesStore } from '../stores/pages';
import { useAlert } from '../composables/useAlert';

const props = defineProps({
    modelValue: Boolean,
});

const emit = defineEmits(['update:modelValue', 'success']);

const pagesStore = usePagesStore();
const { callAlert } = useAlert();

const visible = ref(false);
const loading = ref(false);
const formRef = ref(null);

const form = reactive({
    title: '',
});

const rules = {
    title: [
        { required: true, message: 'Введите название страницы', trigger: 'blur' },
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
    form.title = '';
    formRef.value?.resetFields();
};

const handleSubmit = async () => {
    if (!formRef.value) return;
    
    await formRef.value.validate(async (valid) => {
        if (valid) {
            loading.value = true;
            try {
                await pagesStore.createPage({ title: form.title });
                callAlert('success', `Страница "${form.title}" успешно создана`);
                emit('success');
                handleClose();
            } catch (error) {
                const message = error.message || 'Ошибка при создании страницы';
                callAlert('danger', message);
            } finally {
                loading.value = false;
            }
        }
    });
};
</script>

