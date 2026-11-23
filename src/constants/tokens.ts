// Design tokens. scripts/check-styles.mjs fails when a screen uses a value outside these scales.
export const spacing = { xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 24, xxxl: 32 } as const;
export const radius = { sm: 4, md: 8, lg: 12, xl: 16, pill: 999 } as const;
export const iconSize = { sm: 16, md: 24, lg: 32 } as const;
export const fontSize = { sm: 12, md: 14, lg: 16, xl: 20, xxl: 28 } as const;
