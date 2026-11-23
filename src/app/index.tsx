import { StyleSheet, Text, View } from 'react-native';
import { useTranslation } from 'react-i18next';

import { fontSize, spacing } from '@/constants/tokens';

export default function HomeScreen() {
  const { t } = useTranslation();
  return (
    <View style={styles.container}>
      <Text style={styles.title}>{t('home.title')}</Text>
      <Text>{t('home.subtitle')}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: spacing.lg },
  title: { fontSize: fontSize.xxl, fontWeight: '700' },
});
