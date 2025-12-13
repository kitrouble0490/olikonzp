<template>
    <div class="login-container">
        <el-card class="login-card">
            <template #header>
                <div class="login-header">
                    <h2>OLIKON-ЗП</h2>
                    <p>Вход в систему</p>
                </div>
            </template>
            
            <el-form
                :model="form"
                :rules="rules"
                ref="formRef"
                @submit.prevent="handleLogin"
            >
                <el-form-item prop="login">
                    <el-input
                        v-model="form.login"
                        placeholder="Логин"
                        size="large"
                        :prefix-icon="User"
                        :disabled="loading"
                    />
                </el-form-item>
                
                <el-form-item prop="password">
                    <el-input
                        v-model="form.password"
                        type="password"
                        placeholder="Пароль"
                        size="large"
                        :prefix-icon="Lock"
                        :disabled="loading"
                        @keyup.enter="handleLogin"
                        show-password
                    />
                </el-form-item>
                
                <el-form-item>
                    <el-button
                        type="primary"
                        size="large"
                        style="width: 100%"
                        :loading="loading"
                        @click="handleLogin"
                    >
                        Войти
                    </el-button>
                </el-form-item>
            </el-form>
            
            <el-alert
                v-if="error"
                :title="error"
                type="error"
                :closable="false"
                style="margin-top: 15px"
            />
        </el-card>
    </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { User, Lock } from '@element-plus/icons-vue';
import { useAuthStore } from '../stores/auth';

const authStore = useAuthStore();

const formRef = ref(null);
const loading = ref(false);
const error = ref('');

const form = reactive({
    login: '',
    password: '',
});

const rules = {
    login: [
        { required: true, message: 'Введите логин', trigger: 'blur' },
    ],
    password: [
        { required: true, message: 'Введите пароль', trigger: 'blur' },
    ],
};

const handleLogin = async () => {
    if (!formRef.value) return;
    
    error.value = '';
    
    await formRef.value.validate(async (valid) => {
        if (valid) {
            loading.value = true;
            try {
                await authStore.login(form.login, form.password);
                // Успешный вход - компонент закроется автоматически через проверку в App.vue
            } catch (err) {
                error.value = err.response?.data?.message || err.message || 'Ошибка при входе в систему';
            } finally {
                loading.value = false;
            }
        }
    });
};
</script>

<style scoped>
.login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    background: linear-gradient(135deg, #1a5e73 0%, #2d7a94 100%);
    padding: 20px;
}

.login-card {
    width: 100%;
    max-width: 400px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.login-header {
    text-align: center;
    color: #1a5e73;
}

.login-header h2 {
    margin: 0 0 10px 0;
    font-size: 28px;
    font-weight: bold;
}

.login-header p {
    margin: 0;
    color: #666;
    font-size: 14px;
}
</style>
