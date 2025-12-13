<template>
    <div id="app">
        <!-- Страница авторизации -->
        <Login v-if="!authStore.isAuthenticated && !checkingAuth" />
        
        <!-- Основное приложение -->
        <el-container v-else-if="authStore.isAuthenticated">
            <el-header class="app-header">
                <div class="header-content">
                    <div class="header-title">OLIKON-ЗП</div>
                    <div class="header-actions">
                        <el-button type="primary" :icon="Plus" @click="viewAddPage = true">
                            Страницу
                        </el-button>
                        <el-button type="primary" :icon="Plus" @click="viewAddDepartment = true">
                            Отдел
                        </el-button>
                        <el-button v-if="departmentsStore.departments.length > 0" type="primary" :icon="Plus"
                            @click="viewAddEmployer = true">
                            Сотрудника
                        </el-button>
                        <el-button type="danger" @click="handleLogout">
                            Выход
                        </el-button>
                    </div>
                </div>
            </el-header>

            <el-main class="app-main">
                <el-card class="main-card">
                    <template #header>
                        <div class="card-header">
                            <div class="header-buttons">
                                <el-button v-show="pagesStore.pages &&
                                    pagesStore.pages.length > 0
                                    " :icon="Calendar" @click="createPeriod" title="Создать расчетный период">
                                    Создать период
                                </el-button>
                                <el-button :icon="User" @click="viewEmployeesList = true" title="Список сотрудников">
                                    Сотрудники
                                </el-button>
                                <el-button :icon="OfficeBuilding" @click="viewDepartmentList = true"
                                    title="Список отделов">
                                    Отделы
                                </el-button>
                            </div>
                            <div v-if="currentPage" class="current-page">
                                <el-tag type="info" size="large">Страница: {{ currentPage.title }}</el-tag>
                            </div>
                        </div>
                    </template>

                    <div v-if="!currentPage" class="empty-state">
                        <el-empty description="Не выбрана страница для работы!" />
                    </div>

                    <div v-if="
                        currentPage &&
                        currentPage.periods &&
                        currentPage.periods.length > 0
                    ">
                        <PeriodBlock
                            v-for="period in currentPage.periods"
                            :key="period.id"
                            :period="period"
                            @select-department="selectDepartmentForPeriod"
                            @refresh="handlePeriodRefresh"
                        />
                    </div>
                </el-card>
            </el-main>

            <el-footer class="app-footer">
                <div class="footer-content">
                    <el-scrollbar>
                        <div class="footer-buttons">
                            <el-button v-for="page in pagesStore.pages" :key="page.id" :type="currentPage?.id === page.id
                                    ? 'primary'
                                    : 'default'
                                " @click="selectPage(page.id)">
                                {{ page.title }}
                            </el-button>
                        </div>
                    </el-scrollbar>
                </div>
            </el-footer>
        </el-container>
        
        <!-- Модальные окна -->
        <AddPageModal v-model="viewAddPage" @success="handlePageAdded" />
        <AddDepartmentModal v-model="viewAddDepartment" @success="handleDepartmentAdded" />
        <AddEmployeeModal v-model="viewAddEmployer" @success="handleEmployeeAdded" />
        <AddPeriodModal v-model="viewAddGroup" @success="handlePeriodAdded" />
        <EmployeesListModal v-model="viewEmployeesList" />
        <DepartmentsListModal v-model="viewDepartmentList" :edit-mode="!!editObj" :period="editObj"
            @department-added="handleDepartmentAddedToPeriod" />
    </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from "vue";
import { ElMessage } from "element-plus";
import {
    Plus,
    Calendar,
    User,
    OfficeBuilding,
} from "@element-plus/icons-vue";
import { usePagesStore } from "./stores/pages";
import { useDepartmentsStore } from "./stores/departments";
import { useEmployeesStore } from "./stores/employees";
import { usePeriodsStore } from "./stores/periods";
import { useAuthStore } from "./stores/auth";
import AddPageModal from "./components/AddPageModal.vue";
import AddDepartmentModal from "./components/AddDepartmentModal.vue";
import AddEmployeeModal from "./components/AddEmployeeModal.vue";
import AddPeriodModal from "./components/AddPeriodModal.vue";
import EmployeesListModal from "./components/EmployeesListModal.vue";
import DepartmentsListModal from "./components/DepartmentsListModal.vue";
import PeriodBlock from "./components/PeriodBlock.vue";
import Login from "./components/Login.vue";

// Stores
const pagesStore = usePagesStore();
const departmentsStore = useDepartmentsStore();
const employeesStore = useEmployeesStore();
const periodsStore = usePeriodsStore();
const authStore = useAuthStore();

// Состояние проверки авторизации
const checkingAuth = ref(true);

