import 'legal_models.dart';

const LegalDocument termsEn = LegalDocument(
  kind: LegalKind.terms,
  languageCode: 'en',
  title: 'Terms and conditions',
  updatedLabel: 'Last updated: November 25, 2026',
  intro:
      'These terms govern the use of Nombra, an Android app that downloads files from a link and saves them with a '
      'name you define with rules. By using the app you accept these terms. If you do not agree, do not use it.',
  sections: [
    LegalSection(
      title: '1. What Nombra does',
      paragraphs: [
        'Nombra downloads a file from an https link that you provide, or receives a file or link that you share from '
            'another app, and saves it in a public folder of your phone with the name that results from your rules. '
            'You can sign in with your Google account to back up your rules in the cloud.',
      ],
    ),
    LegalSection(
      title: '2. License',
      paragraphs: [
        'We give you a personal, non-exclusive, non-transferable and revocable license to use Nombra on your devices. '
            'The app, its design and its code remain the property of the developer.',
      ],
    ),
    LegalSection(
      title: '3. Your responsibility for what you download',
      paragraphs: [
        'Nombra does not review, host or control the files you download: they come directly from the site you '
            'indicate. You are responsible for:',
      ],
      items: [
        'having the right to download, copy and use each file, respecting copyright and the terms of the source site;',
        'not using the app to obtain or distribute illegal or malicious content, or content that infringes the rights '
            'of others;',
        'checking that a file is safe before you open it.',
      ],
    ),
    LegalSection(
      title: '4. Account and backup',
      paragraphs: [
        'The Google account is optional. If you sign in, your rules are stored in the cloud and kept up to date '
            'automatically across your devices. You can sign out at any time and delete the backup from '
            'Settings › Account. Keeping your Google account secure is your responsibility.',
        'The backup is a convenience, not a guarantee: keep your own copies of anything important.',
      ],
    ),
    LegalSection(
      title: '5. Acceptable use',
      paragraphs: ['You may not:'],
      items: [
        'try to access other people\'s systems or data without permission;',
        'overload or interfere with the app\'s cloud service;',
        'decompile, copy or redistribute the app except where the law allows it.',
      ],
    ),
    LegalSection(
      title: '6. No warranty',
      paragraphs: [
        'Nombra is provided "as is" and "as available". We do not guarantee that it will run without interruptions or '
            'errors, that a file will always be saved with the name you expect, or that the backup will always be '
            'available.',
      ],
    ),
    LegalSection(
      title: '7. Limitation of liability',
      paragraphs: [
        'To the extent the law allows, the developer is not liable for indirect damages or for the loss of files or '
            'data arising from the use of the app, from the files you download or from failures of third-party '
            'services (such as Google or Firebase). Nothing in these terms limits the rights the law gives you as a '
            'consumer.',
      ],
    ),
    LegalSection(
      title: '8. Changes and termination',
      paragraphs: [
        'We may update the app and these terms. The date above shows the latest version; if a change is important, we '
            'will tell you in the app. Continuing to use the app after a change means you accept it. You can stop '
            'using Nombra at any time, and we may suspend an account that breaks these terms.',
      ],
    ),
    LegalSection(
      title: '9. Privacy',
      paragraphs: ['How your data is handled is explained in the Privacy policy, which is part of these terms.'],
    ),
    LegalSection(title: '10. Contact', paragraphs: ['For any question about these terms write to $legalContactEmail.']),
  ],
);

const LegalDocument privacyEn = LegalDocument(
  kind: LegalKind.privacy,
  languageCode: 'en',
  title: 'Privacy policy',
  updatedLabel: 'Last updated: November 25, 2026',
  intro:
      'This policy explains what data Nombra handles, what for and what control you have over it. In short: the app '
      'works without an account and keeps your data on your phone; if you choose to sign in with Google, it only '
      'backs up your renaming rules. There is no advertising and no usage analytics.',
  sections: [
    LegalSection(
      title: '1. Data that stays on your phone',
      paragraphs: ['Nombra keeps on your device, without sending it to anyone:'],
      items: [
        'your renaming rules and your settings (theme, language, default folder);',
        'the download history: file name, folder and the source link, up to 50 items and 90 days;',
        'the downloaded files, which are saved in public folders of your phone (Downloads, Documents, Pictures, Movies '
            'or Music) and not in a private place of the app.',
      ],
    ),
    LegalSection(
      title: '2. Downloads',
      paragraphs: [
        'When you download a link, your phone connects directly to the source site. That site can see your IP address '
            'and the usual technical data of a connection. Nombra does not use an intermediate server and does not '
            'receive or store the content you download or your links.',
      ],
    ),
    LegalSection(
      title: '3. Google account (optional)',
      paragraphs: [
        'If you sign in, Google and Firebase Authentication give us a unique user identifier, your e-mail and your '
            'name. We use them only to identify your backup and to show your account in Settings.',
      ],
    ),
    LegalSection(
      title: '4. Rules backup in the cloud',
      paragraphs: [
        'While you are signed in, the list of your rules is stored in Cloud Firestore, in a document that only your '
            'account can read, write or delete. It contains your rules (name, pattern, folder, options and the '
            'numbering counter), a random identifier of the device that wrote last and the update date. It does not '
            'include your history or your files.',
        'You sign out in Settings › Account and the rules stay on your phone and in the cloud. "Delete backup and sign '
            'out" removes the document from the cloud. Your sign-in record (identifier and e-mail) stays in Firebase '
            'Authentication until you ask us to delete it.',
      ],
    ),
    LegalSection(
      title: '5. Crash reports',
      paragraphs: [
        'In published versions, Firebase Crashlytics receives reports when the app closes because of an error: device '
            'model, Android and app version, the technical detail of the error and an installation identifier. '
            'Before sending them, Nombra replaces any link that appears in the error. They are used only to fix '
            'crashes and Firebase keeps them for the period set in its documentation.',
      ],
    ),
    LegalSection(
      title: '6. Permissions',
      items: [
        'Internet: to download files and to use the account and the backup.',
        'Notifications (Android 13 or later): to tell you the progress and the result of a download. They are local; '
            'they are not sent to a server.',
      ],
    ),
    LegalSection(
      title: '7. What we do not do',
      items: [
        'We do not show advertising or sell your data.',
        'We do not use usage analytics or tracking across apps.',
        'We do not read your files, or access your contacts, location, microphone or camera.',
        'The app is not included in Android\'s automatic backups.',
      ],
    ),
    LegalSection(
      title: '8. Providers',
      paragraphs: [
        'For the account, the backup and the crash reports we use Google services (Firebase and Google Sign-In). They '
            'handle data under their own privacy policy: policies.google.com/privacy.',
      ],
    ),
    LegalSection(
      title: '9. Your rights',
      paragraphs: [
        'You can sign out, delete your backup from the app and clear the history from Settings. To access your data, '
            'correct it or ask for your account and everything linked to it to be deleted, write to '
            '$legalContactEmail. If you uninstall the app, the local data is deleted.',
      ],
    ),
    LegalSection(
      title: '10. Children',
      paragraphs: [
        'Nombra is not directed to children under 13 and does not knowingly collect data from them. If you believe a '
            'child signed in, write to us and we will delete their data.',
      ],
    ),
    LegalSection(
      title: '11. Changes',
      paragraphs: [
        'If this policy changes, we will update the date above and, if the change is important, we will tell you in '
            'the app.',
      ],
    ),
    LegalSection(title: '12. Contact', paragraphs: ['For any privacy question write to $legalContactEmail.']),
  ],
);
