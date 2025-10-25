# _USEME_ Template Documentation & Examples

This folder contains all detailed documentation, configuration examples, and workflow patterns.

## 📚 Start Here

### 👤 **For Humans:**
Start with **[docs/PRODUCTION_READY.md](docs/PRODUCTION_READY.md)** - Complete overview, quick start guide, and feature list.

### 🤖 **For AI Assistants:**
Start with **[docs/AI-INSTRUCTIONS.md](docs/AI-INSTRUCTIONS.md)** - Step-by-step instructions for creating new actions from this template.

---

## 📁 Organized Folders

### 📋 [docs/](docs/) - Core Documentation
- **[PRODUCTION_READY.md](docs/PRODUCTION_READY.md)** - Human-friendly overview and quick start
- **[AI-INSTRUCTIONS.md](docs/AI-INSTRUCTIONS.md)** - AI agent guide for using this template
- **[PUBLIC_RELEASE_CHECKLIST.md](docs/PUBLIC_RELEASE_CHECKLIST.md)** - Verification that template is public-ready

### 📄 [configs/](configs/) - Configuration Examples
Example configuration files showing all supported formats:
- **[config-example.env](configs/config-example.env)** - .env format (recommended)
- **[config-example.json](configs/config-example.json)** - JSON format
- **[config-example.txt](configs/config-example.txt)** - .txt format

All examples show required and optional fields defined in `../action-spec.json`.

### 🔧 [workflows/](workflows/) - Workflow Usage Examples

#### [Basic Usage](workflows/basic-usage.md)
Simple single-step workflow with .env config file.
- **Use when:** Getting started, simple workflows
- **Format:** .env file
- **Complexity:** ⭐ Beginner

#### [JSON Configuration](workflows/json-config.md)
Using JSON format instead of .env files.
- **Use when:** Prefer JSON, complex data structures
- **Format:** JSON file
- **Complexity:** ⭐ Beginner

#### [Chaining Actions](workflows/chaining-actions.md)
Pass config between multiple actions in a workflow.
- **Use when:** Multi-step workflows, progressive builds
- **Format:** .env file (shared)
- **Complexity:** ⭐⭐ Intermediate

#### [Multiple Configurations](workflows/multiple-configs.md)
Run same action with different config files.
- **Use when:** Multi-environment deployments
- **Format:** Multiple .env files
- **Complexity:** ⭐⭐ Intermediate

#### [Using with Secrets](workflows/with-secrets.md)
Combine config files with repository secrets.
- **Use when:** Working with sensitive data, production
- **Format:** .env + secrets
- **Complexity:** ⭐⭐⭐ Advanced

#### [Conditional Execution](workflows/conditional-execution.md)
Run action only when certain conditions are met.
- **Use when:** Branch-specific, conditional deployments
- **Format:** Any
- **Complexity:** ⭐⭐ Intermediate

#### [Using Reusable Actions](workflows/using-reusable-actions.md)
Advanced patterns for reusable actions.
- **Use when:** Building action libraries
- **Format:** Any
- **Complexity:** ⭐⭐⭐ Advanced

---

## 🗂️ Directory Structure

```
examples/
├── README.md                           ← You are here
│
├── docs/                               ← Core Documentation
│   ├── PRODUCTION_READY.md             ← Start here (humans)
│   ├── AI-INSTRUCTIONS.md              ← Start here (AI)
│   └── PUBLIC_RELEASE_CHECKLIST.md
│
├── configs/                            ← Configuration Examples
│   ├── config-example.env
│   ├── config-example.json
│   └── config-example.txt
│
└── workflows/                          ← Workflow Usage Examples
    ├── basic-usage.md                  ← Recommended first example
    ├── json-config.md
    ├── chaining-actions.md
    ├── multiple-configs.md
    ├── with-secrets.md
    ├── conditional-execution.md
    └── using-reusable-actions.md
```

---

## 🎯 Quick Reference

| I want to... | Read this |
|--------------|-----------|
| Understand the template | [docs/PRODUCTION_READY.md](docs/PRODUCTION_READY.md) |
| Create a new action (AI) | [docs/AI-INSTRUCTIONS.md](docs/AI-INSTRUCTIONS.md) |
| Verify template is ready | [docs/PUBLIC_RELEASE_CHECKLIST.md](docs/PUBLIC_RELEASE_CHECKLIST.md) |
| See config file formats | [configs/](configs/) |
| Learn workflow patterns | [workflows/](workflows/) |

| Scenario | Example | Config Format |
|----------|---------|---------------|
| First time using action | [Basic Usage](workflows/basic-usage.md) | `.env` |
| Prefer JSON | [JSON Config](workflows/json-config.md) | `.json` |
| Multi-step workflow | [Chaining Actions](workflows/chaining-actions.md) | `.env` |
| Multiple environments | [Multiple Configs](workflows/multiple-configs.md) | `.env.*` |
| Production/secrets | [With Secrets](workflows/with-secrets.md) | `.env` + secrets |
| Branch-specific | [Conditional Execution](workflows/conditional-execution.md) | Any |
| Reusable patterns | [Reusable Actions](workflows/using-reusable-actions.md) | Any |
