enum FileKind { image, video, audio, document, other }

const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'bmp', 'svg', 'avif'};
const _videoExtensions = {'mp4', 'mkv', 'webm', 'mov', 'avi', '3gp', 'm4v'};
const _audioExtensions = {'mp3', 'm4a', 'aac', 'wav', 'flac', 'ogg', 'opus'};
const _documentExtensions = {
  'pdf',
  'doc',
  'docx',
  'xls',
  'xlsx',
  'ppt',
  'pptx',
  'txt',
  'md',
  'csv',
  'rtf',
  'odt',
  'epub',
};

/// Classifies a file by its mime type, or by its extension when the mime type is missing.
FileKind fileKindOf({String? mimeType, String extension = ''}) {
  final mime = (mimeType ?? '').toLowerCase();
  if (mime.startsWith('image/')) return FileKind.image;
  if (mime.startsWith('video/')) return FileKind.video;
  if (mime.startsWith('audio/')) return FileKind.audio;
  if (mime == 'application/pdf' || mime.startsWith('text/')) {
    return FileKind.document;
  }
  final ext = extension.toLowerCase();
  if (_imageExtensions.contains(ext)) return FileKind.image;
  if (_videoExtensions.contains(ext)) return FileKind.video;
  if (_audioExtensions.contains(ext)) return FileKind.audio;
  if (_documentExtensions.contains(ext)) return FileKind.document;
  return FileKind.other;
}
