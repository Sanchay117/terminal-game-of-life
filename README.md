# Scripted Challenge Demos

This repository contains two small challenge demos and a GitHub Pages site that showcases them in the browser.

## Terminal Demos

- `hanoi.sh`: Tower of Hanoi in Bash with comments marking the recursive solver.
- `life.sh`: Conway's Game of Life in Bash with comments marking the iterative grid updates.

Run them locally with:

```bash
chmod +x ./hanoi.sh ./life.sh

bash ./hanoi.sh
bash ./hanoi.sh 5

bash ./life.sh
bash ./life.sh 30 15
```

## GitHub Pages Site

The repository also includes a static site:

- `index.html`
- `style.css`
- `script.js`

That site provides:

- a browser animation of **Tower of Hanoi**
- a browser simulation of **Conway's Game of Life**
- a cleaner public presentation than a plain code repository alone

## Deploying With GitHub Actions

The workflow file is:

- `.github/workflows/pages.yml`

To publish it:

1. Push this repository to GitHub.
2. Make sure your default branch is `main`.
3. In GitHub, open `Settings -> Pages`.
4. Set `Source` to `GitHub Actions`.
5. Push to `main` and the workflow will deploy the site automatically.

Your site URL will usually look like:

```text
https://<your-github-username>.github.io/<repo-name>/
```

## Why This Setup Helps

- The **Bash scripts** satisfy the scripted-language challenge directly.
- The **Pages site** makes the project easier to share publicly.
- The **browser versions** solve the limitation that GitHub Pages cannot run Bash scripts directly.
