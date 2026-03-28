# Laravel + React Starter Kit

Opinionated starter kit for building Laravel + React SPAs. No Inertia -- pure React frontend rendered via a single Blade template, communicating with Laravel API routes.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Laravel 13, PHP 8.4, Sanctum |
| Frontend | React 19, React Router 7, Vite 8 |
| Styling | Tailwind CSS 4 (CSS-first) |
| UI Components | Radix UI (headless) + shadcn pattern |
| Icons | Lucide React |
| HTTP | Axios (with credentials, 401 interceptor) |
| Database | SQLite (local), MySQL/PostgreSQL (production) |
| Deployment | Docker (PHP-FPM + Nginx + Supervisor) |
| Dev Tools | Laravel Boost (MCP), Pint, Pail, Sail |

## Quick Start

```bash
# Clone and enter
git clone <repo-url> my-app
cd my-app

# Full setup (composer, env, key, migrations, npm, build)
composer run setup

# Start development
composer run dev
```

This runs Laravel server, queue worker, log tail, and Vite dev server concurrently.

Or run them separately:

```bash
php artisan serve
npm run dev
```

## What's Included

### Backend
- **Sanctum** stateful API authentication (configured in `bootstrap/app.php`)
- **SPA catch-all route** -- all non-API routes serve the React app
- **API routes** with `auth:sanctum` middleware ready
- **Trust proxies** configured for reverse proxy deployments (Traefik, etc.)
- **Database sessions, cache, and queue** -- no Redis required

### Frontend
- **React 19** SPA with client-side routing (React Router)
- **Tailwind CSS v4** with shadcn-compatible CSS variables (light + dark mode)
- **Radix UI** headless components: Dialog, Dropdown, Select, Tabs, Toast, Tooltip, Popover, Switch, Label, Separator
- **`cn()` utility** (clsx + tailwind-merge) in `resources/js/lib/utils.js`
- **Axios** configured with `withCredentials`, JSON headers, and automatic 401 redirect
- **`@` path alias** for `resources/js`

### Docker
- Multi-stage Dockerfile (Node build -> Composer -> PHP 8.4-FPM Alpine)
- Nginx with gzip, security headers, static asset caching
- Supervisor managing PHP-FPM + Nginx
- SQLite persistent volume at `/var/www/html/data`
- Entrypoint with config caching and auto-migrations

### Developer Experience
- `composer run dev` -- one command to start everything
- `composer run setup` -- one command to bootstrap from scratch
- `composer run test` -- run PHPUnit tests
- Laravel Boost MCP integration (`.mcp.json` + `boost.json`)

## Project Structure

```
resources/
  js/
    app.jsx          # React entry point + routing
    bootstrap.js     # Axios configuration
    components/ui/   # Shadcn/Radix UI components (add yours here)
    hooks/           # React hooks
    lib/utils.js     # cn() utility
    pages/           # Page components
  css/
    app.css          # Tailwind v4 + shadcn theme variables
  views/
    app.blade.php    # Single Blade template (renders React)
routes/
  web.php            # SPA catch-all
  api.php            # API routes
docker/              # Nginx, PHP-FPM, Supervisor configs
Dockerfile           # Production multi-stage build
```

## Docker Build

```bash
docker build -t my-app .
docker run -p 80:80 -e APP_KEY=base64:... my-app
```

For persistent SQLite data, mount a volume:

```bash
docker run -p 80:80 -v app-data:/var/www/html/data -e APP_KEY=base64:... my-app
```

## Environment

Copy `.env.example` to `.env` and generate a key:

```bash
cp .env.example .env
php artisan key:generate
```

Key variables:
- `DB_CONNECTION` -- `sqlite` (default), `mysql`, or `pgsql`
- `SANCTUM_STATEFUL_DOMAINS` -- add your frontend domain for cookie auth
- `ANTHROPIC_API_KEY` -- if using Claude API

## License

MIT
