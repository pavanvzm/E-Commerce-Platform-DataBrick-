# 🚀 Push Instructions for E-Commerce Database Schema

## Current Status
✅ All files have been created and committed locally:
- 10 migration files in `migrations/` folder
- GitHub Actions workflow in `.github/workflows/deploy-db.yml`
- `.gitignore` and `README.md`

## Why Push Failed
GitHub requires authentication. The following methods failed:
- HTTPS push (requires username/password or Personal Access Token)
- SSH push (requires deploy key to be added to repo settings)

## Option 1: Push Using Personal Access Token (Recommended)

### Step 1: Create a Personal Access Token
1. Go to: https://github.com/settings/tokens/new
2. Give it a name like "db-deploy-token"
3. Select scope: **repo** (full control of private repositories)
4. Click "Generate token"
5. **Copy the token immediately** (you won't see it again)

### Step 2: Push Using the Token
```bash
cd /workspace
export GITHUB_TOKEN="paste_your_token_here"
git push https://pavanvzm:${GITHUB_TOKEN}@github.com/pavanvzm/E-Commerce-Platform-DataBrick-.git main --force
```

## Option 2: Push Using GitHub CLI (If Installed)
```bash
cd /workspace
gh auth login  # Follow prompts to authenticate
git push origin main --force
```

## Option 3: Manual Upload via GitHub Web Interface

1. Go to: https://github.com/pavanvzm/E-Commerce-Platform-DataBrick-

2. Upload migrations folder:
   - Click "Add file" → "Upload files"
   - Drag all files from `/workspace/migrations/` folder
   - Commit with message: "Initial DB schema + One-Click Deploy setup"

3. Upload workflow:
   - Create folder `.github/workflows`
   - Upload `deploy-db.yml`

4. Upload other files:
   - `.gitignore`
   - `README.md`

## After Successful Push

### Configure GitHub Secrets
Go to: https://github.com/pavanvzm/E-Commerce-Platform-DataBrick-/settings/secrets/actions

Add these secrets:
| Secret | Description | Example |
|--------|-------------|---------|
| `DB_HOST` | Database hostname | `db.example.com` |
| `DB_USER` | Database username | `admin` |
| `DB_PASS` | Database password | `secure_password` |
| `DB_NAME` | Database name | `ecommerce_db` |

### Trigger Deployment
1. Go to: https://github.com/pavanvzm/E-Commerce-Platform-DataBrick-/actions
2. Click "Deploy Database Migrations" workflow
3. Click "Run workflow"
4. Select environment (production/staging)
5. Click "Run workflow" button

---

## Files Ready to Push
```
/workspace/
├── .github/
│   └── workflows/
│       └── deploy-db.yml
├── migrations/
│   ├── 001_create_users.sql
│   ├── 002_create_addresses.sql
│   ├── 003_create_categories.sql
│   ├── 004_create_brands.sql
│   ├── 005_create_products.sql
│   ├── 006_create_carts.sql
│   ├── 007_create_cart_items.sql
│   ├── 008_create_orders.sql
│   ├── 009_create_order_items.sql
│   └── 010_create_payments.sql
├── .gitignore
└── README.md
```
