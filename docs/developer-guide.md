# Developer Guide

## Prerequisites

- Node.js 18+ and npm
- Python 3.9+
- Docker and Docker Compose
- Git

## Initial Setup

1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/pointpath.git
cd pointpath
```

2. Start database services
```bash
docker-compose up -d
```

3. Setup frontend
```bash
cd frontend
npm install
cp .env.local.example .env.local
npm run dev
```

4. Setup backend
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

5. Setup scraper
```bash
cd scrapers
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
playwright install chromium
```

## Development Workflow

*To be expanded as development progresses*