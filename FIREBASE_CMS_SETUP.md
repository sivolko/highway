# Firebase CMS Hosting — Manual Setup Steps

The GitHub integration cannot write to `.github/workflows/` directly (GitHub requires
the `workflow` scope for that). Follow these steps once to complete the setup.

---

## Step 1 — Create Firebase hosting site for the CMS

In Firebase Console → Hosting → Add another site:
- Site ID: `highway-nomads-cms`
- This will be accessible at `https://highway-nomads-cms.web.app`

---

## Step 2 — Replace `.github/workflows/firebase-hosting-merge.yml`

Open the file in GitHub UI and replace the entire content with:

```yaml
name: Deploy to Firebase Hosting on merge

on:
  push:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    permissions:
      checks: write
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.1'
          bundler-cache: false

      - name: Install gems
        run: bundle install

      - name: Build Jekyll
        run: bundle exec jekyll build

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Build CMS
        run: cd cms && npm install && npm run build

      - name: Deploy blog to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_HIGHWAYNOMADS_DCC90 }}'
          channelId: live
          projectId: highwaynomads-dcc90
          target: blog

      - name: Deploy CMS to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_HIGHWAYNOMADS_DCC90 }}'
          channelId: live
          projectId: highwaynomads-dcc90
          target: cms
```

---

## Step 3 — Replace `.github/workflows/firebase-hosting-pull-request.yml`

Replace entire content with:

```yaml
name: Deploy to Firebase Hosting on PR

on: pull_request

jobs:
  build_and_preview:
    if: '${{ github.event.pull_request.head.repo.full_name == github.repository }}'
    runs-on: ubuntu-latest
    permissions:
      checks: write
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.1'
          bundler-cache: true

      - name: Install gems
        run: bundle install

      - name: Build Jekyll
        run: bundle exec jekyll build

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Build CMS
        run: cd cms && npm install && npm run build

      - name: Deploy preview to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_HIGHWAYNOMADS_DCC90 }}'
          projectId: highwaynomads-dcc90
          target: blog
```

---

## Step 4 — Verify secret exists

Go to: Settings → Secrets → Actions
Check that `FIREBASE_SERVICE_ACCOUNT_HIGHWAYNOMADS_DCC90` exists.
If not, re-run: `firebase init hosting` locally and re-link the repo.

---

## What happens after setup

| Event | blog (Jekyll) | cms (React) |
|---|---|---|
| Push to `main` | ✅ builds + deploys | ✅ builds + deploys |
| Pull Request | ✅ preview channel | ✅ preview channel |

- Blog → `https://highwaynomads-dcc90.web.app` (or your custom domain)
- CMS  → `https://highway-nomads-cms.web.app`
