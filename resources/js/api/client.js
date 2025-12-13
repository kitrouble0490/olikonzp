import axios from 'axios';

const apiClient = axios.create({
    baseURL: '/api',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
    withCredentials: true, // Важно для отправки cookies (сессий)
});

// Добавляем CSRF токен из meta тега
const csrfToken = document.querySelector('meta[name="csrf-token"]');
if (csrfToken) {
    apiClient.defaults.headers.common['X-CSRF-TOKEN'] = csrfToken.getAttribute('content');
}

// Обработка ошибок
apiClient.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response) {
            // Ошибка от сервера
            return Promise.reject(error.response.data);
        } else if (error.request) {
            // Запрос отправлен, но ответа нет
            return Promise.reject({ message: 'Нет ответа от сервера' });
        } else {
            // Ошибка при настройке запроса
            return Promise.reject({ message: error.message });
        }
    }
);

export default apiClient;

