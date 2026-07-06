---
name: Vigilant Guardian
colors:
  surface: '#f8faf7'
  surface-dim: '#d8dbd8'
  surface-bright: '#f8faf7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f1'
  surface-container: '#eceeeb'
  surface-container-high: '#e7e9e6'
  surface-container-highest: '#e1e3e0'
  on-surface: '#191c1b'
  on-surface-variant: '#45464e'
  inverse-surface: '#2e312f'
  inverse-on-surface: '#eff1ee'
  outline: '#75777f'
  outline-variant: '#c5c6cf'
  surface-tint: '#4f5e81'
  primary: '#041534'
  on-primary: '#ffffff'
  primary-container: '#1b2a4a'
  on-primary-container: '#8392b7'
  inverse-primary: '#b7c6ee'
  secondary: '#835400'
  on-secondary: '#ffffff'
  secondary-container: '#feb64e'
  on-secondary-container: '#714800'
  tertiary: '#370001'
  on-tertiary: '#ffffff'
  tertiary-container: '#5e0004'
  on-tertiary-container: '#f0665a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#b7c6ee'
  on-primary-fixed: '#0a1a3a'
  on-primary-fixed-variant: '#384668'
  secondary-fixed: '#ffddb5'
  secondary-fixed-dim: '#ffb956'
  on-secondary-fixed: '#2a1800'
  on-secondary-fixed-variant: '#643f00'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb4ab'
  on-tertiary-fixed: '#410002'
  on-tertiary-fixed-variant: '#8a1b18'
  background: '#f8faf7'
  on-background: '#191c1b'
  surface-variant: '#e1e3e0'
typography:
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Playfair Display
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Source Sans 3
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Source Sans 3
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-mono:
    fontFamily: IBM Plex Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm-mono:
    fontFamily: IBM Plex Mono
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.1em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
---

## Brand & Style

The design system is built upon the persona of the **Vigilant Guardian**. It draws inspiration from the solemnity of official Bengali judicial and banking documents, characterized by a direct, plain-spoken, and protective tone. The visual style avoids modern "app-like" fluff, opting instead for a **Corporate / Modern** foundation blended with **Tactile** elements that mimic the physical weight of ink and paper.

The core aesthetic revolves around the "Final Verdict." Every interaction should feel like a formal certification of safety or a stern warning of danger. To achieve this, the design utilizes a high-contrast, information-dense layout that prioritizes legibility and authority over decoration. The emotional response should be one of immediate relief or heightened alertness—never ambiguity.

## Colors

The palette is rooted in the "Ink and Paper" metaphor. 
- **Deep Indigo (#1B2A4A)**: Represents the authority of an official ledger. Use this for primary headers, navigation bars, and structural elements.
- **Marigold Amber (#E8A33D)**: A culturally resonant accent for high-priority actions and attention-grabbing alerts.
- **Danger Red (#C1443B)**: A muted, brick-like red used specifically for "High Risk" verdicts and destructive actions.
- **Safe Green (#2F8F5B)**: A deep forest green indicating total security.
- **Paper Background (#EFF1EE)**: A pale sage-white that reduces eye strain on mid-range mobile displays while maintaining a "physical document" feel.

## Typography

Typography is used to establish forensic hierarchy. 
- **Headlines**: Use Playfair Display for English titles to convey gravity and tradition. (For Bengali implementation, Tiro Bangla is the mandatory serif pairing).
- **Body**: Hind Siliguri (Bengali) and Source Sans 3 (English) provide clean, high-legibility sans-serif reading experiences for long-form explanations and settings.
- **Forensic Data**: IBM Plex Mono is used for all "evidence"—timestamps, transaction IDs, phone numbers, and risk scores—to give the impression of a computer-generated official record.

## Layout & Spacing

This design system uses a **fixed grid** approach optimized for mid-range Android devices common in the Bangladeshi market. 
- **Mobile**: 4-column grid with 20px side margins and 16px gutters.
- **Desktop/Tablet**: 12-column grid with 40px margins.

Spacing follows a strict 8px base unit. Vertical rhythm is critical; group related evidence data using `stack-sm`, while separating major logical sections (e.g., Verdict vs. Reasoning) with `stack-lg`. Components should be tightly packed to mimic the information density of a government form.

## Elevation & Depth

To maintain a serious and official tone, this design system rejects soft shadows and "floating" elements. 
- **Tonal Layers**: Use subtle shifts in background color (e.g., a slightly darker sage-white) to define containers rather than shadows.
- **Low-Contrast Outlines**: Cards and input fields should use 1px solid borders in a slightly darker shade of the background color or Deep Indigo at 20% opacity.
- **The Ink Stamp**: The only element that breaks the flat plane is the "Verdict Seal." It does not use a shadow but instead uses a "pressed" effect—a slight color multiply against the background and a -6 degree rotation to simulate a manual, physical stamp.

## Shapes

The shape language is rigid and disciplined. A **Soft (0.25rem / 4px)** corner radius is the standard for almost all elements (buttons, cards, input fields). This provides a professional edge that is softer than a pure 0px "Brutalist" corner but significantly more serious than "Rounded" consumer apps. 

The "Verdict Seal" is the exception; it should maintain the organic, slightly irregular circular or rectangular shape of a physical rubber stamp, with intentionally distressed edges.

## Components

### The Verdict Seal (Signature Element)
The primary component of the app. It must be placed at a -6 degree angle. 
- **Safe**: Safe Green ink, text "নিরাপদ".
- **Warning**: Marigold Amber ink, text "সতর্ক".
- **Danger**: Danger Red ink, text "উচ্চ ঝুঁকি".
The seal should have a 5% "ink-bleed" texture overlay to ensure it looks like a physical stamp.

### Buttons
Buttons are rectangular with 4px corners. 
- **Primary**: Deep Indigo background with White text.
- **Alert**: Marigold Amber background with Deep Indigo text (for immediate action).
- **Outline**: 1px Deep Indigo border for secondary forensic actions.

### Cards & Evidence Blocks
Use "Paper" white backgrounds with a 1px solid border. Headers within cards should use IBM Plex Mono for a "Case File" feel.

### Input Fields
Inputs should look like blanks on a form. Use a bottom border only or a very light 4px rounded stroke. Never use "floating" labels; labels should be persistent and set in IBM Plex Mono above the field.

### Status Indicators
Small, 8px square indicators (no circles) to denote "Live Scanning" or "Service Active," reinforcing the rigid, technical nature of the protection.