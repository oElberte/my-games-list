# Store listing metadata

App store listing copy for **My Games List**, in English (`en-US`) and Brazilian Portuguese (`pt-BR`).

The layout follows the [fastlane](https://docs.fastlane.tools) convention so it works directly with `supply` (Google Play) and `deliver` (App Store).

> **All text here is DRAFT.** It needs the owner's review and approval before any store submission, and should be re-checked against the shipping build so it never describes a feature the app does not have.

## Layout

```
fastlane/metadata/
├── android/                  # Google Play (supply)
│   ├── en-US/
│   │   ├── title.txt
│   │   ├── short_description.txt
│   │   └── full_description.txt
│   └── pt-BR/                # same three files
└── ios/                      # App Store (deliver)
    ├── en-US/
    │   ├── name.txt
    │   ├── subtitle.txt
    │   ├── promotional_text.txt
    │   ├── description.txt
    │   └── keywords.txt
    └── pt-BR/                # same five files
```

## Character limits

| Store        | Field                | File                    | Limit  |
| ------------ | -------------------- | ----------------------- | ------ |
| Google Play  | Title                | `title.txt`             | 30     |
| Google Play  | Short description    | `short_description.txt` | 80     |
| Google Play  | Full description     | `full_description.txt`  | 4000   |
| App Store    | Name                 | `name.txt`              | 30     |
| App Store    | Subtitle             | `subtitle.txt`          | 30     |
| App Store    | Promotional text     | `promotional_text.txt`  | 170    |
| App Store    | Keywords (CSV)       | `keywords.txt`          | 100    |
| App Store    | Description          | `description.txt`       | 4000   |

The DRAFT markers at the bottom of the long descriptions are **not** part of the published copy. Remove them before submission (they keep the count well under the limit while drafting).

## Still TODO (owner-provided)

These are assets/decisions this PR intentionally does not cover:

- **Screenshots** (phone, tablet) and **feature graphic** (1024x500) — depends on branding (#15).
- **App icon** — depends on branding (#15).
- **Privacy policy URL** — link the published policy once available (Play Data safety + App Store privacy section). The app already exposes data export and account deletion (LGPD).
- **Content rating** questionnaire (Play) / age rating (App Store).
- **Data safety / privacy declarations** — declare data collection accurately. The app collects account email and uses optional Firebase Cloud Messaging for push (consent-gated).
- **Permission declarations** — the Android manifest currently requests `INTERNET` only. Declare any further runtime permissions (e.g. notifications) only if/when they are actually added.
- **Final copy approval** in both locales.

## Updating

Edit the `.txt` files in place; keep both locales in sync. Mirror any wording change in `android/` and `ios/` so the two stores stay consistent.
