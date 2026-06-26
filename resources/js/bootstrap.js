import axios from 'axios'

axios.defaults.withCredentials = true
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest'
axios.defaults.headers.common['Accept'] = 'application/json'

// A 401 should bounce the user to /login — but not when the request is a
// silent auth probe (e.g. checking the session on load) or when the user is
// already on a public page (auth screens, public/shared links). Otherwise a
// logged-out visitor on a public URL gets redirected away unexpectedly.
//
// Opt an individual request out with `axios.get(url, { skipAuthRedirect: true })`
// — use this for an on-load auth check. Add your app's public routes to
// PUBLIC_PATHS so 401s fired from them don't trigger the redirect.
const PUBLIC_PATHS = ['/login', '/register', '/forgot-password', '/reset-password']

function shouldRedirect(error) {
    if (error.config?.skipAuthRedirect) return false
    const path = window.location.pathname
    return !PUBLIC_PATHS.some((p) => path === p || path.startsWith(p + '/'))
}

axios.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401 && shouldRedirect(error)) {
            window.location.replace('/login')
        }
        return Promise.reject(error)
    }
)