// Функция загрузки данных приложения
const loadAppData = async () => {
    try {
        await Promise.all([
            pagesStore.fetchPages(),
            departmentsStore.fetchDepartments(),
            employeesStore.fetchEmployees(),
            periodsStore.fetchMonths(),
        ]);

        if (pagesStore.pages.length > 0) {
            await selectPage(pagesStore.pages[0].id);
        }
    } catch (error) {
        ElMessage.error("Ошибка при загрузке данных");
    }
};

// Отслеживаем изменение состояния авторизации
watch(() => authStore.isAuthenticated, async (isAuthenticated) => {
    if (isAuthenticated && !checkingAuth.value) {
        // Если пользователь авторизовался, загружаем данные
        await loadAppData();
    }
});

// UI State
const viewAddPage = ref(false);
const viewAddGroup = ref(false);
const viewAddEmployer = ref(false);
const viewAddDepartment = ref(false);
const viewEmployeesList = ref(false);
const viewDepartmentList = ref(false);
const editObj = ref(null);

// Computed
const currentPage = computed(() => pagesStore.currentPage);

// Methods
const differenceSumm = (arg1, arg2) => {
    const diff = arg1 - arg2;
    return diff.toFixed(1);
};


const selectPage = async (pageId) => {
    try {
        await pagesStore.fetchPage(pageId);
        ElMessage.success("Страница загружена");
    } catch (error) {
        ElMessage.error("Ошибка при загрузке страницы");
    }
};

const createPeriod = () => {
    if (!currentPage.value) {
        ElMessage.warning("Выберите страницу для добавления РП");
        return;
    }
    viewAddGroup.value = true;
};


const selectDepartmentForPeriod = (period) => {
    editObj.value = period;
    viewDepartmentList.value = true;
};

const handlePeriodRefresh = async () => {
    if (currentPage.value) {
        await pagesStore.fetchPage(currentPage.value.id);
    }
};


const handlePageAdded = async () => {
    await pagesStore.fetchPages();
    if (pagesStore.pages.length > 0) {
        await selectPage(pagesStore.pages[pagesStore.pages.length - 1].id);
    }
};

const handleDepartmentAdded = async () => {
    await departmentsStore.fetchDepartments();
};

const handleEmployeeAdded = async () => {
    await employeesStore.fetchEmployees();
};

const handlePeriodAdded = () => {
    // Данные уже обновлены в модальном окне
};

const handleDepartmentAddedToPeriod = async () => {
    editObj.value = null;
    viewDepartmentList.value = false;
    await handlePeriodRefresh();
};

// Выход из системы
const handleLogout = async () => {
    try {
        await authStore.logout();
        ElMessage.success("Вы успешно вышли из системы");
    } catch (error) {
        ElMessage.error("Ошибка при выходе из системы");
    }
};

// Инициализация
onMounted(async () => {
    try {
        // Проверяем авторизацию
        await authStore.checkAuth();
        checkingAuth.value = false;
        
        // Если авторизован, загружаем данные
        if (authStore.isAuthenticated) {
            await loadAppData();
        }
    } catch (error) {
        checkingAuth.value = false;
        if (authStore.isAuthenticated) {
            ElMessage.error("Ошибка при загрузке данных");
        }
    }
});
</script>

<style scoped>
.app-header {
    background-color: #1a5e73;
    color: white;
    display: flex;
    align-items: center;
    padding: 0 20px;
}

.header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
}

.header-title {
    font-size: 20px;
    font-weight: bold;
}

.header-actions {
    display: flex;
    gap: 10px;
}

.app-main {
    padding: 20px;
    background-color: #f5f5f5;
    min-height: calc(100vh - 120px);
    max-width: 100vw;
    overflow-x: hidden;
    box-sizing: border-box;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.header-buttons {
    display: flex;
    gap: 10px;
}

.current-page {
    flex: 1;
    text-align: end;
}

.empty-state {
    text-align: center;
    padding: 40px;
}

.main-card {
    width: 100%;
    max-width: 100%;
    overflow: hidden;
}

.main-card :deep(.el-card__body) {
    padding: 20px;
    max-width: 100%;
    overflow-x: hidden;
}


.app-footer {
    background-color: #1a5e73;
    color: white;
    display: flex;
    align-items: center;
    padding: 0 20px;
    max-width: 100%;
    overflow: hidden;
}

.footer-content {
    width: 100%;
    max-width: 100%;
}

.footer-content :deep(.el-scrollbar__wrap) {
    overflow-x: auto;
    overflow-y: hidden;
}

.footer-buttons {
    display: flex;
    gap: 10px;
    white-space: nowrap;
    padding: 5px 0;
}


/* Исправление разрыва в модальных окнах Element Plus */
:deep(.el-dialog__body) {
    padding-bottom: 20px;
}

:deep(.el-dialog__footer) {
    padding-top: 10px;
    border-top: 1px solid var(--el-border-color-lighter);
}
</style>

