import axios from 'axios'

axios.defaults.withCredentials = true
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest'
axios.defaults.headers.common['Accept'] = 'application/json'

axios.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401
            && !window.location.pathname.startsWith('/login')) {
            window.location.replace('/login')
        }
        return Promise.reject(error)
    }
)
