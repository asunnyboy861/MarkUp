# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | MarkUp |
| **Git URL** | git@github.com:asunnyboy861/MarkUp.git |
| **Repo URL** | https://github.com/asunnyboy861/MarkUp |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/MarkUp/ | ✅ Active |
| Support | https://asunnyboy861.github.io/MarkUp/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/MarkUp/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/MarkUp/terms.html | ✅ Active |

## Repository Structure

```
MarkUp/
├── MarkUp/                        # iOS App Source Code
│   ├── MarkUp.xcodeproj/          # Xcode Project
│   ├── MarkUp/                    # Swift Source Files
│   │   ├── Views/
│   │   │   ├── Home/              # Photo grid & import
│   │   │   ├── Editor/            # Canvas & annotation editor
│   │   │   ├── Templates/         # Template management
│   │   │   ├── Batch/             # Batch editing
│   │   │   ├── Settings/          # App settings
│   │   │   ├── Support/           # Contact support
│   │   │   └── Paywall/           # Subscription paywall
│   │   ├── Models/                # Data models
│   │   ├── Services/              # Business logic & IAP
│   │   └── ...
│   └── ...
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── keytext.md
├── capabilities.md
├── icon.md
├── price.md
└── nowgit.md
```
